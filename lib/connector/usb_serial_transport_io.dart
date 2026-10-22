import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:usb_serial/usb_serial.dart';

import 'byte_stream_connection.dart';
import 'meshcore_device.dart';

/// MeshCore companion radios run their serial link at 115200 8N1.
const int _defaultBaudRate = 115200;

/// Opens USB serial ports: Android USB OTG via `usb_serial`, desktop OS serial
/// ports via `flutter_libserialport`. iOS has neither and is unsupported.
class UsbSerialBackend {
  Future<List<MeshCoreDevice>> listDevices() async {
    if (Platform.isAndroid) {
      return _listAndroidDevices();
    }
    if (Platform.isIOS) {
      return [];
    }
    return _listDesktopPorts();
  }

  Future<List<MeshCoreDevice>> _listAndroidDevices() async {
    final devices = await UsbSerial.listDevices();
    return devices.map((device) {
      final vid = device.vid?.toRadixString(16).padLeft(4, '0') ?? '????';
      final pid = device.pid?.toRadixString(16).padLeft(4, '0') ?? '????';
      final productName = device.productName?.trim();
      final manufacturer = device.manufacturerName?.trim();
      final displayName = productName?.isNotEmpty == true
          ? productName!
          : manufacturer?.isNotEmpty == true
          ? manufacturer!
          : 'USB $vid:$pid';
      return MeshCoreDevice(
        id: '${device.deviceId}',
        displayName: displayName,
        transportKind: MeshCoreTransportKind.usb,
        subtitle: 'VID:$vid PID:$pid',
      );
    }).toList();
  }

  Future<List<MeshCoreDevice>> _listDesktopPorts() async {
    return SerialPort.availablePorts
        .map(
          (portName) => MeshCoreDevice(
            id: portName,
            displayName: portName,
            transportKind: MeshCoreTransportKind.usb,
            subtitle: portName,
          ),
        )
        .toList();
  }

  Future<ByteStreamConnection> connect(MeshCoreDevice device) async {
    if (Platform.isAndroid) {
      return _connectAndroid(device);
    }
    if (Platform.isIOS) {
      throw UnsupportedError('USB serial is not supported on iOS');
    }
    return _connectDesktop(device);
  }

  Future<ByteStreamConnection> _connectAndroid(MeshCoreDevice device) async {
    final deviceId = int.tryParse(device.id);
    if (deviceId == null) {
      throw Exception('Invalid Android USB device id: ${device.id}');
    }

    final devices = await UsbSerial.listDevices();
    final match = devices.where((entry) => entry.deviceId == deviceId);
    if (match.isEmpty) {
      throw Exception('USB device not found — reconnect the cable');
    }

    final port = await match.first.create();
    if (port == null) {
      throw Exception('Failed to open USB serial port');
    }

    // open() is what triggers Android's USB permission dialog, so a false here
    // usually means the user declined rather than a hardware fault.
    final opened = await port.open();
    if (!opened) {
      throw Exception('USB permission denied or port could not be opened');
    }

    await port.setDTR(true);
    await port.setRTS(true);
    await port.setPortParameters(
      _defaultBaudRate,
      UsbPort.DATABITS_8,
      UsbPort.STOPBITS_1,
      UsbPort.PARITY_NONE,
    );

    final inputStream = port.inputStream;
    if (inputStream == null) {
      await port.close();
      throw Exception('USB serial port produced no input stream');
    }

    final controller = StreamController<Uint8List>();
    final subscription = inputStream.listen(
      (data) {
        if (data.isNotEmpty && !controller.isClosed) {
          controller.add(Uint8List.fromList(data));
        }
      },
      // Surface the loss instead of swallowing it: the transport reconnects off
      // this signal, and a silently dead stream would just hang the session.
      onError: (Object error, StackTrace stack) {
        if (!controller.isClosed) controller.addError(error, stack);
      },
      onDone: () => unawaited(controller.close()),
    );

    return ByteStreamConnection(
      input: controller.stream,
      write: (data) async {
        await port.write(data);
      },
      close: () async {
        await subscription.cancel();
        await port.close();
        if (!controller.isClosed) await controller.close();
      },
    );
  }

  Future<ByteStreamConnection> _connectDesktop(MeshCoreDevice device) async {
    final port = SerialPort(device.id);
    if (!port.openReadWrite()) {
      final error = SerialPort.lastError;
      throw Exception(
        'Failed to open serial port ${device.id}: '
        '${error?.message ?? 'unknown error'}',
      );
    }

    final config = SerialPortConfig();
    config.baudRate = _defaultBaudRate;
    config.bits = 8;
    config.stopBits = 1;
    config.parity = SerialPortParity.none;
    port.config = config;

    final reader = SerialPortReader(port);
    final controller = StreamController<Uint8List>();
    final subscription = reader.stream.listen(
      (data) {
        if (data.isNotEmpty && !controller.isClosed) {
          controller.add(Uint8List.fromList(data));
        }
      },
      onError: (Object error, StackTrace stack) {
        if (!controller.isClosed) controller.addError(error, stack);
      },
      onDone: () => unawaited(controller.close()),
    );

    return ByteStreamConnection(
      input: controller.stream,
      write: (data) async {
        // libserialport may accept a partial buffer; keep going until it's all
        // out, or the frame arrives truncated and desynchronizes the stream.
        var offset = 0;
        while (offset < data.length) {
          final written = port.write(
            offset == 0 ? data : Uint8List.sublistView(data, offset),
          );
          if (written <= 0) {
            throw Exception(
              'Serial port write failed on ${device.id} at offset $offset',
            );
          }
          offset += written;
        }
      },
      close: () async {
        await subscription.cancel();
        reader.close();
        port.close();
        if (!controller.isClosed) await controller.close();
      },
    );
  }
}

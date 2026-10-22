import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/connector/byte_stream_connection.dart';
import 'package:gulf_coast_mesh_app/connector/byte_stream_meshcore_transport.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_device.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_transport.dart';

class _DeferredUsbTransport extends ByteStreamMeshCoreTransport {
  final enumerations = <Completer<List<MeshCoreDevice>>>[];
  final _input = StreamController<Uint8List>.broadcast();
  bool _disposed = false;

  @override
  MeshCoreTransportKind get kind => MeshCoreTransportKind.usb;

  @override
  Future<List<MeshCoreDevice>> discoverDevices() {
    final completion = Completer<List<MeshCoreDevice>>();
    enumerations.add(completion);
    return completion.future;
  }

  @override
  Future<ByteStreamConnection> openConnection(MeshCoreDevice device) async =>
      ByteStreamConnection(
        input: _input.stream,
        write: (_) async {},
        close: _input.close,
      );

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    super.dispose();
    unawaited(_input.close());
  }
}

void main() {
  const oldDevice = MeshCoreDevice(
    id: '/dev/ttyUSB0',
    displayName: 'Old USB radio',
    transportKind: MeshCoreTransportKind.usb,
  );
  const newDevice = MeshCoreDevice(
    id: '/dev/ttyUSB1',
    displayName: 'New USB radio',
    transportKind: MeshCoreTransportKind.usb,
  );

  late _DeferredUsbTransport transport;
  setUp(() => transport = _DeferredUsbTransport());
  tearDown(() => transport.dispose());

  test('current enumeration publishes devices and leaves scanning', () async {
    final scan = transport.startDiscovery();
    expect(transport.state, MeshCoreConnectionState.scanning);
    transport.enumerations.single.complete([newDevice]);
    await scan;
    expect(transport.discoveredDevices, [newDevice]);
    expect(transport.state, MeshCoreConnectionState.disconnected);
  });

  test('current enumeration failure remains recoverable', () async {
    final scan = transport.startDiscovery();
    final failure = expectLater(scan, throwsStateError);
    transport.enumerations.single.completeError(StateError('USB unavailable'));
    await failure;
    expect(transport.state, MeshCoreConnectionState.disconnected);

    final retry = transport.startDiscovery();
    transport.enumerations.last.complete([newDevice]);
    await retry;
    expect(transport.discoveredDevices, [newDevice]);
  });

  for (final failOldScan in [false, true]) {
    test(
      'stale enumeration preserves newer scan (failure=$failOldScan)',
      () async {
        final oldScan = transport.startDiscovery();
        await transport.stopDiscovery();
        final newScan = transport.startDiscovery();
        final oldCompletion = expectLater(oldScan, completes);

        if (failOldScan) {
          transport.enumerations.first.completeError(
            StateError('Old USB enumeration failed'),
          );
        } else {
          transport.enumerations.first.complete([oldDevice]);
        }
        await oldCompletion;
        expect(transport.state, MeshCoreConnectionState.scanning);
        expect(transport.discoveredDevices, isEmpty);

        transport.enumerations.last.complete([newDevice]);
        await newScan;
        expect(transport.discoveredDevices, [newDevice]);
        expect(transport.state, MeshCoreConnectionState.disconnected);
      },
    );
  }

  test('stale enumeration cannot overwrite completed newer results', () async {
    final oldScan = transport.startDiscovery();
    await transport.stopDiscovery();
    final newScan = transport.startDiscovery();
    transport.enumerations.last.complete([newDevice]);
    await newScan;

    transport.enumerations.first.complete([oldDevice]);
    await oldScan;
    expect(transport.discoveredDevices, [newDevice]);
    expect(transport.state, MeshCoreConnectionState.disconnected);
  });

  test('stopped enumeration cannot publish its late results', () async {
    final scan = transport.startDiscovery();
    await transport.stopDiscovery();
    transport.enumerations.single.complete([oldDevice]);
    await scan;
    expect(transport.discoveredDevices, isEmpty);
    expect(transport.state, MeshCoreConnectionState.disconnected);
  });

  test('connecting invalidates an unfinished enumeration', () async {
    final scan = transport.startDiscovery();
    await transport.connect(newDevice);
    expect(transport.state, MeshCoreConnectionState.connected);

    transport.enumerations.single.complete([oldDevice]);
    await scan;
    expect(transport.discoveredDevices, isEmpty);
    expect(transport.state, MeshCoreConnectionState.connected);
    await transport.disconnect();
  });

  for (final failOldScan in [false, true]) {
    test(
      'dispose invalidates an unfinished enumeration (failure=$failOldScan)',
      () async {
        final scan = transport.startDiscovery();
        transport.dispose();
        final completion = expectLater(scan, completes);
        if (failOldScan) {
          transport.enumerations.single.completeError(
            StateError('USB enumeration completed after disposal'),
          );
        } else {
          transport.enumerations.single.complete([oldDevice]);
        }
        await completion;
        expect(transport.discoveredDevices, isEmpty);
      },
    );
  }
}

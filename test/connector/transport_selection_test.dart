import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_connector.dart';

/// A transport that records what it was asked to do and never touches hardware.
class _FakeTransport implements MeshCoreTransport {
  _FakeTransport(this.kind);

  @override
  final MeshCoreTransportKind kind;

  final List<MeshCoreDevice> connectCalls = [];
  final List<bool> disconnectImmediateFlags = [];
  final List<Uint8List> sentFrames = [];
  int discoveryStarts = 0;
  int discoveryStops = 0;
  bool disposed = false;

  /// When set, [connect] throws this instead of succeeding.
  Object? connectError;

  MeshCoreConnectionState _state = MeshCoreConnectionState.disconnected;
  final _stateController =
      StreamController<MeshCoreConnectionState>.broadcast();
  final _framesController = StreamController<Uint8List>.broadcast();
  final _discoveryController = StreamController<void>.broadcast();

  final List<MeshCoreDevice> _discovered = [];
  void seedDiscovered(List<MeshCoreDevice> devices) {
    _discovered
      ..clear()
      ..addAll(devices);
  }

  @override
  MeshCoreConnectionState get state => _state;

  @override
  Stream<MeshCoreConnectionState> get stateChanges => _stateController.stream;

  @override
  Stream<Uint8List> get incomingFrames => _framesController.stream;

  @override
  Stream<void> get discoveryUpdates => _discoveryController.stream;

  @override
  List<MeshCoreDevice> get discoveredDevices => List.unmodifiable(_discovered);

  void _setState(MeshCoreConnectionState next) {
    _state = next;
    if (!_stateController.isClosed) _stateController.add(next);
  }

  @override
  Future<void> startDiscovery({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    discoveryStarts++;
    _setState(MeshCoreConnectionState.scanning);
    _setState(MeshCoreConnectionState.disconnected);
  }

  @override
  Future<void> stopDiscovery() async {
    discoveryStops++;
  }

  @override
  Future<void> connect(
    MeshCoreDevice device, {
    bool isReconnect = false,
  }) async {
    connectCalls.add(device);
    final error = connectError;
    if (error != null) throw error;
    _setState(MeshCoreConnectionState.connected);
  }

  @override
  Future<void> disconnect({bool immediate = false}) async {
    disconnectImmediateFlags.add(immediate);
    _setState(MeshCoreConnectionState.disconnected);
  }

  @override
  Future<void> sendFrame(Uint8List data) async => sentFrames.add(data);

  @override
  void dispose() {
    disposed = true;
    _stateController.close();
    _framesController.close();
    _discoveryController.close();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // The connector reaches for secure storage during teardown.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
          (call) async => call.method == 'readAll' ? <String, String>{} : null,
        );
  });

  ({
    MeshCoreConnector connector,
    _FakeTransport ble,
    _FakeTransport usb,
    _FakeTransport tcp,
  })
  buildConnector() {
    final ble = _FakeTransport(MeshCoreTransportKind.ble);
    final usb = _FakeTransport(MeshCoreTransportKind.usb);
    final tcp = _FakeTransport(MeshCoreTransportKind.tcp);
    final connector = MeshCoreConnector(
      transportOverrides: {
        MeshCoreTransportKind.ble: ble,
        MeshCoreTransportKind.usb: usb,
        MeshCoreTransportKind.tcp: tcp,
      },
    );
    addTearDown(connector.dispose);
    return (connector: connector, ble: ble, usb: usb, tcp: tcp);
  }

  const bleDevice = MeshCoreDevice(
    id: 'AA:BB:CC:DD:EE:FF',
    displayName: 'MeshCore-BLE',
    transportKind: MeshCoreTransportKind.ble,
  );
  const usbDevice = MeshCoreDevice(
    id: '/dev/ttyUSB0',
    displayName: 'Bench radio',
    transportKind: MeshCoreTransportKind.usb,
  );
  const tcpDevice = MeshCoreDevice(
    id: '192.168.1.50:5000',
    displayName: 'Roof node',
    transportKind: MeshCoreTransportKind.tcp,
  );

  group('connect() dispatches on transportKind', () {
    for (final (label, device, kind) in [
      ('BLE', bleDevice, MeshCoreTransportKind.ble),
      ('USB', usbDevice, MeshCoreTransportKind.usb),
      ('TCP', tcpDevice, MeshCoreTransportKind.tcp),
    ]) {
      test('a $label device goes to the $label transport only', () async {
        final h = buildConnector();
        final transports = {
          MeshCoreTransportKind.ble: h.ble,
          MeshCoreTransportKind.usb: h.usb,
          MeshCoreTransportKind.tcp: h.tcp,
        };

        // Self-info never arrives from a fake radio, so connect() throws after
        // reaching the transport. The dispatch is what's under test.
        await expectLater(h.connector.connect(device), throwsA(isA<Object>()));

        expect(transports[kind]!.connectCalls.single.id, device.id);
        for (final entry in transports.entries) {
          if (entry.key == kind) continue;
          expect(
            entry.value.connectCalls,
            isEmpty,
            reason: '${entry.key.name} transport should not have been used',
          );
        }
        // The failed handshake must tear the session down rather than leave a
        // half-open one behind.
        expect(transports[kind]!.disconnectImmediateFlags, contains(true));
        expect(h.connector.state, MeshCoreConnectionState.disconnected);
      });
    }
  });

  test('a failed connect reports the transport error to the caller', () async {
    final h = buildConnector();
    h.usb.connectError = Exception('USB permission denied');

    await expectLater(
      h.connector.connect(usbDevice),
      throwsA(
        isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('USB permission denied'),
        ),
      ),
    );
  });

  test('discovery is routed and reported per transport', () async {
    final h = buildConnector();
    h.usb.seedDiscovered([usbDevice]);

    await h.connector.startDiscovery(MeshCoreTransportKind.usb);

    expect(h.usb.discoveryStarts, 1);
    expect(h.ble.discoveryStarts, 0);
    expect(h.tcp.discoveryStarts, 0);
    expect(h.connector.discoveredDevicesFor(MeshCoreTransportKind.usb), [
      usbDevice,
    ]);
    expect(
      h.connector.discoveredDevicesFor(MeshCoreTransportKind.ble),
      isEmpty,
    );
  });

  test('stopAllDiscovery quiets every transport', () async {
    final h = buildConnector();

    await h.connector.stopAllDiscovery();

    expect(h.ble.discoveryStops, 1);
    expect(h.usb.discoveryStops, 1);
    expect(h.tcp.discoveryStops, 1);
  });

  test('dispose tears down every transport, not just the active one', () async {
    final ble = _FakeTransport(MeshCoreTransportKind.ble);
    final usb = _FakeTransport(MeshCoreTransportKind.usb);
    final tcp = _FakeTransport(MeshCoreTransportKind.tcp);
    MeshCoreConnector(
      transportOverrides: {
        MeshCoreTransportKind.ble: ble,
        MeshCoreTransportKind.usb: usb,
        MeshCoreTransportKind.tcp: tcp,
      },
    ).dispose();

    expect(ble.disposed, isTrue);
    expect(usb.disposed, isTrue);
    expect(tcp.disposed, isTrue);
  });
}

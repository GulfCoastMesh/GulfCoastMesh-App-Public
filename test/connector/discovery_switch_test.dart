import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_connector.dart';
import 'package:gulf_coast_mesh_app/storage/prefs_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fake_meshcore_transport.dart';

class _ControlledTransport extends FakeMeshCoreTransport {
  _ControlledTransport(super.kind);

  final states = StreamController<MeshCoreConnectionState>.broadcast();
  final updates = StreamController<void>.broadcast();
  final scans = <Completer<void>>[];
  Completer<void>? stopGate;
  Object? connectError;

  @override
  Stream<MeshCoreConnectionState> get stateChanges => states.stream;
  @override
  Stream<void> get discoveryUpdates => updates.stream;

  void emitState(MeshCoreConnectionState next) {
    state = next;
    states.add(next);
  }

  @override
  Future<void> startDiscovery({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final completion = Completer<void>();
    scans.add(completion);
    emitState(MeshCoreConnectionState.scanning);
    await completion.future;
  }

  @override
  Future<void> stopDiscovery() async {
    await stopGate?.future;
    if (state == MeshCoreConnectionState.scanning) {
      emitState(MeshCoreConnectionState.disconnected);
    }
  }

  @override
  Future<void> connect(
    MeshCoreDevice device, {
    bool isReconnect = false,
  }) async {
    final error = connectError;
    if (error != null) throw error;
    await super.connect(device, isReconnect: isReconnect);
    emitState(MeshCoreConnectionState.connected);
    await Future<void>.delayed(Duration.zero);
  }

  @override
  Future<void> disconnect({bool immediate = false}) async {
    await super.disconnect(immediate: immediate);
    emitState(MeshCoreConnectionState.disconnected);
  }

  @override
  void dispose() {
    unawaited(states.close());
    unawaited(updates.close());
    super.dispose();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MeshCoreConnector connector;
  late _ControlledTransport ble;
  late _ControlledTransport usb;

  Future<void> flushEvents() => Future<void>.delayed(Duration.zero);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PrefsManager.reset();
    await PrefsManager.initialize();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
          (call) async => call.method == 'readAll' ? <String, String>{} : null,
        );
    ble = _ControlledTransport(MeshCoreTransportKind.ble);
    usb = _ControlledTransport(MeshCoreTransportKind.usb);
    connector = MeshCoreConnector(
      transportOverrides: {
        MeshCoreTransportKind.ble: ble,
        MeshCoreTransportKind.usb: usb,
        MeshCoreTransportKind.tcp: _ControlledTransport(
          MeshCoreTransportKind.tcp,
        ),
      },
    );
  });

  tearDown(() async {
    connector.dispose();
    await flushEvents();
    PrefsManager.reset();
  });

  Future<void> expectBluetoothUpdates() async {
    var notifications = 0;
    void listener() => notifications++;
    connector.addListener(listener);
    ble.updates.add(null);
    await flushEvents();
    connector.removeListener(listener);
    expect(
      notifications,
      1,
      reason: 'Bluetooth discovery updates remain attached',
    );
    ble.emitState(MeshCoreConnectionState.disconnected);
    await flushEvents();
    expect(connector.state, MeshCoreConnectionState.disconnected);
  }

  test(
    'late USB discovery completion preserves active Bluetooth updates',
    () async {
      final usbScan = connector.startDiscovery(MeshCoreTransportKind.usb);
      await flushEvents();
      await connector.stopDiscovery(MeshCoreTransportKind.usb);
      final bleScan = connector.startDiscovery(MeshCoreTransportKind.ble);
      await flushEvents();
      expect(connector.state, MeshCoreConnectionState.scanning);

      usb.scans.single.complete();
      await usbScan;
      await expectBluetoothUpdates();
      ble.scans.single.complete();
      await bleScan;
    },
  );

  test(
    'stopping another transport preserves active Bluetooth updates',
    () async {
      final bleScan = connector.startDiscovery(MeshCoreTransportKind.ble);
      await flushEvents();
      await connector.stopDiscovery(MeshCoreTransportKind.usb);
      await expectBluetoothUpdates();
      ble.scans.single.complete();
      await bleScan;
    },
  );

  test(
    'old discovery completion preserves a restarted scan on the same transport',
    () async {
      final oldScan = connector.startDiscovery(MeshCoreTransportKind.ble);
      await flushEvents();
      await connector.stopDiscovery(MeshCoreTransportKind.ble);
      final newScan = connector.startDiscovery(MeshCoreTransportKind.ble);
      await flushEvents();
      ble.scans.first.complete();
      await oldScan;
      await expectBluetoothUpdates();
      ble.scans.last.complete();
      await newScan;
    },
  );

  test('late USB stop does not reset a new Bluetooth scan', () async {
    final usbScan = connector.startDiscovery(MeshCoreTransportKind.usb);
    await flushEvents();
    usb.stopGate = Completer<void>();
    final stop = connector.stopDiscovery(MeshCoreTransportKind.usb);
    final bleScan = connector.startDiscovery(MeshCoreTransportKind.ble);
    await flushEvents();
    usb.stopGate!.complete();
    await stop;
    expect(connector.state, MeshCoreConnectionState.scanning);
    usb.scans.single.complete();
    await usbScan;
    await expectBluetoothUpdates();
    ble.scans.single.complete();
    await bleScan;
  });

  const usbDevice = MeshCoreDevice(
    id: '/dev/ttyUSB0',
    displayName: 'USB radio',
    transportKind: MeshCoreTransportKind.usb,
  );
  const bleDevice = MeshCoreDevice(
    id: 'AA:BB:CC:DD:EE:FF',
    displayName: 'MeshCore-BLE',
    transportKind: MeshCoreTransportKind.ble,
  );

  for (final failFirstAttempt in [false, true]) {
    test(
      'USB disconnect permits Bluetooth connection (retry=$failFirstAttempt)',
      () async {
        await connector.connect(usbDevice);
        expect(connector.activeTransportKind, MeshCoreTransportKind.usb);
        await connector.disconnect();

        if (failFirstAttempt) {
          ble.connectError = TimeoutException('Bluetooth timed out');
          await expectLater(
            connector.connect(bleDevice),
            throwsA(isA<TimeoutException>()),
          );
          expect(connector.state, MeshCoreConnectionState.disconnected);
          ble.connectError = null;
        }
        await connector.connect(bleDevice);
        expect(connector.isConnected, isTrue);
        expect(connector.activeTransportKind, MeshCoreTransportKind.ble);
        expect(usb.state, MeshCoreConnectionState.disconnected);
        await connector.disconnect();
      },
    );
  }
}

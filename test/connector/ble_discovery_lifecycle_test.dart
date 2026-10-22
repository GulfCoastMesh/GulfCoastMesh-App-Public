import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// Exercise the installed plugin's scan and timeout behavior without hardware.
// ignore: depend_on_referenced_packages
import 'package:flutter_blue_plus_platform_interface/flutter_blue_plus_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/connector/ble_meshcore_transport.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_device.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_transport.dart';

final class _BlePlatform extends FlutterBluePlusPlatform {
  final scanResponses = StreamController<BmScanResponse>.broadcast();
  final connections = StreamController<BmConnectionStateResponse>.broadcast();
  Object? startError;
  Object? stopError;
  Object? connectError;
  int scanStarts = 0;
  int connectCalls = 0;
  Completer<void> scanStarted = Completer<void>();

  @override
  Stream<BmScanResponse> get onScanResponse => scanResponses.stream;

  @override
  Stream<BmConnectionStateResponse> get onConnectionStateChanged =>
      connections.stream;

  @override
  Future<BmBluetoothAdapterState> getAdapterState(
    BmBluetoothAdapterStateRequest request,
  ) async => BmBluetoothAdapterState(adapterState: BmAdapterStateEnum.on);

  @override
  Future<bool> startScan(BmScanSettings request) async {
    scanStarts++;
    if (!scanStarted.isCompleted) scanStarted.complete();
    final error = startError;
    startError = null;
    if (error != null) throw error;
    return true;
  }

  @override
  Future<bool> stopScan(BmStopScanRequest request) async {
    final error = stopError;
    stopError = null;
    if (error != null) throw error;
    return true;
  }

  @override
  Future<bool> connect(BmConnectRequest request) async {
    connectCalls++;
    final error = connectError;
    if (error != null) throw error;
    // No connection event unless the test injects an error above.
    return true;
  }

  @override
  Future<bool> disconnect(BmDisconnectRequest request) async {
    connections.add(
      BmConnectionStateResponse(
        remoteId: request.remoteId,
        connectionState: BmConnectionStateEnum.disconnected,
        disconnectReasonCode: 0,
        disconnectReasonString: 'disconnected',
      ),
    );
    return true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final platform = _BlePlatform();
  late BleMeshCoreTransport transport;

  setUpAll(() {
    // FlutterBluePlus initializes its platform stream listeners once.
    FlutterBluePlusPlatform.instance = platform;
  });

  setUp(() {
    platform.startError = null;
    platform.stopError = null;
    platform.connectError = null;
    platform.scanStarts = 0;
    platform.connectCalls = 0;
    platform.scanStarted = Completer<void>();
    transport = BleMeshCoreTransport();
  });

  tearDown(() async {
    debugDefaultTargetPlatformOverride = null;
    await transport.stopDiscovery();
    await transport.disconnect(immediate: true);
    transport.dispose();
  });

  test('failed scan resets state and a new scan can succeed', () async {
    platform.startError = PlatformException(
      code: 'scan',
      message: 'Bluetooth unavailable',
    );
    await expectLater(
      transport.startDiscovery(),
      throwsA(isA<PlatformException>()),
    );
    expect(transport.state, MeshCoreConnectionState.disconnected);
    expect(FlutterBluePlus.isScanningNow, isFalse);

    final retry = transport.startDiscovery();
    await Future<void>.delayed(Duration.zero);
    expect(platform.scanStarts, 2);
    expect(transport.state, MeshCoreConnectionState.scanning);
    expect(FlutterBluePlus.isScanningNow, isTrue);
    await transport.stopDiscovery();
    await retry;
    expect(transport.state, MeshCoreConnectionState.disconnected);
  });

  test(
    'asynchronous scan failure is returned and leaves scan retryable',
    () async {
      final scan = transport.startDiscovery();
      final failure = expectLater(
        scan,
        throwsA(isA<FlutterBluePlusException>()),
      );
      await Future<void>.delayed(Duration.zero);
      platform.scanResponses.add(
        BmScanResponse(
          advertisements: [],
          success: false,
          errorCode: 6,
          errorString: 'scan failed',
        ),
      );
      await Future<void>.delayed(Duration.zero);
      await failure;
      expect(transport.state, MeshCoreConnectionState.disconnected);
      expect(FlutterBluePlus.isScanningNow, isFalse);
    },
  );

  test(
    'failed scan stop still clears state and permits another scan',
    () async {
      final scan = transport.startDiscovery();
      await Future<void>.delayed(Duration.zero);
      platform.stopError = PlatformException(code: 'stopScan');
      await expectLater(
        transport.stopDiscovery(),
        throwsA(isA<PlatformException>()),
      );
      await scan;
      expect(transport.state, MeshCoreConnectionState.disconnected);

      final retry = transport.startDiscovery();
      await Future<void>.delayed(Duration.zero);
      expect(platform.scanStarts, 2);
      expect(FlutterBluePlus.isScanningNow, isTrue);
      await transport.stopDiscovery();
      await retry;
    },
  );

  test(
    'disposing an unused BLE transport leaves the active scan running',
    () async {
      final scan = transport.startDiscovery();
      await Future<void>.delayed(Duration.zero);
      final unused = BleMeshCoreTransport();
      unused.dispose();
      await Future<void>.delayed(Duration.zero);
      expect(FlutterBluePlus.isScanningNow, isTrue);
      expect(transport.state, MeshCoreConnectionState.scanning);
      await transport.stopDiscovery();
      await scan;
    },
  );

  test(
    'canceled adapter delay cannot start or stop a replacement scan',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      final first = transport.startDiscovery();
      await Future<void>.delayed(Duration.zero);
      expect(platform.scanStarts, 0);
      await transport.stopDiscovery();

      final second = transport.startDiscovery();
      await first;
      await platform.scanStarted.future;
      expect(platform.scanStarts, 1);
      expect(transport.state, MeshCoreConnectionState.scanning);
      expect(FlutterBluePlus.isScanningNow, isTrue);
      await transport.stopDiscovery();
      await second;
      expect(transport.state, MeshCoreConnectionState.disconnected);
    },
  );

  const device = MeshCoreDevice(
    id: 'AA:BB:CC:DD:EE:FF',
    displayName: 'MeshCore-Test',
    transportKind: MeshCoreTransportKind.ble,
  );

  test(
    'plugin connection timeouts retry then return a recoverable error',
    () async {
      platform.connectError = FlutterBluePlusException(
        ErrorPlatform.fbp,
        'connect',
        FbpErrorCode.timeout.index,
        'Timed out after 12s',
      );
      final connection = transport.connect(device);
      final failure = expectLater(
        connection,
        throwsA(
          isA<FlutterBluePlusException>().having(
            (error) => error.code,
            'code',
            FbpErrorCode.timeout.index,
          ),
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(platform.connectCalls, 1);

      await failure;
      expect(platform.connectCalls, BleMeshCoreTransport.connectRetryCount);
      expect(transport.state, MeshCoreConnectionState.disconnected);
    },
  );

  test(
    'nonretryable connection errors return without repeated attempts',
    () async {
      platform.connectError = FlutterBluePlusException(
        ErrorPlatform.fbp,
        'connect',
        FbpErrorCode.adapterIsOff.index,
        'Bluetooth adapter is off',
      );
      await expectLater(
        transport.connect(device),
        throwsA(isA<FlutterBluePlusException>()),
      );
      expect(platform.connectCalls, 1);
      expect(transport.state, MeshCoreConnectionState.disconnected);
    },
  );
}

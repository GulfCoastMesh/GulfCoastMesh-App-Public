import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../helpers/ble_reliability.dart';
import '../helpers/transport_reliability.dart';
import 'meshcore_device.dart';
import 'meshcore_transport.dart';

class MeshCoreUuids {
  static const String service = "6e400001-b5a3-f393-e0a9-e50e24dcca9e";
  static const String rxCharacteristic = "6e400002-b5a3-f393-e0a9-e50e24dcca9e";
  static const String txCharacteristic = "6e400003-b5a3-f393-e0a9-e50e24dcca9e";
}

class BleMeshCoreTransport implements MeshCoreTransport {
  static const int requestedMtu = 185;
  static const int notifyRetryCount = 3;
  static const int notifyRetryBackoffMs = 500;

  /// First attempt budget; retries keep the same timeout (timeout/133 only).
  static const Duration connectionTimeout = Duration(seconds: 12);
  static const int connectRetryCount = 3;
  static const Duration connectRetryDelay = Duration(seconds: 1);
  static const Duration adapterReadyDelay = Duration(milliseconds: 300);
  static const Duration adapterWaitTimeout = Duration(seconds: 5);
  static const Duration rediscoveryScanTimeout = Duration(seconds: 4);

  MeshCoreConnectionState _state = MeshCoreConnectionState.disconnected;
  final StreamController<MeshCoreConnectionState> _stateController =
      StreamController<MeshCoreConnectionState>.broadcast();
  final StreamController<Uint8List> _incomingFramesController =
      StreamController<Uint8List>.broadcast();
  final StreamController<void> _discoveryUpdatesController =
      StreamController<void>.broadcast();

  BluetoothDevice? _device;
  BluetoothCharacteristic? _rxCharacteristic;
  BluetoothCharacteristic? _txCharacteristic;
  int _attMtu = defaultAttMtu;
  int _sessionGeneration = 0;
  int _discoveryGeneration = 0;
  Completer<void>? _disconnectCompleter;
  final List<MeshCoreDevice> _discoveredDevices = [];
  final Map<String, ScanResult> _scanResultsById = {};

  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
  StreamSubscription<List<int>>? _notifySubscription;
  StreamSubscription<BluetoothAdapterState>? _adapterSubscription;

  @override
  MeshCoreTransportKind get kind => MeshCoreTransportKind.ble;

  @override
  MeshCoreConnectionState get state => _state;

  @override
  Stream<MeshCoreConnectionState> get stateChanges => _stateController.stream;

  @override
  Stream<Uint8List> get incomingFrames => _incomingFramesController.stream;

  @override
  Stream<void> get discoveryUpdates => _discoveryUpdatesController.stream;

  @override
  List<MeshCoreDevice> get discoveredDevices =>
      List.unmodifiable(_discoveredDevices);

  /// Negotiated ATT MTU for the active connection (23 if unknown).
  int get attMtu => _attMtu;

  /// Test/debug: current GATT session generation.
  int get sessionGeneration => _sessionGeneration;

  void _setState(MeshCoreConnectionState newState) {
    if (_state == newState || _stateController.isClosed) return;
    _state = newState;
    _stateController.add(newState);
  }

  @override
  Future<void> startDiscovery({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    if (_state != MeshCoreConnectionState.disconnected) return;

    final generation = ++_discoveryGeneration;
    _discoveredDevices.clear();
    _scanResultsById.clear();
    _setState(MeshCoreConnectionState.scanning);

    Object? discoveryError;
    try {
      await FlutterBluePlus.stopScan();
      if (generation != _discoveryGeneration) return;

      if (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS) {
        final adapterState = await FlutterBluePlus.adapterState.first;
        if (generation != _discoveryGeneration) return;
        if (adapterState != BluetoothAdapterState.on) {
          await FlutterBluePlus.adapterState
              .firstWhere((state) => state == BluetoothAdapterState.on)
              .timeout(
                adapterWaitTimeout,
                onTimeout: () {
                  throw Exception('Bluetooth adapter not available');
                },
              );
          if (generation != _discoveryGeneration) return;
        }
        await Future.delayed(adapterReadyDelay);
        if (generation != _discoveryGeneration) return;
      }

      final scanFailed = Completer<void>();
      Object? scanError;
      StackTrace? scanStack;
      _scanSubscription = FlutterBluePlus.scanResults.listen(
        (results) {
          if (generation != _discoveryGeneration) return;
          _discoveredDevices.clear();
          _scanResultsById.clear();
          for (final result in results) {
            if (!_isMeshCoreDevice(result)) continue;
            final id = result.device.remoteId.toString();
            final name = result.device.platformName.isNotEmpty
                ? result.device.platformName
                : result.advertisementData.advName;
            _scanResultsById[id] = result;
            _discoveredDevices.add(
              MeshCoreDevice(
                id: id,
                displayName: name.isNotEmpty ? name : id,
                transportKind: MeshCoreTransportKind.ble,
                rssi: result.rssi,
                subtitle: id,
              ),
            );
          }
          if (!_discoveryUpdatesController.isClosed) {
            _discoveryUpdatesController.add(null);
          }
        },
        onError: (Object error, StackTrace stack) {
          if (generation != _discoveryGeneration) return;
          scanError = error;
          scanStack = stack;
          if (!scanFailed.isCompleted) scanFailed.complete();
        },
      );

      await FlutterBluePlus.startScan(
        timeout: timeout,
        androidScanMode: AndroidScanMode.lowLatency,
        // Manifest uses neverForLocation; don't require Location services on.
        androidCheckLocationServices: false,
      );
      if (generation != _discoveryGeneration) return;

      await Future.any([
        FlutterBluePlus.isScanning.where((scanning) => !scanning).first,
        scanFailed.future,
      ]);
      if (scanError != null) {
        Error.throwWithStackTrace(scanError!, scanStack!);
      }
    } catch (error) {
      discoveryError = error;
      // A canceled scan must not report a late failure for its replacement.
      if (generation == _discoveryGeneration) rethrow;
    } finally {
      // An older scan finishing must not stop a newer scan or its subscription.
      if (generation == _discoveryGeneration) {
        try {
          await stopDiscovery();
        } catch (error) {
          if (discoveryError == null) rethrow;
          debugPrint('BLE scan cleanup failed: $error');
        }
      }
    }
  }

  bool _isMeshCoreDevice(ScanResult result) {
    return result.device.platformName.startsWith('MeshCore-') ||
        result.advertisementData.advName.startsWith('MeshCore-') ||
        result.advertisementData.advName.startsWith('Whisper-');
  }

  bool get _needsRediscoveryScan =>
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  Future<void> _shortRediscoveryScan() async {
    try {
      await FlutterBluePlus.stopScan();
      final sub = FlutterBluePlus.scanResults.listen((results) {
        for (final result in results) {
          if (!_isMeshCoreDevice(result)) continue;
          _scanResultsById[result.device.remoteId.toString()] = result;
        }
      });
      try {
        await FlutterBluePlus.startScan(
          timeout: rediscoveryScanTimeout,
          androidScanMode: AndroidScanMode.lowLatency,
          androidCheckLocationServices: false,
        );
        await FlutterBluePlus.isScanning.where((scanning) => !scanning).first;
      } finally {
        await sub.cancel();
        await FlutterBluePlus.stopScan();
      }
    } catch (e) {
      debugPrint('BLE rediscovery scan failed: $e');
    }
  }

  @override
  Future<void> stopDiscovery() async {
    ++_discoveryGeneration;
    final subscription = _scanSubscription;
    final hadDiscovery =
        _state == MeshCoreConnectionState.scanning || subscription != null;
    _scanSubscription = null;
    if (_state == MeshCoreConnectionState.scanning) {
      _setState(MeshCoreConnectionState.disconnected);
    }
    try {
      if (hadDiscovery) await FlutterBluePlus.stopScan();
    } finally {
      await subscription?.cancel();
    }
  }

  @override
  Future<void> connect(
    MeshCoreDevice device, {
    bool isReconnect = false,
  }) async {
    if (device.transportKind != MeshCoreTransportKind.ble) {
      throw ArgumentError('BleMeshCoreTransport cannot connect to USB device');
    }
    if (_state == MeshCoreConnectionState.connecting ||
        _state == MeshCoreConnectionState.connected) {
      throw StateError('BLE transport connect() called while ${_state.name}');
    }

    await stopDiscovery();
    final generation = ++_sessionGeneration;
    _setState(MeshCoreConnectionState.connecting);
    _attMtu = defaultAttMtu;

    if (isReconnect && _needsRediscoveryScan) {
      await _shortRediscoveryScan();
    }

    final scanResult = _scanResultsById[device.id];
    final bleDevice = scanResult?.device ?? BluetoothDevice.fromId(device.id);
    _device = bleDevice;

    try {
      await _adapterSubscription?.cancel();
      _adapterSubscription = FlutterBluePlus.adapterState.listen((state) {
        if (!isFatalBluetoothAdapterStateName(state.name)) return;
        if (!canApplyDisconnectTeardown(
          disconnectGeneration: generation,
          currentGeneration: _sessionGeneration,
        )) {
          return;
        }
        if (_state == MeshCoreConnectionState.connected ||
            _state == MeshCoreConnectionState.connecting) {
          unawaited(disconnect(immediate: true));
        }
      });

      var gattUp = false;
      await _connectionSubscription?.cancel();
      _connectionSubscription = bleDevice.connectionState.listen((state) {
        if (state != BluetoothConnectionState.disconnected) return;
        if (!canApplyDisconnectTeardown(
          disconnectGeneration: generation,
          currentGeneration: _sessionGeneration,
        )) {
          return;
        }
        if (_state == MeshCoreConnectionState.connected ||
            (_state == MeshCoreConnectionState.connecting && gattUp)) {
          unawaited(disconnect(immediate: true));
        }
      });

      Object? lastError;
      for (var attempt = 0; attempt < connectRetryCount; attempt++) {
        if (generation != _sessionGeneration) {
          throw StateError('BLE connect aborted by newer session');
        }
        try {
          if (attempt > 0) {
            debugPrint('BLE connect retry ${attempt + 1}/$connectRetryCount');
            try {
              await bleDevice.disconnect(queue: false, androidDelay: 0);
            } catch (_) {}
            await Future.delayed(connectRetryDelay * attempt);
          }
          await bleDevice.connect(
            timeout: connectionTimeout,
            mtu: null,
            license: License.free,
          );
          lastError = null;
          break;
        } catch (e) {
          lastError = e;
          final retryable =
              e is FlutterBluePlusException &&
              ((e.platform == ErrorPlatform.fbp &&
                      e.code == FbpErrorCode.timeout.index) ||
                  (e.platform == ErrorPlatform.android && e.code == 133));
          if (!retryable) {
            rethrow;
          }
          debugPrint('BLE connect attempt ${attempt + 1} failed: $e');
          if (attempt == connectRetryCount - 1) rethrow;
        }
      }
      if (lastError != null) {
        throw lastError;
      }
      gattUp = true;

      int? requested;
      try {
        requested = await bleDevice.requestMtu(requestedMtu);
        debugPrint('MTU request returned: $requested');
      } catch (e) {
        debugPrint('MTU request failed: $e, mtuNow=${bleDevice.mtuNow}');
      }
      _attMtu = await resolveAttMtu(
        requestedMtu: requested,
        mtuNow: bleDevice.mtuNow,
        waitForNegotiated: (timeout) => bleDevice.mtu
            .firstWhere(isAttMtuCompatibleWithMeshCore)
            // Fall back to the *live* value: negotiation may have finished
            // after the wait started without emitting a compatible event.
            .timeout(timeout, onTimeout: () => bleDevice.mtuNow),
      );
      debugPrint('MTU resolved to: $_attMtu');

      if (!isAttMtuCompatibleWithMeshCore(_attMtu)) {
        throw Exception(
          'BLE ATT MTU $_attMtu is too small for MeshCore frames '
          '(need >= $minCompatibleMeshCoreAttMtu). '
          'Try reconnecting closer to the device.',
        );
      }
      if (isAttMtuCompatibilityMode(_attMtu)) {
        debugPrint(
          'BLE ATT MTU $_attMtu compatibility mode: outgoing frames are '
          'limited to ${attPayloadBudget(_attMtu)} bytes; rare larger incoming '
          'frames cannot be received intact.',
        );
      }

      if (defaultTargetPlatform == TargetPlatform.android) {
        try {
          await bleDevice.requestConnectionPriority(
            connectionPriorityRequest: ConnectionPriority.high,
          );
        } catch (e) {
          debugPrint('requestConnectionPriority failed: $e');
        }
      }

      if (generation != _sessionGeneration) {
        throw StateError('BLE connect aborted by newer session');
      }

      final services = await bleDevice.discoverServices();
      BluetoothService? uartService;
      for (final service in services) {
        if (service.uuid.toString().toLowerCase() == MeshCoreUuids.service) {
          uartService = service;
          break;
        }
      }

      if (uartService == null) {
        throw Exception('MeshCore UART service not found');
      }

      for (final characteristic in uartService.characteristics) {
        final uuid = characteristic.uuid.toString().toLowerCase();
        if (uuid == MeshCoreUuids.rxCharacteristic) {
          _rxCharacteristic = characteristic;
        } else if (uuid == MeshCoreUuids.txCharacteristic) {
          _txCharacteristic = characteristic;
        }
      }

      if (_rxCharacteristic == null || _txCharacteristic == null) {
        throw Exception('MeshCore characteristics not found');
      }

      await _notifySubscription?.cancel();
      _notifySubscription = _txCharacteristic!.onValueReceived.listen((data) {
        if (data.isEmpty || _incomingFramesController.isClosed) return;
        _incomingFramesController.add(Uint8List.fromList(data));
      });

      var notifySet = false;
      for (
        var attempt = 0;
        attempt < notifyRetryCount && !notifySet;
        attempt++
      ) {
        try {
          if (attempt > 0) {
            await Future.delayed(
              Duration(milliseconds: notifyRetryBackoffMs * attempt),
            );
          }
          await _txCharacteristic!.setNotifyValue(true);
          notifySet = true;
        } catch (e) {
          debugPrint(
            'setNotifyValue attempt ${attempt + 1}/$notifyRetryCount failed: $e',
          );
          if (attempt == notifyRetryCount - 1) rethrow;
        }
      }

      if (generation != _sessionGeneration) {
        throw StateError('BLE connect aborted by newer session');
      }

      _setState(MeshCoreConnectionState.connected);
    } catch (e) {
      debugPrint('BLE connection error: $e');
      if (generation == _sessionGeneration) {
        await disconnect(immediate: true);
      }
      rethrow;
    }
  }

  @override
  Future<void> disconnect({bool immediate = false}) async {
    // flutter_blue_plus wants a settle delay on Android before the GATT
    // handle is reused; skip it when the caller needs the socket back now.
    final androidDelay = immediate ? 0 : 2000;
    if (_state == MeshCoreConnectionState.disconnected &&
        _device == null &&
        _disconnectCompleter == null) {
      return;
    }
    final inFlight = _disconnectCompleter;
    if (inFlight != null) {
      return inFlight.future;
    }

    final generation = _sessionGeneration;
    final completer = Completer<void>();
    _disconnectCompleter = completer;
    if (_state != MeshCoreConnectionState.disconnecting) {
      _setState(MeshCoreConnectionState.disconnecting);
    }

    try {
      await _notifySubscription?.cancel();
      _notifySubscription = null;
      await _connectionSubscription?.cancel();
      _connectionSubscription = null;
      await _adapterSubscription?.cancel();
      _adapterSubscription = null;

      try {
        await _device?.disconnect(queue: false, androidDelay: androidDelay);
      } catch (e) {
        debugPrint('BLE disconnect error: $e');
      }

      if (!canApplyDisconnectTeardown(
        disconnectGeneration: generation,
        currentGeneration: _sessionGeneration,
      )) {
        return;
      }

      _device = null;
      _rxCharacteristic = null;
      _txCharacteristic = null;
      _attMtu = defaultAttMtu;
      _setState(MeshCoreConnectionState.disconnected);
    } finally {
      if (!completer.isCompleted) completer.complete();
      if (identical(_disconnectCompleter, completer)) {
        _disconnectCompleter = null;
      }
    }
  }

  @override
  Future<void> sendFrame(Uint8List data) async {
    if (_state != MeshCoreConnectionState.connected ||
        _rxCharacteristic == null) {
      throw Exception('Not connected to a MeshCore device');
    }

    final properties = _rxCharacteristic!.properties;
    final withoutResponse = shouldWriteWithoutResponse(
      payloadLength: data.length,
      attMtu: _attMtu,
      canWriteWithResponse: properties.write,
      canWriteWithoutResponse: properties.writeWithoutResponse,
    );

    final command = data.isEmpty
        ? 'empty frame'
        : 'command 0x${data.first.toRadixString(16).padLeft(2, '0')}';
    await awaitBleWrite<void>(
      frameDescription: 'MeshCore $command (${data.length} bytes)',
      write: () => _rxCharacteristic!.write(
        data.toList(),
        withoutResponse: withoutResponse,
      ),
    );
  }

  @override
  void dispose() {
    unawaited(
      stopDiscovery().catchError((Object error) {
        debugPrint('BLE scan cleanup failed: $error');
      }),
    );
    unawaited(disconnect(immediate: true));
    unawaited(_stateController.close());
    unawaited(_incomingFramesController.close());
    unawaited(_discoveryUpdatesController.close());
  }
}

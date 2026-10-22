import 'dart:async';
import 'dart:typed_data';

import 'byte_stream_connection.dart';
import 'meshcore_device.dart';
import 'meshcore_transport.dart';
import 'serial_frame_codec.dart';

/// Shared machinery for every transport that speaks MeshCore over a raw byte
/// stream — USB/OS serial and TCP.
///
/// The wire protocol is identical across them (see [SerialFrameCodec]); only
/// device enumeration and opening the stream differ, which is all a subclass
/// has to provide.
abstract class ByteStreamMeshCoreTransport implements MeshCoreTransport {
  final SerialFrameCodec _codec = SerialFrameCodec();

  MeshCoreConnectionState _state = MeshCoreConnectionState.disconnected;
  final StreamController<MeshCoreConnectionState> _stateController =
      StreamController<MeshCoreConnectionState>.broadcast();
  final StreamController<Uint8List> _incomingFramesController =
      StreamController<Uint8List>.broadcast();
  final StreamController<void> _discoveryUpdatesController =
      StreamController<void>.broadcast();

  final List<MeshCoreDevice> _discoveredDevices = [];
  ByteStreamConnection? _connection;
  StreamSubscription<Uint8List>? _inputSubscription;
  Future<void> _writeChain = Future<void>.value();

  /// Guards against a teardown from a stale session (a late `onDone` from a
  /// stream we already replaced) tearing down the current one.
  int _sessionGeneration = 0;
  int _discoveryGeneration = 0;

  /// Enumerate reachable companions. Transports without real discovery (TCP)
  /// may return an empty list.
  Future<List<MeshCoreDevice>> discoverDevices();

  /// Open a byte stream to [device]. Throw with an actionable message on
  /// failure — the text surfaces to the user as the connect error.
  Future<ByteStreamConnection> openConnection(MeshCoreDevice device);

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

  void _setState(MeshCoreConnectionState newState) {
    if (_state == newState || _stateController.isClosed) return;
    _state = newState;
    _stateController.add(newState);
  }

  void _notifyDiscoveryUpdate() {
    if (!_discoveryUpdatesController.isClosed) {
      _discoveryUpdatesController.add(null);
    }
  }

  @override
  Future<void> startDiscovery({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    // Enumeration is a point-in-time listing rather than a running scan, so a
    // connected session must not be interrupted to refresh it.
    if (_discoveryUpdatesController.isClosed ||
        _state == MeshCoreConnectionState.scanning ||
        _state == MeshCoreConnectionState.connected ||
        _state == MeshCoreConnectionState.connecting) {
      return;
    }

    final generation = ++_discoveryGeneration;
    _discoveredDevices.clear();
    _notifyDiscoveryUpdate();
    _setState(MeshCoreConnectionState.scanning);

    try {
      final devices = await discoverDevices().timeout(timeout);
      if (generation != _discoveryGeneration) return;
      _discoveredDevices.addAll(devices);
    } catch (_) {
      // A stopped enumeration must not report a late error for its replacement.
      if (generation == _discoveryGeneration) rethrow;
    } finally {
      if (generation == _discoveryGeneration) {
        _notifyDiscoveryUpdate();
        // Enumeration is instantaneous; there is no scan left running to stop.
        if (_state == MeshCoreConnectionState.scanning) {
          _setState(MeshCoreConnectionState.disconnected);
        }
      }
    }
  }

  @override
  Future<void> stopDiscovery() async {
    _discoveryGeneration++;
    if (_state == MeshCoreConnectionState.scanning) {
      _setState(MeshCoreConnectionState.disconnected);
    }
  }

  @override
  Future<void> connect(
    MeshCoreDevice device, {
    bool isReconnect = false,
  }) async {
    if (device.transportKind != kind) {
      throw ArgumentError(
        '$runtimeType cannot connect to a ${device.transportKind.name} device',
      );
    }
    if (_state == MeshCoreConnectionState.connecting ||
        _state == MeshCoreConnectionState.connected) {
      return;
    }

    await stopDiscovery();
    _setState(MeshCoreConnectionState.connecting);
    _codec.reset();
    final generation = ++_sessionGeneration;

    try {
      final connection = await openConnection(device);
      if (generation != _sessionGeneration) {
        // A newer connect (or a disconnect) landed while we were opening.
        await connection.close();
        return;
      }
      _connection = connection;
      _inputSubscription = connection.input.listen(
        (chunk) {
          if (generation != _sessionGeneration) return;
          for (final frame in _codec.feed(chunk)) {
            if (!_incomingFramesController.isClosed) {
              _incomingFramesController.add(frame);
            }
          }
        },
        onError: (Object error) => _handleStreamLoss(generation),
        onDone: () => _handleStreamLoss(generation),
      );
      _setState(MeshCoreConnectionState.connected);
    } catch (_) {
      if (generation == _sessionGeneration) {
        await disconnect(immediate: true);
      }
      rethrow;
    }
  }

  /// The far end went away on its own — cable pulled, socket reset, companion
  /// rebooted. Drop to disconnected so the connector's reconnect policy runs.
  void _handleStreamLoss(int generation) {
    if (generation != _sessionGeneration) return;
    if (_state == MeshCoreConnectionState.connected ||
        _state == MeshCoreConnectionState.connecting) {
      unawaited(disconnect(immediate: true));
    }
  }

  @override
  Future<void> disconnect({bool immediate = false}) async {
    if (_state == MeshCoreConnectionState.disconnected && _connection == null) {
      return;
    }
    _sessionGeneration++;
    _setState(MeshCoreConnectionState.disconnecting);

    await _inputSubscription?.cancel();
    _inputSubscription = null;
    _codec.reset();
    _writeChain = Future<void>.value();

    final connection = _connection;
    _connection = null;
    if (connection != null) {
      try {
        await connection.close();
      } catch (_) {
        // Already gone; nothing useful left to do.
      }
    }

    _setState(MeshCoreConnectionState.disconnected);
  }

  @override
  Future<void> sendFrame(Uint8List data) async {
    final connection = _connection;
    if (_state != MeshCoreConnectionState.connected || connection == null) {
      throw StateError('Not connected to a MeshCore device');
    }

    final framed = _codec.encodeOutbound(data);
    // Serialize writes: a byte stream has no framing of its own, so two
    // concurrent writes could interleave and corrupt both frames.
    final writeFuture = _writeChain.then((_) => connection.write(framed));
    _writeChain = writeFuture.catchError((Object _) {});
    await writeFuture;
  }

  @override
  void dispose() {
    _discoveryGeneration++;
    unawaited(disconnect(immediate: true));
    unawaited(_stateController.close());
    unawaited(_incomingFramesController.close());
    unawaited(_discoveryUpdatesController.close());
  }
}

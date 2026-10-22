import 'dart:async';
import 'dart:typed_data';

import 'package:gulf_coast_mesh_app/connector/meshcore_connector.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_protocol.dart';

/// Connects without hardware and allows replies while a write is still pending.
class FakeMeshCoreTransport implements MeshCoreTransport {
  FakeMeshCoreTransport(this.kind);

  @override
  final MeshCoreTransportKind kind;
  @override
  MeshCoreConnectionState state = MeshCoreConnectionState.disconnected;
  final _frames = StreamController<Uint8List>.broadcast();
  final _states = StreamController<MeshCoreConnectionState>.broadcast();
  final sentFrames = <Uint8List>[];
  Future<void> Function(Uint8List frame)? onSend;

  void receive(List<int> frame) => _frames.add(Uint8List.fromList(frame));

  @override
  Stream<Uint8List> get incomingFrames => _frames.stream;
  @override
  Stream<MeshCoreConnectionState> get stateChanges => _states.stream;
  @override
  Stream<void> get discoveryUpdates => const Stream.empty();
  @override
  List<MeshCoreDevice> get discoveredDevices => const [];
  @override
  Future<void> startDiscovery({
    Duration timeout = const Duration(seconds: 10),
  }) async {}
  @override
  Future<void> stopDiscovery() async {}

  @override
  Future<void> connect(
    MeshCoreDevice device, {
    bool isReconnect = false,
  }) async {
    state = MeshCoreConnectionState.connected;
    _states.add(state);
    await Future<void>.delayed(Duration.zero);
  }

  @override
  Future<void> disconnect({bool immediate = false}) async {
    state = MeshCoreConnectionState.disconnected;
    _states.add(state);
  }

  @override
  Future<void> sendFrame(Uint8List data) async {
    sentFrames.add(Uint8List.fromList(data));
    if (data[0] == cmdAppStart) {
      receive([respCodeSelfInfo, 1, 20, 22, ...List.filled(32, 9)]);
    }
    await onSend?.call(data);
    await Future<void>.delayed(Duration.zero);
  }

  @override
  void dispose() {
    unawaited(_frames.close());
    unawaited(_states.close());
  }
}

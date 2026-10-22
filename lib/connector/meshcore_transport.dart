import 'dart:async';
import 'dart:typed_data';

import 'meshcore_device.dart';

enum MeshCoreConnectionState {
  disconnected,
  scanning,
  connecting,
  connected,
  disconnecting,
}

abstract class MeshCoreTransport {
  MeshCoreTransportKind get kind;

  MeshCoreConnectionState get state;

  Stream<MeshCoreConnectionState> get stateChanges;

  Stream<Uint8List> get incomingFrames;

  /// Fires when [discoveredDevices] changes during an active discovery session.
  Stream<void> get discoveryUpdates;

  Future<void> startDiscovery({Duration timeout = const Duration(seconds: 10)});

  Future<void> stopDiscovery();

  List<MeshCoreDevice> get discoveredDevices;

  Future<void> connect(MeshCoreDevice device, {bool isReconnect = false});

  /// Tears the link down. [immediate] asks for the fastest possible teardown
  /// (a failed connect, or a reconnect about to follow) at the cost of
  /// whatever settling the transport would normally do — BLE on Android, for
  /// instance, otherwise waits for the GATT stack before returning.
  Future<void> disconnect({bool immediate = false});

  Future<void> sendFrame(Uint8List data);

  void dispose();
}

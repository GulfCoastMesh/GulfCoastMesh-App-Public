import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'byte_stream_connection.dart';
import 'meshcore_device.dart';
import 'tcp_meshcore_transport.dart';

/// How long to wait for the TCP handshake before giving up. A wrong or stale
/// address otherwise sits in SYN retransmit for over a minute on some
/// platforms, which reads as a hang.
const Duration tcpConnectTimeout = Duration(seconds: 8);

class TcpBackend {
  Future<ByteStreamConnection> connect(MeshCoreDevice device) async {
    final endpoint = parseTcpEndpoint(device.id);
    if (endpoint == null) {
      throw Exception(
        'Invalid address "${device.id}" — expected host or host:port',
      );
    }

    final Socket socket;
    try {
      socket = await Socket.connect(
        endpoint.host,
        endpoint.port,
        timeout: tcpConnectTimeout,
      );
    } on SocketException catch (e) {
      // osError carries the useful part ("Connection refused", "No route to
      // host"); the wrapper's toString is mostly noise.
      final reason = e.osError?.message ?? e.message;
      throw Exception(
        'Could not reach ${endpoint.host}:${endpoint.port} — $reason',
      );
    } on TimeoutException {
      throw Exception(
        'Timed out connecting to ${endpoint.host}:${endpoint.port}',
      );
    }

    // Frames are small and latency-sensitive; Nagle would coalesce them.
    socket.setOption(SocketOption.tcpNoDelay, true);

    final controller = StreamController<Uint8List>();
    final subscription = socket.listen(
      (data) {
        if (data.isNotEmpty && !controller.isClosed) controller.add(data);
      },
      onError: (Object error, StackTrace stack) {
        if (!controller.isClosed) controller.addError(error, stack);
      },
      onDone: () => unawaited(controller.close()),
    );

    return ByteStreamConnection(
      input: controller.stream,
      write: (data) async {
        socket.add(data);
        await socket.flush();
      },
      close: () async {
        await subscription.cancel();
        try {
          await socket.close();
        } finally {
          socket.destroy();
        }
        if (!controller.isClosed) await controller.close();
      },
    );
  }
}

import 'byte_stream_connection.dart';
import 'meshcore_device.dart';

/// Web fallback: browsers cannot open raw TCP sockets.
class TcpBackend {
  Future<ByteStreamConnection> connect(MeshCoreDevice device) {
    throw UnsupportedError(
      'TCP connections are not supported on this platform',
    );
  }
}

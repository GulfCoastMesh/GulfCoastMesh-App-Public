import 'byte_stream_connection.dart';
import 'meshcore_device.dart';

/// Web fallback: there is no USB serial access, so nothing is ever listed and
/// connecting is a hard error rather than a silent no-op.
class UsbSerialBackend {
  Future<List<MeshCoreDevice>> listDevices() async => [];

  Future<ByteStreamConnection> connect(MeshCoreDevice device) {
    throw UnsupportedError('USB serial is not supported on this platform');
  }
}

import 'byte_stream_connection.dart';
import 'byte_stream_meshcore_transport.dart';
import 'meshcore_device.dart';
import 'usb_serial_transport_io.dart'
    if (dart.library.js_interop) 'usb_serial_transport_stub.dart';

/// MeshCore over USB OTG (Android) or an OS serial port (desktop).
///
/// All the protocol work lives in [ByteStreamMeshCoreTransport]; this only
/// knows how to find ports and open one.
class UsbSerialMeshCoreTransport extends ByteStreamMeshCoreTransport {
  final UsbSerialBackend _backend = UsbSerialBackend();

  @override
  MeshCoreTransportKind get kind => MeshCoreTransportKind.usb;

  @override
  Future<List<MeshCoreDevice>> discoverDevices() => _backend.listDevices();

  @override
  Future<ByteStreamConnection> openConnection(MeshCoreDevice device) =>
      _backend.connect(device);
}

import 'byte_stream_connection.dart';
import 'byte_stream_meshcore_transport.dart';
import 'meshcore_device.dart';
import 'tcp_transport_io.dart'
    if (dart.library.js_interop) 'tcp_transport_stub.dart';

/// Default companion TCP port for WiFi-capable MeshCore firmware.
const int defaultMeshCoreTcpPort = 5000;

/// MeshCore over TCP/IP.
///
/// The wire protocol is byte-for-byte the same as USB serial, so everything is
/// inherited; only opening the socket differs.
///
/// There is no discovery: an endpoint is typed in or recalled from a saved
/// profile, so [discoverDevices] always returns empty and the scanner shows
/// saved TCP profiles instead.
class TcpMeshCoreTransport extends ByteStreamMeshCoreTransport {
  final TcpBackend _backend = TcpBackend();

  @override
  MeshCoreTransportKind get kind => MeshCoreTransportKind.tcp;

  @override
  Future<List<MeshCoreDevice>> discoverDevices() async => [];

  @override
  Future<ByteStreamConnection> openConnection(MeshCoreDevice device) =>
      _backend.connect(device);
}

/// Splits a `host`, `host:port`, or bracketed IPv6 `[::1]:port` endpoint.
///
/// Returns null when [address] is unusable, so callers can report a bad
/// profile rather than dialing something nonsensical.
({String host, int port})? parseTcpEndpoint(String address) {
  final trimmed = address.trim();
  if (trimmed.isEmpty) return null;

  // Bracketed IPv6, optionally with a port: [::1] or [::1]:5000
  if (trimmed.startsWith('[')) {
    final end = trimmed.indexOf(']');
    if (end <= 1) return null;
    final host = trimmed.substring(1, end);
    final rest = trimmed.substring(end + 1);
    if (rest.isEmpty) return (host: host, port: defaultMeshCoreTcpPort);
    if (!rest.startsWith(':')) return null;
    final port = int.tryParse(rest.substring(1));
    if (port == null || port < 1 || port > 65535) return null;
    return (host: host, port: port);
  }

  // A bare IPv6 literal has several colons and no port; anything with exactly
  // one colon is host:port.
  final colon = trimmed.lastIndexOf(':');
  if (colon == -1 || trimmed.indexOf(':') != colon) {
    return (host: trimmed, port: defaultMeshCoreTcpPort);
  }

  final host = trimmed.substring(0, colon);
  if (host.isEmpty) return null;
  final port = int.tryParse(trimmed.substring(colon + 1));
  if (port == null || port < 1 || port > 65535) return null;
  return (host: host, port: port);
}

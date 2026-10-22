import 'dart:async';
import 'dart:typed_data';

/// An open bidirectional byte stream to a MeshCore companion.
///
/// Deliberately transport-agnostic: a USB serial port, an OS serial port, and a
/// TCP socket all reduce to the same read/write/close triple, so
/// [SerialFrameCodec] and the transports above it work identically over any of
/// them. [input] delivers raw bytes with no frame boundaries — the codec, not
/// the caller, is responsible for reassembly.
class ByteStreamConnection {
  final Stream<Uint8List> input;
  final Future<void> Function(Uint8List data) write;
  final Future<void> Function() close;

  ByteStreamConnection({
    required this.input,
    required this.write,
    required this.close,
  });
}

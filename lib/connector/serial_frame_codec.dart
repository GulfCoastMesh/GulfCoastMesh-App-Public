import 'dart:typed_data';

import 'meshcore_protocol.dart';

/// Length-prefixed framing for the MeshCore companion protocol over byte
/// streams (USB serial and TCP).
///
/// BLE gets frame boundaries for free — one GATT notification is one MeshCore
/// frame — but a byte stream does not, and MeshCore frames carry no length of
/// their own (they are bare `[code][payload…]`). This codec supplies the
/// boundaries:
///
/// Outbound (app → device): `0x3C` + 2-byte LE length + payload
/// Inbound (device → app): `0x3E` + 2-byte LE length + payload
///
/// There is no byte escaping. After a framing error the parser resynchronizes
/// on the next inbound prefix (`0x3E`), which may be payload data rather than
/// a real frame boundary if the stream was corrupted.
class SerialFrameCodec {
  static const int outboundPrefix = 0x3C;
  static const int inboundPrefix = 0x3E;

  int _state = 0;
  int _payloadLength = 0;
  final List<int> _payloadBuffer = [];

  Uint8List encodeOutbound(Uint8List payload) {
    if (payload.length > maxFrameSize) {
      throw ArgumentError(
        'Payload length ${payload.length} exceeds max frame size $maxFrameSize',
      );
    }

    final framed = Uint8List(3 + payload.length);
    framed[0] = outboundPrefix;
    framed[1] = payload.length & 0xFF;
    framed[2] = (payload.length >> 8) & 0xFF;
    framed.setRange(3, framed.length, payload);
    return framed;
  }

  List<Uint8List> feed(List<int> bytes) {
    final frames = <Uint8List>[];

    for (final byte in bytes) {
      switch (_state) {
        case 0:
          if (byte == inboundPrefix) {
            _state = 1;
          }
          break;
        case 1:
          _payloadLength = byte;
          _state = 2;
          break;
        case 2:
          _payloadLength |= byte << 8;
          if (_payloadLength > maxFrameSize) {
            _reset();
            break;
          }
          if (_payloadLength == 0) {
            frames.add(Uint8List(0));
            _reset();
            break;
          }
          _payloadBuffer.clear();
          _state = 3;
          break;
        case 3:
          _payloadBuffer.add(byte);
          if (_payloadBuffer.length >= _payloadLength) {
            frames.add(Uint8List.fromList(_payloadBuffer));
            _reset();
          }
          break;
      }
    }

    return frames;
  }

  void reset() => _reset();

  void _reset() {
    _state = 0;
    _payloadLength = 0;
    _payloadBuffer.clear();
  }
}

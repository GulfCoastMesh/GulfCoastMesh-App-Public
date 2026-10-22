import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_protocol.dart';
import 'package:gulf_coast_mesh_app/connector/serial_frame_codec.dart';

void main() {
  group('SerialFrameCodec', () {
    test('encodeOutbound prefixes payload with 0x3C and length', () {
      final codec = SerialFrameCodec();
      final payload = Uint8List.fromList([0x01, 0x02, 0x03]);
      final framed = codec.encodeOutbound(payload);

      expect(framed, [0x3C, 0x03, 0x00, 0x01, 0x02, 0x03]);
    });

    test('encodeOutbound rejects payload larger than maxFrameSize', () {
      final codec = SerialFrameCodec();
      final payload = Uint8List(maxFrameSize + 1);

      expect(() => codec.encodeOutbound(payload), throwsArgumentError);
    });

    test('feed decodes a single inbound frame', () {
      final codec = SerialFrameCodec();
      final payload = Uint8List.fromList([0x05, 0xAA]);
      final bytes = <int>[0x3E, payload.length, 0x00, ...payload];

      final frames = codec.feed(bytes);

      expect(frames.length, 1);
      expect(frames.first, payload);
    });

    test('feed reassembles frames split across reads', () {
      final codec = SerialFrameCodec();
      final payload = Uint8List.fromList([0x10, 0x20, 0x30, 0x40]);
      final bytes = <int>[0x3E, payload.length, 0x00, ...payload];

      final first = codec.feed(bytes.sublist(0, 3));
      expect(first, isEmpty);

      final second = codec.feed(bytes.sublist(3, 5));
      expect(second, isEmpty);

      final third = codec.feed(bytes.sublist(5));
      expect(third.length, 1);
      expect(third.first, payload);
    });

    test('feed decodes multiple frames in one read', () {
      final codec = SerialFrameCodec();
      final payloadA = Uint8List.fromList([0x01]);
      final payloadB = Uint8List.fromList([0x02, 0x03]);
      final bytes = <int>[
        0x3E,
        payloadA.length,
        0x00,
        ...payloadA,
        0x3E,
        payloadB.length,
        0x00,
        ...payloadB,
      ];

      final frames = codec.feed(bytes);

      expect(frames.length, 2);
      expect(frames[0], payloadA);
      expect(frames[1], payloadB);
    });

    test('feed rejects oversize length and resynchronizes', () {
      final codec = SerialFrameCodec();
      final validPayload = Uint8List.fromList([0x07]);
      final bytes = <int>[
        0x3E,
        maxFrameSize + 1,
        0x00,
        ...List<int>.filled(maxFrameSize + 1, 0xFF),
        0x3E,
        validPayload.length,
        0x00,
        ...validPayload,
      ];

      final frames = codec.feed(bytes);

      expect(frames.length, 1);
      expect(frames.first, validPayload);
    });

    test('feed ignores garbage until inbound prefix', () {
      final codec = SerialFrameCodec();
      final payload = Uint8List.fromList([0x09]);
      final bytes = <int>[0x00, 0xFF, 0x3E, payload.length, 0x00, ...payload];

      final frames = codec.feed(bytes);

      expect(frames.length, 1);
      expect(frames.first, payload);
    });
  });
}

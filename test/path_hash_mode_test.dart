import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_protocol.dart';
import 'package:gulf_coast_mesh_app/models/app_settings.dart';
import 'package:gulf_coast_mesh_app/models/contact.dart';

void main() {
  group('buildSetPathHashModeFrame', () {
    test('builds 2-byte mode frame', () {
      expect(buildSetPathHashModeFrame(1), Uint8List.fromList([0x3D, 0, 1]));
    });

    test('rejects invalid mode', () {
      expect(() => buildSetPathHashModeFrame(3), throwsArgumentError);
    });
  });

  group('path length metadata', () {
    test('decodes 1-byte 5-hop path', () {
      expect(decodePathHopCount(0x05), 5);
      expect(decodePathHashSize(0x05), 1);
      expect(decodePathByteLength(0x05), 5);
    });

    test('decodes 2-byte 5-hop path', () {
      expect(decodePathHopCount(0x45), 5);
      expect(decodePathHashSize(0x45), 2);
      expect(decodePathByteLength(0x45), 10);
    });

    test('decodes 3-byte 10-hop path', () {
      expect(decodePathHopCount(0x8A), 10);
      expect(decodePathHashSize(0x8A), 3);
      expect(decodePathByteLength(0x8A), 30);
    });

    test('encodes multibyte path length', () {
      expect(encodePathLength(hopCount: 5, hashSizeBytes: 2), 0x45);
    });
  });

  group('parsePathLengthField fallback hash size', () {
    test('uses fallback when the field does not self-describe', () {
      // 5, no self-describing bits set (legacy/ambiguous encoding).
      final parsed = parsePathLengthField(0x05, fallbackHashSizeBytes: 2);
      expect(parsed.hopCount, 5);
      expect(parsed.hashSizeBytes, 2);
      expect(parsed.pathByteLength, 10);
    });

    test('defaults to 1-byte hashes when no fallback given', () {
      final parsed = parsePathLengthField(0x05);
      expect(parsed.hashSizeBytes, 1);
      expect(parsed.pathByteLength, 5);
    });

    test('self-describing bits still win over the fallback', () {
      // 0x45 = 2-byte hashes, 5 hops, already self-describing.
      final parsed = parsePathLengthField(0x45, fallbackHashSizeBytes: 3);
      expect(parsed.hopCount, 5);
      expect(parsed.hashSizeBytes, 2);
      expect(parsed.pathByteLength, 10);
    });

    test('zero-length field ignores the fallback for byte length', () {
      final parsed = parsePathLengthField(0, fallbackHashSizeBytes: 2);
      expect(parsed.hopCount, 0);
      expect(parsed.pathByteLength, 0);
    });
  });

  group('formatPathIdList', () {
    test('formats 2-byte hop prefixes', () {
      expect(
        formatPathIdList(
          Uint8List.fromList([0xAB, 0xCD, 0xEF, 0x01]),
          hashSizeBytes: 2,
        ),
        'ABCD,EF01',
      );
    });
  });

  group('AppSettings companionPathHashMode', () {
    test('defaults to 2-byte mode', () {
      expect(AppSettings().companionPathHashMode, defaultPathHashMode);
      expect(defaultPathHashMode, 1);
    });

    test('round-trips JSON', () {
      final settings = AppSettings(companionPathHashMode: 2);
      final restored = AppSettings.fromJson(settings.toJson());
      expect(restored.companionPathHashMode, 2);
    });
  });

  group('Contact multibyte paths', () {
    for (final hashSize in [1, 2, 3]) {
      test('preserves two hops with $hashSize-byte hashes', () {
        final frame = Uint8List(contactFrameSize);
        frame[0] = respCodeContact;
        frame[contactTypeOffset] = advTypeRepeater;
        frame[contactPathLenOffset] = encodePathLength(
          hopCount: 2,
          hashSizeBytes: hashSize,
        );
        final path = List.generate(2 * hashSize, (i) => 0xa0 + i);
        frame.setAll(contactPathOffset, path);

        final contact = Contact.fromFrame(frame)!;
        expect(contact.pathLength, 2);
        expect(contact.effectivePathHashSize, hashSize);
        expect(contact.path, path);
        expect(contact.pathLabel, '2 hops');
      });
    }

    test('direct and flood routes remain distinct', () {
      final frame = Uint8List(contactFrameSize)..[0] = respCodeContact;
      expect(Contact.fromFrame(frame)!.pathLength, 0);
      frame[contactPathLenOffset] = 0xff;
      final flood = Contact.fromFrame(frame)!;
      expect(flood.pathLength, -1);
      expect(flood.path, isEmpty);
      expect(flood.pathLabel, 'Flood');
    });

    test('rejects reserved, oversized and truncated contact paths', () {
      final frame = Uint8List(contactFrameSize)..[0] = respCodeContact;
      frame[contactPathLenOffset] = 0xc2;
      expect(Contact.fromFrame(frame), isNull);
      frame[contactPathLenOffset] = encodePathLength(
        hopCount: 22,
        hashSizeBytes: 3,
      );
      expect(Contact.fromFrame(frame), isNull);
      frame[contactPathLenOffset] = 0x82;
      expect(
        Contact.fromFrame(frame.sublist(0, contactPathOffset + 5)),
        isNull,
      );
    });

    test('fromFrame parses encoded path metadata', () {
      final frame = Uint8List(contactFrameSize);
      frame[0] = respCodeContact;
      frame[contactTypeOffset] = advTypeRepeater;
      frame[contactPathLenOffset] = 0x42; // 2 hops, 2-byte hashes
      frame[contactPathOffset] = 0xAA;
      frame[contactPathOffset + 1] = 0xBB;
      frame[contactPathOffset + 2] = 0xCC;
      frame[contactPathOffset + 3] = 0xDD;
      frame[contactNameOffset] = 'R1'.codeUnitAt(0);

      final contact = Contact.fromFrame(frame);
      expect(contact, isNotNull);
      expect(contact!.pathLength, 2);
      expect(contact.path, Uint8List.fromList([0xAA, 0xBB, 0xCC, 0xDD]));
      expect(contact.pathIdList, 'AABB,CCDD');
    });

    test(
      'fromFrame uses fallbackHashSizeBytes for non-self-describing path',
      () {
        final frame = Uint8List(contactFrameSize);
        frame[0] = respCodeContact;
        frame[contactTypeOffset] = advTypeRepeater;
        frame[contactPathLenOffset] = 0x02; // 2 hops, no self-describing bits
        frame[contactPathOffset] = 0xAA;
        frame[contactPathOffset + 1] = 0xBB;
        frame[contactPathOffset + 2] = 0xCC;
        frame[contactPathOffset + 3] = 0xDD;
        frame[contactNameOffset] = 'R1'.codeUnitAt(0);

        final contact = Contact.fromFrame(frame, fallbackHashSizeBytes: 2);
        expect(contact, isNotNull);
        // 2 hops at the fallback 2-byte hash size = 4 path bytes, not 2.
        expect(contact!.path, Uint8List.fromList([0xAA, 0xBB, 0xCC, 0xDD]));
        expect(contact.pathIdList, 'AABB,CCDD');
      },
    );
  });
}

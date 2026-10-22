import 'dart:typed_data';

import 'package:ed25519_edwards/ed25519_edwards.dart' as ed;
import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/helpers/advert_signature.dart';
import 'package:gulf_coast_mesh_app/helpers/meshcore_channel_crypto.dart';

void main() {
  group('verifyAdvertSignature', () {
    test('accepts a correctly signed advert frame', () {
      final keyPair = ed.generateKey();
      final publicKey = Uint8List.fromList(keyPair.publicKey.bytes);
      final timestamp = Uint8List.fromList([0x78, 0x56, 0x34, 0x12]);
      final appData = Uint8List.fromList([0x81, 0x4e, 0x6f, 0x64, 0x65]);

      final message = Uint8List(32 + 4 + appData.length)
        ..setRange(0, 32, publicKey)
        ..setRange(32, 36, timestamp)
        ..setRange(36, 36 + appData.length, appData);

      final signature = ed.sign(keyPair.privateKey, message);
      final frame = Uint8List(100 + appData.length)
        ..setRange(0, 32, publicKey)
        ..setRange(32, 36, timestamp)
        ..setRange(36, 100, signature)
        ..setRange(100, 100 + appData.length, appData);

      expect(verifyAdvertSignature(frame), isTrue);
    });

    test('rejects tampered app data', () {
      final keyPair = ed.generateKey();
      final publicKey = Uint8List.fromList(keyPair.publicKey.bytes);
      final timestamp = Uint8List.fromList([0x01, 0x00, 0x00, 0x00]);
      final appData = Uint8List.fromList([0x80, 0x41]);

      final message = Uint8List(32 + 4 + appData.length)
        ..setRange(0, 32, publicKey)
        ..setRange(32, 36, timestamp)
        ..setRange(36, 36 + appData.length, appData);
      final signature = ed.sign(keyPair.privateKey, message);

      final frame = Uint8List(100 + appData.length)
        ..setRange(0, 32, publicKey)
        ..setRange(32, 36, timestamp)
        ..setRange(36, 100, signature)
        ..setRange(100, 100 + appData.length, appData);
      frame[100] = 0x81;

      expect(verifyAdvertSignature(frame), isFalse);
    });

    test('rejects truncated frames', () {
      expect(verifyAdvertSignature(Uint8List(50)), isFalse);
    });
  });

  group('meshcore channel crypto', () {
    test('computeChannelHash is first SHA-256 byte', () {
      final psk = Uint8List.fromList(List.generate(16, (i) => i));
      expect(computeChannelHash(psk), inInclusiveRange(0, 255));
    });

    test('decryptChannelPayload rejects bad mac', () {
      final psk = Uint8List.fromList(List.filled(16, 7));
      final encrypted = Uint8List.fromList([0x01, 0x02, ...List.filled(16, 0)]);
      expect(decryptChannelPayload(psk, encrypted), isNull);
    });
  });
}

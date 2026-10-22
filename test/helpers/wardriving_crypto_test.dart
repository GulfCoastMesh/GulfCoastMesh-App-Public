import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/helpers/wardriving_crypto.dart';
import 'package:pointycastle/export.dart';

void main() {
  Uint8List encryptGroupText(Uint8List psk, String text) {
    final textBytes = utf8.encode(text);
    final plainLength = ((5 + textBytes.length + 1 + 15) ~/ 16) * 16;
    final plain = Uint8List(plainLength);
    plain.setRange(5, 5 + textBytes.length, textBytes);

    final key16 = Uint8List(16)..setRange(0, 16, psk);
    final cipher = ECBBlockCipher(AESEngine())..init(true, KeyParameter(key16));
    final encrypted = Uint8List(plain.length);
    for (var offset = 0; offset < plain.length; offset += 16) {
      cipher.processBlock(plain, offset, encrypted, offset);
    }

    final key32 = Uint8List(32)..setRange(0, 16, psk);
    final mac = crypto.Hmac(crypto.sha256, key32).convert(encrypted).bytes;
    return Uint8List.fromList([
      computeChannelHash(psk),
      mac[0],
      mac[1],
      ...encrypted,
    ]);
  }

  test('decryptGroupTextMessage preserves UTF-8 sender and text', () {
    final psk = Uint8List.fromList(List<int>.generate(16, (i) => i + 1));
    const message = 'José: Ready ✅';

    expect(
      decryptGroupTextMessage(psk, encryptGroupText(psk, message)),
      message,
    );
  });
}

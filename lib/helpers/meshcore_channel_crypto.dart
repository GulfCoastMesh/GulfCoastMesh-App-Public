import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;
import 'package:pointycastle/export.dart';

const int meshcoreCipherMacSize = 2;

int computeChannelHash(Uint8List psk) {
  final digest = crypto.sha256.convert(psk).bytes;
  return digest[0];
}

/// Decrypt a MeshCore channel ciphertext blob: `[mac x2][aes-ecb ciphertext]`.
Uint8List? decryptChannelPayload(Uint8List psk, Uint8List encrypted) {
  if (encrypted.length <= meshcoreCipherMacSize) return null;
  final mac = encrypted.sublist(0, meshcoreCipherMacSize);
  final cipherText = encrypted.sublist(meshcoreCipherMacSize);

  final key32 = Uint8List(32);
  final copyLen = psk.length < 32 ? psk.length : 32;
  key32.setRange(0, copyLen, psk);

  final hmac = crypto.Hmac(crypto.sha256, key32).convert(cipherText).bytes;
  if (hmac[0] != mac[0] || hmac[1] != mac[1]) {
    return null;
  }

  if (cipherText.isEmpty || cipherText.length % 16 != 0) return null;
  final key16 = Uint8List(16);
  final keyLen = psk.length < 16 ? psk.length : 16;
  key16.setRange(0, keyLen, psk);

  final cipher = ECBBlockCipher(AESEngine());
  cipher.init(false, KeyParameter(key16));
  final out = Uint8List(cipherText.length);
  for (var i = 0; i < cipherText.length; i += 16) {
    cipher.processBlock(cipherText, i, out, i);
  }
  return out;
}

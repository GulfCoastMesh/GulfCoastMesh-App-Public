import 'dart:convert';
import 'dart:typed_data';

import 'meshcore_channel_crypto.dart';

export 'meshcore_channel_crypto.dart'
    show computeChannelHash, decryptChannelPayload, meshcoreCipherMacSize;

@Deprecated('Use meshcoreCipherMacSize')
const int wardrivingCipherMacSize = meshcoreCipherMacSize;

String? decryptGroupTextMessage(Uint8List psk, Uint8List encryptedPayload) {
  if (encryptedPayload.length <= meshcoreCipherMacSize + 1) return null;
  final encrypted = encryptedPayload.sublist(1);
  final decrypted = decryptChannelPayload(psk, encrypted);
  if (decrypted == null || decrypted.length < 6) return null;

  final txtType = decrypted[4];
  if ((txtType >> 2) != 0) return null;

  var end = 5;
  while (end < decrypted.length && decrypted[end] != 0) {
    end++;
  }
  return utf8.decode(decrypted.sublist(5, end), allowMalformed: true).trim();
}

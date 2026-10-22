import 'dart:typed_data';

import 'package:ed25519_edwards/ed25519_edwards.dart' as ed;

/// MeshCore node advert layout:
/// `[public_key x32][timestamp x4 LE][signature x64][appdata...]`
///
/// Signature covers `public_key || timestamp || appdata` (see MeshCore payloads.md).
bool verifyAdvertSignature(Uint8List frame) {
  if (frame.length < 100) return false;

  final publicKey = frame.sublist(0, 32);
  final timestamp = frame.sublist(32, 36);
  final signature = frame.sublist(36, 100);
  final appData = frame.length > 100 ? frame.sublist(100) : Uint8List(0);

  final message = Uint8List(32 + 4 + appData.length);
  message.setRange(0, 32, publicKey);
  message.setRange(32, 36, timestamp);
  if (appData.isNotEmpty) {
    message.setRange(36, message.length, appData);
  }

  try {
    return ed.verify(ed.PublicKey(publicKey), message, signature);
  } catch (_) {
    return false;
  }
}

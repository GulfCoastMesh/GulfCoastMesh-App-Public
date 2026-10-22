import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// MeshMapper's 56-bit, four-round Feistel wire tag.
///
/// This implementation intentionally uses arithmetic for values wider than
/// 32 bits so it remains byte-identical on Dart web builds.
class MeshMapperWireTag {
  MeshMapperWireTag._();

  static const prefix = 'MM:';
  static const _pow11 = 2048;
  static const _pow25 = 33554432;
  static const _pow28 = 268435456;
  static const _pow12 = 4096;
  static const _mask28 = 0x0FFFFFFF;
  static const _yearBase = 2020;
  static const _pow9 = 512;
  static const _pow5 = 32;

  static String encode(String sessionId, int counter, String? key) {
    final parts = sessionId.split('-');
    if (parts.length < 3 ||
        parts[0].length != 3 ||
        parts[0].toLowerCase() == 'offline' ||
        counter < 1 ||
        counter > 2047) {
      throw ArgumentError('Invalid MeshMapper session or ping counter');
    }
    final dateText = parts[1];
    if (dateText.length != 8) throw ArgumentError('Invalid session date');
    final year = int.parse(dateText.substring(0, 4));
    final month = int.parse(dateText.substring(4, 6));
    final day = int.parse(dateText.substring(6, 8));
    final date = (year - _yearBase) * _pow9 + month * _pow5 + day;
    final lowPart = date * _pow25 + int.parse(parts[2]) * _pow11 + counter;
    final lo = lowPart % _pow28;
    final hi = _packRegion(parts[0]) * _pow12 + lowPart ~/ _pow28;
    final encrypted = _feistel(utf8.encode(key ?? ''), hi, lo);
    return prefix + _base64Url(_toBytes(encrypted.$1, encrypted.$2));
  }

  static int _packRegion(String value) {
    final region = value.toUpperCase();
    return (region.codeUnitAt(0) - 65) * 676 +
        (region.codeUnitAt(1) - 65) * 26 +
        region.codeUnitAt(2) -
        65;
  }

  static int _round(List<int> secret, int half, int round) {
    final digest = sha256.convert([
      ...secret,
      round,
      (half ~/ 16777216) % 256,
      (half ~/ 65536) % 256,
      (half ~/ 256) % 256,
      half % 256,
    ]).bytes;
    return (digest[0] * 16777216 +
            digest[1] * 65536 +
            digest[2] * 256 +
            digest[3]) %
        _pow28;
  }

  static (int, int) _feistel(List<int> secret, int hi, int lo) {
    var left = hi;
    var right = lo;
    for (var round = 0; round < 4; round++) {
      final nextLeft = right;
      right = (left ^ _round(secret, right, round)) & _mask28;
      left = nextLeft;
    }
    return (left, right);
  }

  static Uint8List _toBytes(int hi, int lo) => Uint8List.fromList([
    (hi ~/ 1048576) % 256,
    (hi ~/ 4096) % 256,
    (hi ~/ 16) % 256,
    (hi % 16) * 16 + (lo ~/ 16777216) % 16,
    (lo ~/ 65536) % 256,
    (lo ~/ 256) % 256,
    lo % 256,
  ]);

  static String _base64Url(List<int> bytes) =>
      base64Url.encode(bytes).replaceAll('=', '');
}

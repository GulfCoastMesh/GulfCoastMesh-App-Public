import 'dart:typed_data';

/// Bounded RFC1951 decoder for API2. Unlike permissive archive readers this
/// requires a final block, rejects trailing streams and caps output as it grows.
Uint8List inflateWeatherPayload(Uint8List input) {
  final bits = _Bits(input);
  final output = <int>[];
  void append(int value) {
    if (output.length >= 8192) {
      throw const FormatException('API2 inflation limit');
    }
    output.add(value);
  }

  var finalBlock = false;
  while (!finalBlock) {
    finalBlock = bits.read(1) == 1;
    final type = bits.read(2);
    if (type == 0) {
      bits.align();
      final length = bits.read(16);
      if ((length ^ bits.read(16)) != 65535) {
        throw const FormatException('Invalid stored block');
      }
      for (var i = 0; i < length; i++) {
        append(bits.read(8));
      }
      continue;
    }
    if (type == 3) throw const FormatException('Reserved DEFLATE block');
    late _Huffman literals, distances;
    if (type == 1) {
      literals = _Huffman(
        List.generate(
          288,
          (i) => i < 144
              ? 8
              : i < 256
              ? 9
              : i < 280
              ? 7
              : 8,
        ),
      );
      distances = _Huffman(List.filled(32, 5));
    } else {
      final nl = bits.read(5) + 257;
      final nd = bits.read(5) + 1;
      final nc = bits.read(4) + 4;
      if (nl > 286) throw const FormatException('Invalid literal count');
      const order = [
        16,
        17,
        18,
        0,
        8,
        7,
        9,
        6,
        10,
        5,
        11,
        4,
        12,
        3,
        13,
        2,
        14,
        1,
        15,
      ];
      final lengths = List.filled(19, 0);
      for (var i = 0; i < nc; i++) {
        lengths[order[i]] = bits.read(3);
      }
      final codes = _Huffman(lengths);
      final rows = <int>[];
      while (rows.length < nl + nd) {
        final code = codes.decode(bits);
        if (code < 16) {
          rows.add(code);
          continue;
        }
        if (code == 16 && rows.isEmpty) {
          throw const FormatException('Missing previous length');
        }
        final repeat = code == 16
            ? bits.read(2) + 3
            : code == 17
            ? bits.read(3) + 3
            : bits.read(7) + 11;
        final value = code == 16 ? rows.last : 0;
        if (rows.length + repeat > nl + nd) {
          throw const FormatException('Length repeat overflow');
        }
        rows.addAll(List.filled(repeat, value));
      }
      if (rows[256] == 0) throw const FormatException('Missing end of block');
      literals = _Huffman(rows.sublist(0, nl));
      distances = _Huffman(rows.sublist(nl));
    }
    while (true) {
      final code = literals.decode(bits);
      if (code < 256) {
        append(code);
        continue;
      }
      if (code == 256) break;
      if (code > 285) throw const FormatException('Invalid length symbol');
      const bases = [
        3,
        4,
        5,
        6,
        7,
        8,
        9,
        10,
        11,
        13,
        15,
        17,
        19,
        23,
        27,
        31,
        35,
        43,
        51,
        59,
        67,
        83,
        99,
        115,
        131,
        163,
        195,
        227,
        258,
      ];
      const extras = [
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        1,
        1,
        1,
        1,
        2,
        2,
        2,
        2,
        3,
        3,
        3,
        3,
        4,
        4,
        4,
        4,
        5,
        5,
        5,
        5,
        0,
      ];
      final length = bases[code - 257] + bits.read(extras[code - 257]);
      final distanceCode = distances.decode(bits);
      if (distanceCode > 29) {
        throw const FormatException('Invalid distance symbol');
      }
      const db = [
        1,
        2,
        3,
        4,
        5,
        7,
        9,
        13,
        17,
        25,
        33,
        49,
        65,
        97,
        129,
        193,
        257,
        385,
        513,
        769,
        1025,
        1537,
        2049,
        3073,
        4097,
        6145,
        8193,
        12289,
        16385,
        24577,
      ];
      final extra = distanceCode < 4 ? 0 : distanceCode ~/ 2 - 1;
      final distance = db[distanceCode] + bits.read(extra);
      if (distance > output.length) {
        throw const FormatException('Invalid back reference');
      }
      for (var i = 0; i < length; i++) {
        append(output[output.length - distance]);
      }
    }
  }
  if ((bits.position + 7) ~/ 8 != input.length) {
    throw const FormatException('Trailing DEFLATE bytes');
  }
  return Uint8List.fromList(output);
}

class _Bits {
  _Bits(this.bytes);
  final Uint8List bytes;
  int position = 0;
  int read(int count) {
    if (position + count > bytes.length * 8) {
      throw const FormatException('Truncated DEFLATE stream');
    }
    var value = 0;
    for (var i = 0; i < count; i++, position++) {
      value |= ((bytes[position ~/ 8] >> (position % 8)) & 1) << i;
    }
    return value;
  }

  void align() {
    position = (position + 7) ~/ 8 * 8;
  }
}

class _Huffman {
  _Huffman(List<int> lengths) {
    final counts = List.filled(16, 0);
    for (final length in lengths) {
      if (length > 0) counts[length]++;
    }
    var left = 1;
    for (var i = 1; i <= 15; i++) {
      left = left * 2 - counts[i];
      if (left < 0) throw const FormatException('Oversubscribed Huffman tree');
    }
    final next = List.filled(16, 0);
    var code = 0;
    for (var i = 1; i <= 15; i++) {
      code = (code + counts[i - 1]) << 1;
      next[i] = code;
    }
    for (var symbol = 0; symbol < lengths.length; symbol++) {
      final length = lengths[symbol];
      if (length > 0) _codes[(1 << length) | next[length]++] = symbol;
    }
  }
  final Map<int, int> _codes = {};
  int decode(_Bits bits) {
    var code = 0;
    for (var length = 1; length <= 15; length++) {
      code = (code << 1) | bits.read(1);
      final symbol = _codes[(1 << length) | code];
      if (symbol != null) return symbol;
    }
    throw const FormatException('Invalid Huffman code');
  }
}

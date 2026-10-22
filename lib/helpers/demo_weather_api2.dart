import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'weather_api2_codec.dart';

/// Synthetic API2 responses used only by the connector's explicit demo mode.
/// A complete wire round trip keeps the real decoder and UI exercised in demos.
List<String> demoWeatherApi2Replies(String request, {bool dm = false}) {
  final command = request.trim().toLowerCase();
  if (!command.endsWith(' api2')) return [];
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final zip = RegExp(r'\b\d{5}\b').firstMatch(command)?.group(0) ?? '39501';
  var type = 6;
  List<int> payload = utf8.encode(jsonEncode(['api2', 5]));
  void positional(int kind, List<Object?> fields) {
    type = kind;
    payload = utf8.encode(jsonEncode(fields));
  }

  if (command == 'bot api2' || command == 'wx help api2') {
    positional(2, [
      255,
      [140, 16],
      ['F', 'mph', '%'],
    ]);
  } else if (command == 'wx version api2') {
    positional(3, ['demo-api2']);
  } else if (command == 'ping api2' && dm) {
    positional(5, [
      DateTime.now().toUtc().toIso8601String(),
      'Direct (demo)',
      4.2,
    ]);
  } else if (command.startsWith('wx report')) {
    if (!dm) {
      positional(6, ['wx report', 4]);
    } else {
      positional(
        4,
        command == 'wx report stop api2'
            ? [
                'stopped',
                null,
                [zip],
              ]
            : ['enabled', zip],
      );
    }
  } else if (command.startsWith('wx radar ')) {
    final words = command.split(RegExp(r'\s+'));
    final lat = words.length == 6 ? double.tryParse(words[2]) : null;
    final lon = words.length == 6 ? double.tryParse(words[3]) : null;
    final offset = words.length == 6
        ? words[4] == 'now'
              ? 0
              : int.tryParse(words[4].replaceAll('h', ''))
        : null;
    if (lat != null &&
        lon != null &&
        lat.isFinite &&
        lon.isFinite &&
        lat.abs() <= 90 &&
        lon.abs() <= 180 &&
        offset != null &&
        offset.abs() <= 5) {
      type = 8;
      final bytes = Uint8List(324);
      final view = ByteData.sublistView(bytes);
      bytes[0] = offset > 0 ? 1 : 0;
      bytes[1] = 32;
      view.setInt8(2, offset);
      view.setInt32(3, (lat * 100000).round());
      view.setInt32(7, (lon * 100000).round());
      view.setUint32(11, now + offset * 3600);
      view.setUint32(15, offset > 0 ? now - 3600 : 0);
      var bit = 0;
      for (var y = 0; y < 32; y++) {
        for (var x = 0; x < 32; x++) {
          if (!weatherRadarIncludesCell(x, y, 32)) continue;
          final distance = math.sqrt(
            math.pow(x - 18 - offset, 2) + math.pow(y - 12, 2),
          );
          final code = x < 3
              ? 7
              : distance < 3
              ? 6
              : distance < 5
              ? 4
              : distance < 9
              ? 2
              : 0;
          final index = 19 + bit ~/ 8;
          final shift = bit % 8;
          bytes[index] |= (code << shift) & 255;
          if (shift > 5) bytes[index + 1] |= code >> (8 - shift);
          bit += 3;
        }
      }
      payload = bytes;
    }
  } else if (RegExp(r'^wx \d{5} all api2$').hasMatch(command)) {
    type = 1;
    payload = [];
    void unsigned(int value) {
      do {
        final part = value & 127;
        value >>= 7;
        payload.add(part | (value > 0 ? 128 : 0));
      } while (value > 0);
    }

    void row(List<int> values) {
      payload.add(63);
      for (final value in values) {
        unsigned(value >= 0 ? value * 2 : -value * 2 - 1);
      }
    }

    unsigned(int.parse(zip));
    unsigned(now);
    row([84, 2, 71, 165, 12, 89]);
    payload.add(5 | (1 << 3));
    row([0, 84, 2, 165, 12, 20]);
    for (var i = 1; i < 5; i++) {
      row([60, -1, 0, 5, 0, 10]);
    }
    payload.add(0x26); // Synthetic moderate heat alert for the demo UI.
  } else if (RegExp(r'^wx \d{5} api2$').hasMatch(command)) {
    positional(7, [
      zip,
      'Gulf Coast (demo)',
      '84°F',
      'Partly cloudy',
      '71%',
      '89°F',
      'SE 12 mph',
    ]);
  }
  final id = DateTime.now().microsecondsSinceEpoch & 0xffffff;
  final count = payload.length <= 98 ? 1 : (payload.length + 95) ~/ 96;
  return [
    for (var i = 0; i < count; i++)
      '~W2${base64Url.encode([
        type | (count > 1 ? 64 : 0),
        (id >> 16) & 255,
        (id >> 8) & 255,
        id & 255,
        if (count > 1) ...[i, count],
        ...payload.sublist(count == 1 ? 0 : i * 96, count == 1 ? payload.length : math.min((i + 1) * 96, payload.length)),
      ]).replaceAll('=', '')}',
  ];
}

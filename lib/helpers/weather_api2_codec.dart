import 'dart:convert';
import 'dart:typed_data';

import 'weather_inflate.dart';

/// One independently armored API2 fragment. Context and sender belong to the
/// caller's reassembly key, not to the bot's opaque 24-bit response ID.
class WeatherApi2Frame {
  WeatherApi2Frame(String text) {
    if (!RegExp(r'^~W2[A-Za-z0-9_-]+$').hasMatch(text) || text.length > 139) {
      throw const FormatException('Invalid API2 armor');
    }
    final raw = base64Url.decode(base64Url.normalize(text.substring(3)));
    if (raw.length < 5 || raw.length > 102) {
      throw const FormatException('Invalid API2 frame size');
    }
    flags = raw[0];
    type = flags & 15;
    if (flags & 128 != 0 || type < 1 || type > 8) {
      throw const FormatException('Unsupported API2 frame');
    }
    id = raw
        .sublist(1, 4)
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
    final fragmented = flags & 64 != 0;
    if (fragmented && raw.length < 7) {
      throw const FormatException('Truncated fragment');
    }
    index = fragmented ? raw[4] : 0;
    count = fragmented ? raw[5] : 1;
    if ((fragmented && count < 2) ||
        count > (type == 8 ? 4 : 16) ||
        index >= count) {
      throw const FormatException('Invalid fragment count');
    }
    payload = raw.sublist(fragmented ? 6 : 4);
  }

  late final int flags, type, index, count;
  late final String id;
  late final Uint8List payload;
}

class WeatherApi2Group {
  WeatherApi2Group(this.first);
  final WeatherApi2Frame first;
  final Map<int, Uint8List> _parts = {};
  int get received => _parts.length;
  int get total => first.count;

  Map<String, dynamic>? add(WeatherApi2Frame frame) {
    if (frame.id != first.id ||
        frame.flags != first.flags ||
        frame.count != total) {
      throw const FormatException('Inconsistent API2 fragments');
    }
    final previous = _parts[frame.index];
    if (previous != null &&
        base64Encode(previous) != base64Encode(frame.payload)) {
      throw const FormatException('Conflicting API2 duplicate');
    }
    _parts[frame.index] = frame.payload;
    if (received != total) return null;
    var bytes = Uint8List.fromList([
      for (var i = 0; i < total; i++) ..._parts[i]!,
    ]);
    if (first.flags & 32 != 0) bytes = inflateWeatherPayload(bytes);
    if (bytes.length > 8192) {
      throw const FormatException('API2 payload too large');
    }
    final result = decodeWeatherApi2Payload(first.type, bytes);
    result['flood_warning'] = first.flags & 16 != 0;
    return result;
  }
}

Map<String, dynamic> decodeWeatherApi2Payload(int type, Uint8List bytes) {
  if (type == 1) return _decodeWeather(bytes);
  if (type == 8) return _decodeRadar(bytes);
  const schemas = {
    2: ['cmd', 'lim', 'u'],
    3: ['git_commit'],
    4: ['status', 'zip_code', 'zip_codes'],
    5: ['received_at', 'path', 'approx_direct_miles'],
    6: ['command', 'error', 'zip_code'],
    7: ['z', 'l', 't', 'c', 'h', 'i', 'w', 'a'],
  };
  const kinds = {
    2: 'b',
    3: 'version',
    4: 'report',
    5: 'pong',
    6: 'e',
    7: 'current',
  };
  final schema = schemas[type];
  if (schema == null) throw const FormatException('Unknown API2 type');
  final slots = jsonDecode(utf8.decode(bytes));
  if (slots is! List || slots.length > schema.length) {
    throw const FormatException('Invalid API2 positional payload');
  }
  for (var i = 0; i < slots.length; i++) {
    final value = slots[i];
    if (value == null) continue;
    final field = schema[i];
    final valid = switch (field) {
      'cmd' || 'error' => value is int && value >= 0,
      'lim' =>
        value is List &&
            value.length == 2 &&
            value.every((v) => v is int && v > 0),
      'u' || 'zip_codes' => value is List && value.every((v) => v is String),
      'a' => value is List,
      'approx_direct_miles' => value is num && value.isFinite && value >= 0,
      't' || 'h' || 'i' => value is String || (value is num && value.isFinite),
      _ => value is String,
    };
    if (!valid) throw FormatException('Invalid API2 field: $field');
  }
  return {
    'k': kinds[type],
    for (var i = 0; i < slots.length; i++) schema[i]: slots[i],
  };
}

Map<String, dynamic> _decodeWeather(Uint8List bytes) {
  final reader = _WeatherReader(bytes);
  final zip = reader.unsigned();
  if (zip > 99999) throw const FormatException('Invalid weather ZIP');
  final generated = reader.unsigned();
  // DateTime's supported range, also exactly representable on web.
  if (generated > 8640000000000) throw const FormatException('Invalid time');
  final current = reader.row();
  final counts = reader.byte();
  final hours = counts & 7;
  final alerts = (counts >> 3) & 7;
  if (counts & 128 != 0 || hours > 5 || alerts > 5) {
    throw const FormatException('Invalid weather row counts');
  }
  var previous = List<int?>.filled(6, 0);
  final hourly = <List<int?>>[];
  for (var i = 0; i < hours; i++) {
    final delta = reader.row();
    final row = List<int?>.generate(
      6,
      (j) => delta[j] == null ? null : delta[j]! + (previous[j] ?? 0),
    );
    hourly.add(row);
    previous = row;
  }
  final alertRows = <List<int>>[];
  for (var i = 0; i < alerts; i++) {
    final value = reader.byte();
    alertRows.add([value & 15, value >> 4]);
  }
  if (reader.offset != bytes.length) {
    throw const FormatException('Trailing weather bytes');
  }
  return {
    'k': 'w',
    'z': zip.toString().padLeft(5, '0'),
    'g': generated,
    'n': current,
    'h': hourly,
    'a': alertRows,
    'x': counts & 64 != 0,
  };
}

class _WeatherReader {
  _WeatherReader(this.bytes);
  final Uint8List bytes;
  int offset = 0;
  int byte() {
    if (offset >= bytes.length) {
      throw const FormatException('Truncated weather payload');
    }
    return bytes[offset++];
  }

  int unsigned() {
    var value = BigInt.zero;
    for (var i = 0; i < 10; i++) {
      final b = byte();
      if (i == 9 && b > 1) throw const FormatException('Oversized integer');
      value |= BigInt.from(b & 127) << (7 * i);
      if (b & 128 == 0) {
        if (i > 0 && b == 0) {
          throw const FormatException('Noncanonical integer');
        }
        // Weather values must be safe integers on Dart's web and native targets.
        if (value > BigInt.from(9007199254740991)) {
          throw const FormatException('Unsafe integer');
        }
        return value.toInt();
      }
    }
    throw const FormatException('Oversized integer');
  }

  List<int?> row() {
    final mask = byte();
    if (mask & 192 != 0) throw const FormatException('Invalid row mask');
    return List.generate(6, (i) {
      if (mask & (1 << i) == 0) return null;
      final value = unsigned();
      return value.isEven ? value ~/ 2 : -((value + 1) ~/ 2);
    });
  }
}

bool weatherRadarIncludesCell(int x, int y, int width) =>
    (2 * x + 1 - width) * (2 * x + 1 - width) +
        (2 * y + 1 - width) * (2 * y + 1 - width) <=
    width * width;

Map<String, dynamic> _decodeRadar(Uint8List bytes) {
  if (bytes.length < 19) throw const FormatException('Truncated radar header');
  final view = ByteData.sublistView(bytes);
  final source = bytes[0];
  final width = bytes[1];
  final offset = view.getInt8(2);
  final lat = view.getInt32(3) / 100000;
  final lon = view.getInt32(7) / 100000;
  final valid = view.getUint32(11);
  final issued = view.getUint32(15);
  if (source > 1 ||
      (width != 28 && width != 32) ||
      offset < -5 ||
      offset > 5 ||
      lat.abs() > 90 ||
      lon.abs() > 180 ||
      (source == 0 ? issued != 0 : issued == 0)) {
    throw const FormatException('Invalid radar metadata');
  }
  var count = 0;
  for (var y = 0; y < width; y++) {
    for (var x = 0; x < width; x++) {
      if (weatherRadarIncludesCell(x, y, width)) count++;
    }
  }
  if (bytes.length != 19 + (count * 3 + 7) ~/ 8) {
    throw const FormatException('Invalid radar size');
  }
  final cells = <int>[];
  for (var j = 0; j < count; j++) {
    final bit = j * 3;
    final index = 19 + bit ~/ 8;
    final shift = bit % 8;
    var value = bytes[index] >> shift;
    if (shift > 5) value |= bytes[index + 1] << (8 - shift);
    cells.add(value & 7);
  }
  final padding = count * 3 % 8;
  if (padding != 0 && bytes.last >> padding != 0) {
    throw const FormatException('Nonzero radar padding');
  }
  return {
    'k': 'r',
    'lat': lat,
    'lon': lon,
    'o': offset,
    'v': valid,
    if (source == 1) 'i': issued,
    's': source == 0 ? 'observed' : 'forecast',
    'n': width,
    'c': cells,
  };
}

import 'dart:convert';

/// ATAK-style tactical map payloads sent as MeshCore channel/DM plain text.
///
/// Prefix: `a:v1` (ASCII, lowercase). Do not use `g:` for GIF payloads.
///
/// ## Position update (blue-force location)
/// ```
/// a:v1|pos|lat|lon|timestamp|name
/// ```
/// - lat/lon: decimal degrees, 6 fractional digits
/// - timestamp: Unix seconds (uint32-safe)
/// - name: callsign or node label; pipes replaced with `/`, max 32 UTF-8 bytes
///
/// Example: `a:v1|pos|37.774900|-122.419400|1717603200|Alpha-1`
///
/// ## POI marker
/// ```
/// a:v1|poi|lat|lon|timestamp|label|type
/// ```
/// - label: marker label; pipes replaced with `/`, max 32 UTF-8 bytes
/// - type: short code (`poi`, `wp`, `tgt`, `hz`, …); defaults to `poi`
///
/// Example: `a:v1|poi|37.774900|-122.419400|1717603200|LZ North|wp`
///
/// Future versions may use `a:v2|…`; only `a:v1` is accepted today.
enum TacticalMapKind { position, poi }

sealed class TacticalMapPayload {
  const TacticalMapPayload();

  TacticalMapKind get kind;

  double get lat;
  double get lon;
  int get timestampSeconds;

  static const String prefix = 'a:v1';
  static const int maxFieldUtf8Bytes = 32;

  static bool isTacticalMapPayload(String text) {
    return text.trim().startsWith('$prefix|');
  }

  static TacticalMapPayload? tryParse(String text) {
    final trimmed = text.trim();
    if (!trimmed.startsWith('$prefix|')) return null;

    final parts = trimmed.split('|');
    if (parts.length < 2) return null;

    final kindToken = parts[1];
    switch (kindToken) {
      case 'pos':
        if (parts.length != 6) return null;
        final lat = _parseLat(parts[2]);
        final lon = _parseLon(parts[3]);
        final timestamp = _parseTimestamp(parts[4]);
        if (lat == null || lon == null || timestamp == null) return null;
        final name = parts[5];
        if (name.isEmpty) return null;
        return TacticalPositionUpdate(
          lat: lat,
          lon: lon,
          timestampSeconds: timestamp,
          name: name,
        );
      case 'poi':
        if (parts.length != 7) return null;
        final lat = _parseLat(parts[2]);
        final lon = _parseLon(parts[3]);
        final timestamp = _parseTimestamp(parts[4]);
        if (lat == null || lon == null || timestamp == null) return null;
        final label = parts[5];
        final type = parts[6];
        if (label.isEmpty || type.isEmpty) return null;
        return TacticalPoiMarker(
          lat: lat,
          lon: lon,
          timestampSeconds: timestamp,
          label: label,
          type: type,
        );
      default:
        return null;
    }
  }

  static String formatPosition({
    required double lat,
    required double lon,
    required int timestampSeconds,
    required String name,
  }) {
    return [
      prefix,
      'pos',
      _formatCoord(lat),
      _formatCoord(lon),
      timestampSeconds.toString(),
      _sanitizeField(name),
    ].join('|');
  }

  static String formatPoi({
    required double lat,
    required double lon,
    required int timestampSeconds,
    required String label,
    String type = 'poi',
  }) {
    final normalizedType = _sanitizeField(type.isEmpty ? 'poi' : type);
    return [
      prefix,
      'poi',
      _formatCoord(lat),
      _formatCoord(lon),
      timestampSeconds.toString(),
      _sanitizeField(label),
      normalizedType,
    ].join('|');
  }

  static double? _parseLat(String value) {
    final lat = double.tryParse(value.trim());
    if (lat == null || lat < -90 || lat > 90) return null;
    return lat;
  }

  static double? _parseLon(String value) {
    final lon = double.tryParse(value.trim());
    if (lon == null || lon < -180 || lon > 180) return null;
    return lon;
  }

  static int? _parseTimestamp(String value) {
    final timestamp = int.tryParse(value.trim());
    if (timestamp == null || timestamp < 0) return null;
    return timestamp;
  }

  static String _formatCoord(double value) {
    return value.toStringAsFixed(6);
  }

  static String _sanitizeField(String value) {
    final cleaned = value.trim().replaceAll('|', '/');
    return _truncateUtf8(cleaned, maxFieldUtf8Bytes);
  }

  static String _truncateUtf8(String value, int maxBytes) {
    final bytes = utf8.encode(value);
    if (bytes.length <= maxBytes) return value;

    var end = maxBytes;
    while (end > 0 && (bytes[end] & 0xC0) == 0x80) {
      end--;
    }
    return utf8.decode(bytes.sublist(0, end));
  }
}

final class TacticalPositionUpdate extends TacticalMapPayload {
  @override
  final double lat;
  @override
  final double lon;
  @override
  final int timestampSeconds;
  final String name;

  const TacticalPositionUpdate({
    required this.lat,
    required this.lon,
    required this.timestampSeconds,
    required this.name,
  });

  @override
  TacticalMapKind get kind => TacticalMapKind.position;
}

final class TacticalPoiMarker extends TacticalMapPayload {
  @override
  final double lat;
  @override
  final double lon;
  @override
  final int timestampSeconds;
  final String label;
  final String type;

  const TacticalPoiMarker({
    required this.lat,
    required this.lon,
    required this.timestampSeconds,
    required this.label,
    required this.type,
  });

  @override
  TacticalMapKind get kind => TacticalMapKind.poi;
}

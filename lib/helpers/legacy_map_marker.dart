/// Legacy shared map marker format: `m:lat,lon|label|flags`
///
/// Superseded by the ATAK-style `a:v1` payloads in [TacticalMapPayload], which
/// is what this app sends now. This parser exists purely so pins that are
/// already out there still render: messages from clients on older builds, and
/// pins sitting in a user's own persisted history from before the migration.
///
/// Read-only on purpose. There is deliberately no formatter — restoring one
/// would put this format back on the air.
class LegacyMapMarker {
  final double lat;
  final double lon;
  final String label;
  final String flags;

  const LegacyMapMarker({
    required this.lat,
    required this.lon,
    required this.label,
    required this.flags,
  });

  static LegacyMapMarker? tryParse(String text) {
    final trimmed = text.trim();
    if (!trimmed.startsWith('m:')) return null;

    final parts = trimmed.substring(2).split('|');
    if (parts.isEmpty) return null;

    final coords = parts[0].split(',');
    if (coords.length != 2) return null;

    final lat = double.tryParse(coords[0].trim());
    final lon = double.tryParse(coords[1].trim());
    if (lat == null || lon == null) return null;
    if (lat < -90 || lat > 90 || lon < -180 || lon > 180) return null;

    final label = parts.length > 1 ? parts[1].trim() : '';
    final flags = parts.length > 2 ? parts[2].trim() : '';

    return LegacyMapMarker(lat: lat, lon: lon, label: label, flags: flags);
  }
}

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';

import 'region_scope_codes.dart';

/// Loads dissolved region outer rings for Gulf Coast scopes.
///
/// GeoJSON parts are parish/county unions with internal borders removed
/// (see `scripts/dissolve_gulf_coast_regions.py`).
class GulfCoastRegionGeometry {
  GulfCoastRegionGeometry._();

  static const String assetPath = 'assets/geo/gulf_coast_regions.geojson';

  static Map<String, List<List<LatLng>>>? _cache;
  static Future<Map<String, List<List<LatLng>>>>? _loading;

  /// Ring lists keyed by MeshCore region code (outer rings only).
  static Future<Map<String, List<List<LatLng>>>> load() {
    if (_cache != null) return Future.value(_cache!);
    return _loading ??= _loadAsset();
  }

  static Map<String, List<List<LatLng>>>? get cached => _cache;

  static List<List<LatLng>> ringsFor(String code) {
    return _cache?[RegionScopeCodes.canonicalize(code)] ?? const [];
  }

  static Future<Map<String, List<List<LatLng>>>> _loadAsset() async {
    final raw = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final features = decoded['features'] as List<dynamic>? ?? const [];
    final result = <String, List<List<LatLng>>>{};

    for (final feature in features) {
      if (feature is! Map<String, dynamic>) continue;
      final props = feature['properties'] as Map<String, dynamic>? ?? {};
      final code = props['code']?.toString();
      if (code == null || code.isEmpty) continue;
      final geom = feature['geometry'] as Map<String, dynamic>?;
      if (geom == null) continue;
      result[code] = _parseRings(geom);
    }

    _cache = result;
    _loading = null;
    return result;
  }

  static List<List<LatLng>> _parseRings(Map<String, dynamic> geom) {
    final type = geom['type']?.toString();
    final coords = geom['coordinates'];
    final rings = <List<LatLng>>[];

    void addRing(dynamic ring) {
      if (ring is! List || ring.length < 3) return;
      final points = <LatLng>[];
      for (final c in ring) {
        if (c is! List || c.length < 2) continue;
        final lon = (c[0] as num).toDouble();
        final lat = (c[1] as num).toDouble();
        points.add(LatLng(lat, lon));
      }
      if (points.length >= 3) rings.add(points);
    }

    if (type == 'Polygon' && coords is List && coords.isNotEmpty) {
      addRing(coords.first);
    } else if (type == 'MultiPolygon' && coords is List) {
      for (final poly in coords) {
        if (poly is List && poly.isNotEmpty) addRing(poly.first);
      }
    }
    return rings;
  }

  /// Approximate area of a ring (absolute shoelace), for hit-test priority.
  static double ringArea(List<LatLng> ring) {
    if (ring.length < 3) return 0;
    var sum = 0.0;
    for (var i = 0; i < ring.length; i++) {
      final j = (i + 1) % ring.length;
      sum += ring[i].longitude * ring[j].latitude;
      sum -= ring[j].longitude * ring[i].latitude;
    }
    return sum.abs() * 0.5;
  }

  static double totalArea(List<List<LatLng>> rings) {
    var total = 0.0;
    for (final ring in rings) {
      total += ringArea(ring);
    }
    return total;
  }

  static bool containsPoint(List<List<LatLng>> rings, LatLng point) {
    for (final ring in rings) {
      if (_ringContains(ring, point)) return true;
    }
    return false;
  }

  static bool _ringContains(List<LatLng> poly, LatLng point) {
    if (poly.length < 3) return false;
    var inside = false;
    for (var i = 0, j = poly.length - 1; i < poly.length; j = i++) {
      final xi = poly[i].longitude;
      final yi = poly[i].latitude;
      final xj = poly[j].longitude;
      final yj = poly[j].latitude;
      final intersect =
          ((yi > point.latitude) != (yj > point.latitude)) &&
          (point.longitude <
              (xj - xi) * (point.latitude - yi) / (yj - yi) + xi);
      if (intersect) inside = !inside;
    }
    return inside;
  }

  /// Test helper: inject geometry without asset load.
  static void debugSetCache(Map<String, List<List<LatLng>>>? value) {
    _cache = value;
    _loading = null;
  }
}

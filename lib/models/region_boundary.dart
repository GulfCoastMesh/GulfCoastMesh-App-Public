import 'package:latlong2/latlong.dart';

/// One entry in the locally bundled Gulf Coast Mesh region catalog.
class RegionBoundary {
  final int indexPosition;
  final String id;
  final String name;
  final String coordinationStatus;
  final String coordinationLabel;
  final bool initiallyVisible;
  final bool optional;
  final String geometryUrl;
  final List<GeoJsonPolygon> polygons;

  const RegionBoundary({
    required this.indexPosition,
    required this.id,
    required this.name,
    required this.coordinationStatus,
    required this.coordinationLabel,
    required this.initiallyVisible,
    required this.optional,
    required this.geometryUrl,
    required this.polygons,
  });

  String get displayCode => id;

  bool containsPoint(LatLng point) =>
      polygons.any((polygon) => polygon.containsPoint(point));
}

/// One GeoJSON Polygon part, with the outer ring first and holes afterward.
class GeoJsonPolygon {
  final List<List<LatLng>> rings;

  const GeoJsonPolygon(this.rings);

  bool containsPoint(LatLng point) {
    // The source's Alaska rings cross the antimeridian. Check world copies,
    // and include shared boundaries (including hole edges), as the docs do.
    return [0.0, -360.0, 360.0].any((offset) {
      final wrapped = LatLng(point.latitude, point.longitude + offset);
      if (rings.isEmpty || _ringLocation(rings.first, wrapped) < 0) {
        return false;
      }
      return !rings.skip(1).any((hole) => _ringLocation(hole, wrapped) == 1);
    });
  }
}

// -1 outside, 0 on the boundary, 1 inside.
int _ringLocation(List<LatLng> ring, LatLng point) {
  if (ring.length < 3) return -1;
  var inside = false;
  for (var i = 0, j = ring.length - 1; i < ring.length; j = i++) {
    final a = ring[i];
    final b = ring[j];
    if (_pointOnSegment(point, a, b)) return 0;
    final crossesLatitude =
        (a.latitude > point.latitude) != (b.latitude > point.latitude);
    if (crossesLatitude &&
        point.longitude <
            (b.longitude - a.longitude) *
                    (point.latitude - a.latitude) /
                    (b.latitude - a.latitude) +
                a.longitude) {
      inside = !inside;
    }
  }
  return inside ? 1 : -1;
}

bool _pointOnSegment(LatLng point, LatLng a, LatLng b) {
  final lengthSquared =
      (b.longitude - a.longitude) * (b.longitude - a.longitude) +
      (b.latitude - a.latitude) * (b.latitude - a.latitude);
  if (lengthSquared == 0) {
    return (point.longitude - a.longitude).abs() < 1e-10 &&
        (point.latitude - a.latitude).abs() < 1e-10;
  }
  final cross =
      (point.latitude - a.latitude) * (b.longitude - a.longitude) -
      (point.longitude - a.longitude) * (b.latitude - a.latitude);
  if (cross.abs() > 1e-10) return false;
  final dot =
      (point.longitude - a.longitude) * (b.longitude - a.longitude) +
      (point.latitude - a.latitude) * (b.latitude - a.latitude);
  return dot >= 0 && dot <= lengthSquared;
}

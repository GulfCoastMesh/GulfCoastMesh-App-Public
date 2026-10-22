import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Web Mercator latitude limit used for world overview downloads.
const double kMapWorldMaxLatitude = 85.05112878;

const int kMapWorldOverviewDefaultMinZoom = 2;
const int kMapWorldOverviewDefaultMaxZoom = 5;

LatLngBounds get kWorldOverviewBounds => LatLngBounds(
  const LatLng(kMapWorldMaxLatitude, -180),
  const LatLng(-kMapWorldMaxLatitude, 180),
);

class MapOfflineDownloadSpec {
  final LatLngBounds bounds;
  final int minZoom;
  final int maxZoom;

  const MapOfflineDownloadSpec({
    required this.bounds,
    required this.minZoom,
    required this.maxZoom,
  });
}

class MapOfflinePreset {
  final String id;
  final LatLngBounds bounds;
  final int defaultMinZoom;
  final int defaultMaxZoom;

  const MapOfflinePreset({
    required this.id,
    required this.bounds,
    required this.defaultMinZoom,
    required this.defaultMaxZoom,
  });

  MapOfflineDownloadSpec toDownloadSpec({int? minZoom, int? maxZoom}) {
    return MapOfflineDownloadSpec(
      bounds: bounds,
      minZoom: minZoom ?? defaultMinZoom,
      maxZoom: maxZoom ?? defaultMaxZoom,
    );
  }
}

/// Built-in regional presets (bounds can be tuned without migrating user data).
final List<MapOfflinePreset> kMapOfflinePresets = [
  MapOfflinePreset(
    id: 'gulf_coast',
    bounds: LatLngBounds(LatLng(24.0, -97.0), LatLng(31.0, -80.0)),
    defaultMinZoom: 10,
    defaultMaxZoom: 15,
  ),
];

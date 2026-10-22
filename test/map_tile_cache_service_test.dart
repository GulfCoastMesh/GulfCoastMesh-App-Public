import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gulf_coast_mesh_app/models/map_offline_region.dart';
import 'package:gulf_coast_mesh_app/services/map_tile_cache_service.dart';

void main() {
  test('world overview defaults are low zoom', () {
    expect(kMapWorldOverviewDefaultMinZoom, 2);
    expect(kMapWorldOverviewDefaultMaxZoom, 5);
    expect(kWorldOverviewBounds.north, closeTo(kMapWorldMaxLatitude, 0.001));
  });

  test('gulf coast preset is configured', () {
    final preset = kMapOfflinePresets.first;
    expect(preset.id, 'gulf_coast');
    expect(preset.defaultMinZoom, 10);
    expect(preset.defaultMaxZoom, 15);
    expect(preset.toDownloadSpec().minZoom, preset.defaultMinZoom);
  });

  test('persisted bounds reject non-finite and out-of-range values', () {
    expect(
      MapTileCacheService.boundsFromJson({
        'north': double.nan,
        'south': -10,
        'east': 10,
        'west': -10,
      }),
      isNull,
    );
    expect(
      MapTileCacheService.boundsFromJson({
        'north': 95,
        'south': -10,
        'east': 10,
        'west': -10,
      }),
      isNull,
    );
    expect(
      MapTileCacheService.boundsFromJson({
        'north': -20,
        'south': 20,
        'east': 10,
        'west': -10,
      }),
      isNull,
    );
  });

  test('tile estimates clamp invalid zoom inputs', () {
    final bounds = LatLngBounds.unsafe(
      north: 85,
      south: -85,
      west: -180,
      east: 180,
    );

    expect(MapTileCacheService.estimateTileCountForBounds(bounds, -10, -1), 1);
  });
}

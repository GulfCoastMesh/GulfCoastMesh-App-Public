import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/models/app_settings.dart';

void main() {
  test('isolated corrupt fields do not discard valid settings', () {
    final settings = AppSettings.fromJson({
      'map_show_repeaters': false,
      'theme_mode': 'dark',
      'notifications_enabled': 'not-a-bool',
      'map_key_prefix': 42,
      'battery_chemistry_by_device_id': 'not-a-map',
      'battery_cell_count_by_device_id': 'not-a-map',
      'map_cache_bounds': {'north': 31.0, 'south': 'bad', 'east': -88},
    });

    expect(settings.mapShowRepeaters, isFalse);
    expect(settings.themeMode, 'dark');
    expect(settings.notificationsEnabled, isTrue);
    expect(settings.mapKeyPrefix, isEmpty);
    expect(settings.batteryChemistryByDeviceId, isEmpty);
    expect(settings.batteryCellCountByDeviceId, isEmpty);
    expect(settings.mapCacheBounds, {'north': 31.0, 'east': -88.0});
  });

  test('integer settings accept JSON numeric values', () {
    final settings = AppSettings.fromJson({
      'map_cache_min_zoom': 9.0,
      'atak_channel_index': 3.0,
      'wardriving_interval_sec': 45.0,
    });

    expect(settings.mapCacheMinZoom, 9);
    expect(settings.atakChannelIndex, 3);
    expect(settings.wardrivingIntervalSec, 45);
  });
}

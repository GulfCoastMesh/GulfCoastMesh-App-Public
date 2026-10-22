import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/models/app_settings.dart';

void main() {
  group('AppSettings ATAK fields', () {
    test('defaults keep broadcast disabled and no channel selected', () {
      final settings = AppSettings();
      expect(settings.atakChannelIndex, isNull);
      expect(settings.atakChannelName, '');
      expect(settings.atakLocationBroadcastEnabled, isFalse);
      expect(settings.atakMovementDistanceMeters, 50);
      expect(settings.atakMinSendIntervalSec, 60);
      expect(settings.atakSyncNodeAdvertLocation, isFalse);
    });

    test('json round-trip preserves ATAK settings', () {
      final original = AppSettings(
        atakChannelIndex: 2,
        atakChannelName: '#atak',
        atakLocationBroadcastEnabled: true,
        atakMovementDistanceMeters: 75,
        atakMinSendIntervalSec: 120,
        atakSyncNodeAdvertLocation: true,
      );

      final restored = AppSettings.fromJson(original.toJson());
      expect(restored.atakChannelIndex, 2);
      expect(restored.atakChannelName, '#atak');
      expect(restored.atakLocationBroadcastEnabled, isTrue);
      expect(restored.atakMovementDistanceMeters, 75);
      expect(restored.atakMinSendIntervalSec, 120);
      expect(restored.atakSyncNodeAdvertLocation, isTrue);
    });

    test('fromJson uses safe defaults for missing ATAK keys', () {
      final restored = AppSettings.fromJson({});
      expect(restored.atakChannelIndex, isNull);
      expect(restored.atakChannelName, '');
      expect(restored.atakLocationBroadcastEnabled, isFalse);
      expect(restored.atakMovementDistanceMeters, 50);
      expect(restored.atakMinSendIntervalSec, 60);
      expect(restored.atakSyncNodeAdvertLocation, isFalse);
    });
  });
}

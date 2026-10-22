import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/models/app_settings.dart';
import 'package:gulf_coast_mesh_app/models/wardriving.dart';
import 'package:gulf_coast_mesh_app/models/wardriving_queue_item.dart';
import 'package:gulf_coast_mesh_app/services/meshmapper_queue_service.dart';

void main() {
  group('WardrivingQueueItem', () {
    test('round-trips JSON', () {
      final item = WardrivingQueueItem.tx(
        latitude: 45.1,
        longitude: -75.2,
        heardRepeats: '4E(12.25)',
        timestamp: DateTime.utc(2026, 1, 1, 12),
        externalAntenna: true,
        powerWatts: 0.3,
      );

      final restored = WardrivingQueueItem.fromJson(item.toJson());
      expect(restored.type, 'TX');
      expect(restored.latitude, 45.1);
      expect(restored.heardRepeats, '4E(12.25)');
      expect(restored.externalAntenna, isTrue);
      expect(restored.powerWatts, 0.3);
    });

    test('formats TX API JSON', () {
      final item = WardrivingQueueItem.tx(
        latitude: 45.1,
        longitude: -75.2,
        heardRepeats: '4E(12.25),77(10.00)',
        timestamp: DateTime.utc(2026, 1, 1, 12),
        externalAntenna: false,
        powerWatts: 1.0,
      );

      final json = item.toApiJson(contactPrefix: 'ABCD');
      expect(json['type'], 'TX');
      expect(json['heard_repeats'], '4E(12.25),77(10.00)');
      expect(json['power'], '1.0w');
      expect(json['contact'], 'ABCD');
    });

    test('formats DISC API JSON', () {
      final item = WardrivingQueueItem.disc(
        latitude: 45.1,
        longitude: -75.2,
        heardRepeats: '4E:REPEATER:12.00:-50:5.00:ABCD',
        timestamp: DateTime.utc(2026, 1, 1, 12),
        externalAntenna: false,
      );

      final json = item.toApiJson();
      expect(json['type'], 'DISC');
      expect(json['repeater_id'], '4E');
      expect(json['node_type'], 'REPEATER');
      expect(json['local_snr'], 12.0);
    });

    test('keeps retry metadata capped with durable long backoff', () {
      final item = WardrivingQueueItem.rx(
        latitude: 29.7,
        longitude: -95.3,
        heardRepeats: '4E(8.00)',
        timestamp: DateTime.utc(2026),
        externalAntenna: false,
      );

      for (var i = 0; i < 20; i++) {
        item.markRetried();
      }
      expect(item.retryCount, 5);
      expect(item.nextRetryDelay, const Duration(minutes: 5));
      expect(WardrivingQueueItem.fromJson(item.toJson()).retryCount, 5);
    });

    test(
      'identifies partial and complete wire-tag metadata as session-bound',
      () {
        final tagged = WardrivingQueueItem.tx(
          latitude: 29.7,
          longitude: -95.3,
          heardRepeats: '4E(8.00)',
          timestamp: DateTime.utc(2026),
          externalAntenna: false,
          wireTag: 'MM:abc',
        );
        final counterOnly = WardrivingQueueItem.tx(
          latitude: 29.7,
          longitude: -95.3,
          heardRepeats: '4E(8.00)',
          timestamp: DateTime.utc(2026),
          externalAntenna: false,
          pingCounter: 1,
        );

        expect(tagged.hasWireTag, isTrue);
        expect(counterOnly.hasWireTag, isTrue);
      },
    );

    test('persists wire-tag session binding without rebinding it', () {
      final item = WardrivingQueueItem.tx(
        latitude: 29.7,
        longitude: -95.3,
        heardRepeats: '4E(8.00)',
        timestamp: DateTime.utc(2026),
        externalAntenna: false,
        wireTag: 'MM:abc',
      );
      item.bindWireTagSession('session-original');
      item.bindWireTagSession('session-new');

      expect(item.wireTagSessionId, 'session-original');
      expect(
        WardrivingQueueItem.fromJson(item.toJson()).wireTagSessionId,
        'session-original',
      );
    });

    test('formats TRACE with nullable measured RSSI', () {
      final item = WardrivingQueueItem.trace(
        latitude: 29.7,
        longitude: -95.3,
        heardRepeats: 'AABB:7.25::3.50',
        timestamp: DateTime.utc(2026),
        externalAntenna: false,
      );

      final json = item.toApiJson();
      expect(json['repeater_id'], 'AABB');
      expect(json['local_snr'], 7.25);
      expect(json['local_rssi'], isNull);
      expect(json['remote_snr'], 3.5);
    });
  });

  group('formatHeardRepeats', () {
    test('formats repeater map', () {
      expect(
        formatHeardRepeats({'4E': 12.25, '77': 10}),
        '4E(12.25),77(10.00)',
      );
      expect(formatHeardRepeats({}), 'None');
    });
  });

  group('AppSettings wardriving fields', () {
    test('serializes wardriving settings', () {
      final settings = AppSettings(
        wardrivingDisclosureAccepted: true,
        wardrivingIntervalSec: 30,
        wardrivingMinDistanceMeters: 25,
        wardrivingExternalAntenna: true,
        wardrivingCarpeaterPrefix: 'AB',
        wardrivingDisableRssiFilter: true,
        wardrivingIncludeContactKey: true,
        wardrivingDiscDropEnabled: true,
        wardrivingBroadcastCoordinates: true,
        wardrivingBackgroundEnabled: false,
        wardrivingCoverageGridSize: 100,
        wardrivingOfflineMode: true,
      );

      final restored = AppSettings.fromJson(settings.toJson());
      expect(restored.wardrivingDisclosureAccepted, isTrue);
      expect(restored.wardrivingIntervalSec, 30);
      expect(restored.wardrivingMinDistanceMeters, 25);
      expect(restored.wardrivingCarpeaterPrefix, 'AB');
      expect(restored.wardrivingIncludeContactKey, isTrue);
      expect(restored.wardrivingBroadcastCoordinates, isTrue);
      expect(restored.wardrivingBackgroundEnabled, isFalse);
      expect(restored.wardrivingCoverageGridSize, 100);
      expect(restored.wardrivingOfflineMode, isTrue);
    });

    test('clamps wardriving interval below minimum on load', () {
      final restored = AppSettings.fromJson({'wardriving_interval_sec': 5});
      expect(restored.wardrivingIntervalSec, kWardrivingMinIntervalSec);
    });

    test('clamps wardriving movement distance to the protocol floor', () {
      final restored = AppSettings.fromJson({
        'wardriving_min_distance_meters': 1,
      });
      expect(
        restored.wardrivingMinDistanceMeters,
        kWardrivingMinDistanceMeters,
      );
    });
  });
}

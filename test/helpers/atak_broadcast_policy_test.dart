import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:gulf_coast_mesh_app/helpers/atak_broadcast_policy.dart';

void main() {
  final now = DateTime.utc(2026, 6, 5, 12, 0, 0);
  const startLat = 37.7749;
  const startLon = -122.4194;
  const thresholdMeters = 50.0;
  const dist = Distance();
  final movedLat = startLat + (thresholdMeters / 111320);

  group('shouldBroadcastAtakPosition', () {
    test('returns false without coordinates', () {
      expect(
        shouldBroadcastAtakPosition(
          lat: null,
          lon: -122.0,
          lastLat: null,
          lastLon: null,
          lastSentAt: null,
          minIntervalSec: 60,
          movementMeters: 50,
          now: now,
        ),
        isFalse,
      );
    });

    test('allows first send when coordinates are available', () {
      expect(
        shouldBroadcastAtakPosition(
          lat: 37.7749,
          lon: -122.4194,
          lastLat: null,
          lastLon: null,
          lastSentAt: null,
          minIntervalSec: 60,
          movementMeters: 50,
          now: now,
        ),
        isTrue,
      );
    });

    test('blocks send before min interval elapses', () {
      expect(
        shouldBroadcastAtakPosition(
          lat: 37.7749,
          lon: -122.4194,
          lastLat: 37.7749,
          lastLon: -122.4194,
          lastSentAt: now.subtract(const Duration(seconds: 30)),
          minIntervalSec: 60,
          movementMeters: 50,
          now: now,
        ),
        isFalse,
      );
    });

    test('blocks send when movement is below threshold', () {
      expect(
        shouldBroadcastAtakPosition(
          lat: 37.77495,
          lon: -122.41945,
          lastLat: 37.7749,
          lastLon: -122.4194,
          lastSentAt: now.subtract(const Duration(seconds: 120)),
          minIntervalSec: 60,
          movementMeters: 50,
          now: now,
        ),
        isFalse,
      );
    });

    test('allows send after interval and sufficient movement', () {
      expect(
        shouldBroadcastAtakPosition(
          lat: 37.7755,
          lon: -122.4194,
          lastLat: 37.7749,
          lastLon: -122.4194,
          lastSentAt: now.subtract(const Duration(seconds: 120)),
          minIntervalSec: 60,
          movementMeters: 50,
          now: now,
        ),
        isTrue,
      );
    });

    test('allows send when interval elapsed exactly at minimum', () {
      expect(
        shouldBroadcastAtakPosition(
          lat: movedLat,
          lon: startLon,
          lastLat: startLat,
          lastLon: startLon,
          lastSentAt: now.subtract(const Duration(seconds: 60)),
          minIntervalSec: 60,
          movementMeters: thresholdMeters,
          now: now,
        ),
        isTrue,
      );
    });

    test('allows send when movement is exactly at threshold', () {
      expect(
        dist(const LatLng(startLat, startLon), LatLng(movedLat, startLon)),
        closeTo(thresholdMeters, 1.0),
      );
      expect(
        shouldBroadcastAtakPosition(
          lat: movedLat,
          lon: startLon,
          lastLat: startLat,
          lastLon: startLon,
          lastSentAt: now.subtract(const Duration(seconds: 120)),
          minIntervalSec: 60,
          movementMeters: thresholdMeters,
          now: now,
        ),
        isTrue,
      );
    });

    test('blocks send when interval elapsed but movement is zero', () {
      expect(
        shouldBroadcastAtakPosition(
          lat: startLat,
          lon: startLon,
          lastLat: startLat,
          lastLon: startLon,
          lastSentAt: now.subtract(const Duration(seconds: 120)),
          minIntervalSec: 60,
          movementMeters: thresholdMeters,
          now: now,
        ),
        isFalse,
      );
    });
  });
}

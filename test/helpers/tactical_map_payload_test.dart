import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/helpers/tactical_map_payload.dart';

void main() {
  group('TacticalMapPayload', () {
    const lat = 37.7749;
    const lon = -122.4194;
    const timestamp = 1717603200;

    group('formatPosition / tryParse round-trip', () {
      test('position payload round-trips', () {
        final text = TacticalMapPayload.formatPosition(
          lat: lat,
          lon: lon,
          timestampSeconds: timestamp,
          name: 'Alpha-1',
        );
        expect(text, 'a:v1|pos|37.774900|-122.419400|1717603200|Alpha-1');

        final parsed = TacticalMapPayload.tryParse(text);
        expect(parsed, isA<TacticalPositionUpdate>());
        final position = parsed! as TacticalPositionUpdate;
        expect(position.lat, closeTo(lat, 0.000001));
        expect(position.lon, closeTo(lon, 0.000001));
        expect(position.timestampSeconds, timestamp);
        expect(position.name, 'Alpha-1');
        expect(position.kind, TacticalMapKind.position);
      });

      test('sanitizes pipes in name', () {
        final text = TacticalMapPayload.formatPosition(
          lat: lat,
          lon: lon,
          timestampSeconds: timestamp,
          name: 'Alpha|1',
        );
        final parsed =
            TacticalMapPayload.tryParse(text)! as TacticalPositionUpdate;
        expect(parsed.name, 'Alpha/1');
      });
    });

    group('formatPoi / tryParse round-trip', () {
      test('poi payload round-trips', () {
        final text = TacticalMapPayload.formatPoi(
          lat: lat,
          lon: lon,
          timestampSeconds: timestamp,
          label: 'LZ North',
          type: 'wp',
        );
        expect(text, 'a:v1|poi|37.774900|-122.419400|1717603200|LZ North|wp');

        final parsed = TacticalMapPayload.tryParse(text);
        expect(parsed, isA<TacticalPoiMarker>());
        final poi = parsed! as TacticalPoiMarker;
        expect(poi.lat, closeTo(lat, 0.000001));
        expect(poi.lon, closeTo(lon, 0.000001));
        expect(poi.timestampSeconds, timestamp);
        expect(poi.label, 'LZ North');
        expect(poi.type, 'wp');
        expect(poi.kind, TacticalMapKind.poi);
      });

      test('defaults empty type to poi', () {
        final text = TacticalMapPayload.formatPoi(
          lat: lat,
          lon: lon,
          timestampSeconds: timestamp,
          label: 'Target',
          type: '',
        );
        final parsed = TacticalMapPayload.tryParse(text)! as TacticalPoiMarker;
        expect(parsed.type, 'poi');
      });

      test('sanitizes pipes in label', () {
        final text = TacticalMapPayload.formatPoi(
          lat: lat,
          lon: lon,
          timestampSeconds: timestamp,
          label: 'LZ|North',
          type: 'wp',
        );
        final parsed = TacticalMapPayload.tryParse(text)! as TacticalPoiMarker;
        expect(parsed.label, 'LZ/North');
      });
    });

    group('isTacticalMapPayload', () {
      test('returns true for a:v1 payloads', () {
        expect(
          TacticalMapPayload.isTacticalMapPayload(
            'a:v1|pos|37.774900|-122.419400|1717603200|Alpha-1',
          ),
          isTrue,
        );
      });

      test('returns false for other prefixes', () {
        expect(
          TacticalMapPayload.isTacticalMapPayload('x:v1|poi|1|2|3|x|wp'),
          isFalse,
        );
        expect(TacticalMapPayload.isTacticalMapPayload('g:abc'), isFalse);
      });
    });

    group('invalid payloads', () {
      test('rejects wrong prefix', () {
        expect(TacticalMapPayload.tryParse('b:v1|pos|1|2|3|x'), isNull);
        expect(TacticalMapPayload.tryParse('a:v2|pos|1|2|3|x'), isNull);
        expect(TacticalMapPayload.tryParse('x:v1|poi|1|2|3|LZ|wp'), isNull);
        expect(TacticalMapPayload.tryParse('g:abc123'), isNull);
      });

      test('rejects wrong field counts', () {
        expect(TacticalMapPayload.tryParse('a:v1|pos|1|2|3'), isNull);
        expect(TacticalMapPayload.tryParse('a:v1|poi|1|2|3|4'), isNull);
        expect(TacticalMapPayload.tryParse('a:v1|poi|1|2|3|4|5|6'), isNull);
      });

      test('rejects invalid coordinates and timestamp', () {
        expect(
          TacticalMapPayload.tryParse('a:v1|pos|bad|-122.419400|1717603200|A'),
          isNull,
        );
        expect(
          TacticalMapPayload.tryParse('a:v1|pos|91.0|-122.419400|1717603200|A'),
          isNull,
        );
        expect(
          TacticalMapPayload.tryParse('a:v1|pos|37.774900|181|1717603200|A'),
          isNull,
        );
        expect(
          TacticalMapPayload.tryParse('a:v1|pos|37.774900|-122.419400|bad|A'),
          isNull,
        );
      });

      test('rejects empty required text fields', () {
        expect(
          TacticalMapPayload.tryParse(
            'a:v1|pos|37.774900|-122.419400|1717603200|',
          ),
          isNull,
        );
        expect(
          TacticalMapPayload.tryParse(
            'a:v1|poi|37.774900|-122.419400|1717603200||wp',
          ),
          isNull,
        );
      });

      test('rejects unknown kind token', () {
        expect(
          TacticalMapPayload.tryParse(
            'a:v1|track|37.774900|-122.419400|1717603200|Alpha-1',
          ),
          isNull,
        );
      });

      test('rejects empty body', () {
        expect(TacticalMapPayload.tryParse(''), isNull);
        expect(TacticalMapPayload.tryParse('   '), isNull);
      });
    });
  });
}

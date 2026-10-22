import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/helpers/channel_message_preview.dart';
import 'package:gulf_coast_mesh_app/helpers/tactical_map_payload.dart';

void main() {
  group('ChannelMessagePreview', () {
    const lat = 37.7749;
    const lon = -122.4194;
    const timestamp = 1717603200;

    test('classifies tactical position updates', () {
      final text = TacticalMapPayload.formatPosition(
        lat: lat,
        lon: lon,
        timestampSeconds: timestamp,
        name: 'Alpha-1',
      );

      expect(
        ChannelMessagePreview.classify(text),
        ChannelStructuredMessageKind.tacticalPosition,
      );
      expect(ChannelMessagePreview.isTacticalPosition(text), isTrue);
      expect(ChannelMessagePreview.shouldNotify(text), isFalse);
      expect(ChannelMessagePreview.parsePoi(text), isNull);
    });

    test('classifies and parses tactical POI messages', () {
      final text = TacticalMapPayload.formatPoi(
        lat: lat,
        lon: lon,
        timestampSeconds: timestamp,
        label: 'LZ North',
        type: 'wp',
      );

      expect(
        ChannelMessagePreview.classify(text),
        ChannelStructuredMessageKind.tacticalPoi,
      );
      expect(ChannelMessagePreview.isTacticalPosition(text), isFalse);
      expect(ChannelMessagePreview.shouldNotify(text), isTrue);

      final poi = ChannelMessagePreview.parsePoi(text);
      expect(poi, isNotNull);
      expect(poi!.lat, closeTo(lat, 0.000001));
      expect(poi.lon, closeTo(lon, 0.000001));
      expect(poi.label, 'LZ North');
      expect(poi.tacticalType, 'wp');
    });

    test('still reads legacy m: pins from older clients and history', () {
      const text = 'm:37.774900,-122.419400|LZ North|poi';
      expect(
        ChannelMessagePreview.classify(text),
        ChannelStructuredMessageKind.legacyPoi,
      );
      expect(ChannelMessagePreview.shouldNotify(text), isTrue);

      final poi = ChannelMessagePreview.parsePoi(text)!;
      expect(poi.lat, closeTo(37.7749, 1e-6));
      expect(poi.lon, closeTo(-122.4194, 1e-6));
      expect(poi.label, 'LZ North');
      // Legacy pins predate tactical types; the flags field is not one.
      expect(poi.tacticalType, isNull);
    });

    test('a legacy pin with no label still parses', () {
      final poi = ChannelMessagePreview.parsePoi('m:30.396,-89.093')!;
      expect(poi.label, isEmpty);
    });

    test('malformed legacy pins stay plain text', () {
      for (final text in [
        'm:not,coords|x',
        'm:91.0,0.0|out of range',
        'm:0.0,181.0|out of range',
        'm:',
        'meet me at the ramp',
      ]) {
        expect(
          ChannelMessagePreview.classify(text),
          ChannelStructuredMessageKind.plain,
          reason: 'should not classify "$text" as a pin',
        );
      }
    });

    test('classifies GIF messages', () {
      const text = 'g:abc123';

      expect(
        ChannelMessagePreview.classify(text),
        ChannelStructuredMessageKind.gif,
      );
      expect(ChannelMessagePreview.shouldNotify(text), isTrue);
      expect(ChannelMessagePreview.parseGifId(text), 'abc123');
      expect(ChannelMessagePreview.parsePoi(text), isNull);
    });

    test('classifies plain text messages', () {
      const text = 'Hello mesh';

      expect(
        ChannelMessagePreview.classify(text),
        ChannelStructuredMessageKind.plain,
      );
      expect(ChannelMessagePreview.shouldNotify(text), isTrue);
      expect(ChannelMessagePreview.parsePoi(text), isNull);
      expect(ChannelMessagePreview.parseGifId(text), isNull);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/helpers/legacy_map_marker.dart';

void main() {
  group('LegacyMapMarker.tryParse', () {
    test('reads coordinates, label, and flags', () {
      final m = LegacyMapMarker.tryParse('m:30.396000,-89.092800|Ramp|poi')!;
      expect(m.lat, closeTo(30.396, 1e-9));
      expect(m.lon, closeTo(-89.0928, 1e-9));
      expect(m.label, 'Ramp');
      expect(m.flags, 'poi');
    });

    test('tolerates whitespace and missing optional fields', () {
      final m = LegacyMapMarker.tryParse('  m: 30.5 , -89.5 ')!;
      expect(m.lat, closeTo(30.5, 1e-9));
      expect(m.label, isEmpty);
      expect(m.flags, isEmpty);

      expect(LegacyMapMarker.tryParse('m:1.0,2.0|only label')!.flags, isEmpty);
    });

    test('rejects out-of-range coordinates', () {
      expect(LegacyMapMarker.tryParse('m:90.1,0'), isNull);
      expect(LegacyMapMarker.tryParse('m:-90.1,0'), isNull);
      expect(LegacyMapMarker.tryParse('m:0,180.1'), isNull);
      expect(LegacyMapMarker.tryParse('m:0,-180.1'), isNull);
    });

    test('accepts the exact range boundaries', () {
      expect(LegacyMapMarker.tryParse('m:90,180'), isNotNull);
      expect(LegacyMapMarker.tryParse('m:-90,-180'), isNotNull);
    });

    test('rejects anything that is not this format', () {
      for (final text in [
        '',
        'm:',
        'm:onlyone',
        'm:a,b',
        'm:1,2,3',
        'a:v1|poi|1|2|3|x|wp',
        'just a message about m: things',
      ]) {
        expect(
          LegacyMapMarker.tryParse(text),
          isNull,
          reason: 'should reject "$text"',
        );
      }
    });

    test('a label containing the delimiter keeps only the label segment', () {
      // The sender replaced '|' with '/' when formatting, so a raw '|' in a
      // label means the remainder is flags, not label text.
      final m = LegacyMapMarker.tryParse('m:1,2|North|Ramp')!;
      expect(m.label, 'North');
      expect(m.flags, 'Ramp');
    });
  });
}

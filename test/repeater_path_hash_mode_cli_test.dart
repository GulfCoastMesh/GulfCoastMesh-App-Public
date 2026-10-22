import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_protocol.dart';

void main() {
  group('parsePathHashModeCliValue', () {
    test('accepts valid modes', () {
      expect(parsePathHashModeCliValue('0'), 0);
      expect(parsePathHashModeCliValue('1'), 1);
      expect(parsePathHashModeCliValue('2'), 2);
      expect(parsePathHashModeCliValue('>2'), 2);
    });

    test('rejects invalid values', () {
      expect(parsePathHashModeCliValue('3'), isNull);
      expect(parsePathHashModeCliValue('1,2'), isNull);
      expect(parsePathHashModeCliValue(''), isNull);
      expect(parsePathHashModeCliValue('abc'), isNull);
    });
  });
}

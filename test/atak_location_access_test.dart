import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/helpers/atak_location_access.dart';

void main() {
  group('isValidMapCoordinate', () {
    test('rejects null island sentinel', () {
      expect(isValidMapCoordinate(0, 0), isFalse);
    });

    test('accepts normal coordinates', () {
      expect(isValidMapCoordinate(37.7749, -122.4194), isTrue);
      expect(isValidMapCoordinate(-33.8688, 151.2093), isTrue);
    });

    test('rejects out of range coordinates', () {
      expect(isValidMapCoordinate(91, 0), isFalse);
      expect(isValidMapCoordinate(0, 181), isFalse);
      expect(isValidMapCoordinate(-91, 0), isFalse);
      expect(isValidMapCoordinate(0, -181), isFalse);
    });
  });
}

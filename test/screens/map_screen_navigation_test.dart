import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/screens/map_screen.dart';

void main() {
  test('pushed map allows route back navigation', () {
    expect(mapScreenAllowsBack(hideBackButton: false), isTrue);
  });

  test('embedded map keeps route back navigation disabled', () {
    expect(mapScreenAllowsBack(hideBackButton: true), isFalse);
  });
}

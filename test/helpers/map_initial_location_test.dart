import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_connector.dart';
import 'package:gulf_coast_mesh_app/helpers/map_initial_location.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('syncMapCenterFromConnector', () {
    test('returns null when connector has no self location', () {
      final connector = MeshCoreConnector();
      expect(syncMapCenterFromConnector(connector), isNull);
    });
  });

  group('map location constants', () {
    test('fallback center is a valid coordinate', () {
      expect(kFallbackMapCenter, isA<LatLng>());
      expect(kFallbackMapCenter.latitude, 20.0);
      expect(kFallbackMapCenter.longitude, 0.0);
    });

    test('zoom constants are sensible', () {
      expect(kUserLocationZoom, greaterThan(kWorldZoom));
    });
  });
}

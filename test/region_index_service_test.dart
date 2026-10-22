import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:gulf_coast_mesh_app/models/region_boundary.dart';
import 'package:gulf_coast_mesh_app/services/region_index_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(RegionIndexService.debugResetCache);

  group('RegionIndexService', () {
    test(
      'loads the complete locally bundled docs catalog and embedded geometry',
      () async {
        final catalog = await RegionIndexService.load();

        expect(catalog.title, 'Emerald Coast Mesh Regions');
        expect(catalog.version, 1);
        expect(catalog.regions, hasLength(82));
        expect(catalog.uniqueGeometryCount, 76);
        expect(catalog.initiallyVisible, isNotEmpty);
        expect(
          catalog.regions.every(
            (region) =>
                region.geometryUrl.startsWith('https://') &&
                region.polygons.isNotEmpty,
          ),
          isTrue,
        );
        expect(catalog.policy['areas'], hasLength(9));
        expect(catalog.canonicalRegionId('gc'), 'us-gc');
        expect(catalog.canonicalRegionId('us-la-msy-mm'), 'us-la-msy');
        expect(catalog.canonicalRegionId('gc-la-msy-mm'), 'us-la-msy');
        expect(
          catalog.regions.map((region) => region.id),
          contains('us-al-dya'),
        );
      },
    );

    test('loads a Gulf Coast boundary that contains Baton Rouge', () async {
      final catalog = await RegionIndexService.load();
      final gulfCoast = catalog.regions.singleWhere(
        (region) => region.id == 'us-gc',
      );
      final batonRouge = const LatLng(30.4515, -91.1871);

      expect(gulfCoast.initiallyVisible, isFalse);
      expect(gulfCoast.containsPoint(batonRouge), isTrue);
    });
  });

  group('GeoJsonPolygon', () {
    test(
      'point containment respects holes and includes the outer boundary',
      () {
        const polygon = GeoJsonPolygon([
          [
            LatLng(0, 0),
            LatLng(0, 10),
            LatLng(10, 10),
            LatLng(10, 0),
            LatLng(0, 0),
          ],
          [
            LatLng(4, 4),
            LatLng(4, 6),
            LatLng(6, 6),
            LatLng(6, 4),
            LatLng(4, 4),
          ],
        ]);

        expect(polygon.containsPoint(const LatLng(2, 2)), isTrue);
        expect(polygon.containsPoint(const LatLng(5, 5)), isFalse);
        expect(polygon.containsPoint(const LatLng(4, 5)), isTrue);
        expect(polygon.containsPoint(const LatLng(0, 5)), isTrue);
      },
    );
    test('handles Alaska geometry across the antimeridian', () {
      const polygon = GeoJsonPolygon([
        [
          LatLng(60, -187),
          LatLng(60, -170),
          LatLng(70, -170),
          LatLng(70, -187),
          LatLng(60, -187),
        ],
      ]);
      expect(polygon.containsPoint(const LatLng(65, 175)), isTrue);
      expect(polygon.containsPoint(const LatLng(65, -175)), isTrue);
      expect(polygon.containsPoint(const LatLng(65, 160)), isFalse);
    });
  });
}

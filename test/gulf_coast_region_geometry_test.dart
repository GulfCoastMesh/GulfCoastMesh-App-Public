import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:gulf_coast_mesh_app/helpers/gulf_coast_region_geometry.dart';
import 'package:gulf_coast_mesh_app/models/gulf_coast_region_tree.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GulfCoastRegionTree drill helpers', () {
    test('hasSimpleChildren true for us-la, false for us-la-msy', () {
      final la = GulfCoastRegionTree.find('us-la')!;
      final msy = GulfCoastRegionTree.find('us-la-msy')!;
      expect(GulfCoastRegionTree.hasSimpleChildren(la), isTrue);
      expect(GulfCoastRegionTree.hasSimpleChildren(msy), isFalse);
    });

    test('simpleChildrenOf us-la returns metros', () {
      final codes = GulfCoastRegionTree.simpleChildrenOf(
        'us-la',
      ).map((n) => n.code).toList();
      expect(codes, containsAll(['us-la-msy', 'us-la-lft', 'us-la-lc']));
    });

    test('simplePicker excludes us', () {
      final codes = GulfCoastRegionTree.simplePickerNodes.map((n) => n.code);
      expect(codes, isNot(contains('us')));
      expect(codes, isNot(contains('us-southeast')));
    });
  });

  group('GulfCoastRegionGeometry', () {
    setUp(() {
      GulfCoastRegionGeometry.debugSetCache(null);
    });

    tearDown(() {
      GulfCoastRegionGeometry.debugSetCache(null);
    });

    test('load provides rings for all simple map codes', () async {
      final map = await GulfCoastRegionGeometry.load();
      for (final code in [
        'us-gc',
        'us-la',
        'us-la-msy',
        'us-la-lft',
        'us-la-lc',
        'us-ms',
        'us-ms-gpt',
        'us-pns',
      ]) {
        expect(map.containsKey(code), isTrue, reason: code);
        expect(map[code]!.isNotEmpty, isTrue, reason: code);
        expect(map[code]!.first.length, greaterThanOrEqualTo(3), reason: code);
      }
    });

    test('dissolved rings are outer silhouettes not parish grids', () async {
      final map = await GulfCoastRegionGeometry.load();
      // Louisiana's statewide boundary retains its offshore islands.
      expect(map['us-gc']!.length, lessThanOrEqualTo(10));
      expect(map['us-la']!.length, lessThanOrEqualTo(10));
      expect(map['us-la-msy']!.length, lessThanOrEqualTo(2));
      expect(map['us-la-lft']!.length, lessThanOrEqualTo(3));
      expect(map['us-la-lc']!.length, equals(1));
      expect(map['us-ms']!.length, lessThanOrEqualTo(4));
      expect(map['us-ms-gpt']!.length, lessThanOrEqualTo(5));
      expect(map['us-pns']!.length, equals(1));
    });

    test('containsPoint downtown NOLA is inside us-la-msy', () async {
      await GulfCoastRegionGeometry.load();
      final msy = GulfCoastRegionTree.find('us-la-msy')!;
      expect(
        GulfCoastRegionTree.containsPoint(msy, const LatLng(29.95, -90.07)),
        isTrue,
      );
      expect(
        GulfCoastRegionTree.containsPoint(msy, const LatLng(40.0, -90.0)),
        isFalse,
      );
    });

    test('injected cache works without asset', () {
      GulfCoastRegionGeometry.debugSetCache({
        'us-la-msy': [
          [
            const LatLng(29.8, -90.2),
            const LatLng(30.1, -90.2),
            const LatLng(30.1, -89.8),
            const LatLng(29.8, -89.8),
          ],
        ],
      });
      expect(
        GulfCoastRegionGeometry.containsPoint(
          GulfCoastRegionGeometry.ringsFor('us-la-msy'),
          const LatLng(29.95, -90.0),
        ),
        isTrue,
      );
    });
  });
}

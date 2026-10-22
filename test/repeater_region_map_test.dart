import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:gulf_coast_mesh_app/screens/region_index_map_screen.dart';
import 'package:gulf_coast_mesh_app/services/map_tile_cache_service.dart';
import 'package:gulf_coast_mesh_app/services/region_index_service.dart';

void main() {
  Future<void> openPicker(
    WidgetTester tester, {
    ValueChanged<List<String>?>? onSelected,
  }) async {
    await tester.runAsync(RegionIndexService.load);
    await tester.pumpWidget(
      Provider<MapTileCacheService>.value(
        value: MapTileCacheService(),
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  final selected = await Navigator.push<List<String>>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RegionIndexMapScreen(
                        selectForRepeater: true,
                        initialLocation: LatLng(30.4515, -91.1871),
                      ),
                    ),
                  );
                  onSelected?.call(selected);
                },
                child: const Text('Open picker'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open picker'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.runAsync(() async {
      await tester.pump();
    });
    await tester.pump();
  }

  testWidgets('returns all location codes even with every map layer hidden', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    List<String>? result;
    await openPicker(tester, onSelected: (codes) => result = codes);

    await tester.tap(find.byTooltip('Choose region layers'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('None'));
    Navigator.of(tester.element(find.text('None'))).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Use this location'));
    await tester.pumpAndSettle();
    expect(find.text('us-la-msy'), findsOneWidget);
    await tester.ensureVisible(find.text('Use these regions'));
    await tester.tap(find.text('Use these regions'));
    await tester.pumpAndSettle();

    expect(result, [
      'us',
      'us-east',
      'us-gc',
      'us-la',
      'us-la-msy',
      'us-south',
      'us-southeast',
    ]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('coordinates validate and unsupported locations cannot apply', (
    tester,
  ) async {
    await openPicker(tester);
    await tester.tap(find.byTooltip('Enter coordinates'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '91');
    await tester.tap(find.text('Find regions'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a number from -90 to 90'), findsOneWidget);

    await tester.enterText(fields.at(0), '0');
    await tester.enterText(fields.at(1), '0');
    await tester.tap(find.text('Find regions'));
    await tester.pumpAndSettle();
    expect(find.textContaining('No approved regions found.'), findsOneWidget);
    expect(find.text('Use these regions'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a map tap looks up the clicked point', (tester) async {
    await openPicker(tester);
    // Tap the actual map rather than the initial repeater-location button.
    final map = find.byType(FlutterMap);
    await tester.tapAt(tester.getCenter(map) + const Offset(40, 40));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    expect(find.text('us-la-msy'), findsOneWidget);
    expect(find.text('Use these regions'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

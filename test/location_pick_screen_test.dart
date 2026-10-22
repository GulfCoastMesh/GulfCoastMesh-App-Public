import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_connector.dart';
import 'package:gulf_coast_mesh_app/helpers/tactical_map_payload.dart';
import 'package:gulf_coast_mesh_app/l10n/app_localizations.dart';
import 'package:gulf_coast_mesh_app/screens/location_pick_screen.dart';
import 'package:gulf_coast_mesh_app/services/map_tile_cache_service.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestApp(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MeshCoreConnector>(
          create: (_) => MeshCoreConnector(),
        ),
        Provider<MapTileCacheService>(create: (_) => MapTileCacheService()),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );
  }

  testWidgets('LocationPickScreen renders map hint and name field', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestApp(const LocationPickScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Send waypoint'), findsOneWidget);
    expect(find.text('Tap the map to place a waypoint'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.my_location), findsOneWidget);
    expect(find.byType(FlutterMap), findsOneWidget);
  });

  test('waypoint share payload round-trips as wp tactical POI', () {
    const lat = 48.858400;
    const lon = 2.294500;
    final timestamp =
        DateTime.utc(2026, 6, 11, 12, 0, 0).millisecondsSinceEpoch ~/ 1000;

    final payload = TacticalMapPayload.formatPoi(
      lat: lat,
      lon: lon,
      timestampSeconds: timestamp,
      label: 'Meet here',
      type: 'wp',
    );

    final parsed = TacticalMapPayload.tryParse(payload);
    expect(parsed, isA<TacticalPoiMarker>());
    final poi = parsed! as TacticalPoiMarker;
    expect(poi.type, 'wp');
    expect(poi.label, 'Meet here');
    expect(poi.lat, closeTo(lat, 0.000001));
    expect(poi.lon, closeTo(lon, 0.000001));
  });
}

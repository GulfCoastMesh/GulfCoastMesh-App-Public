import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_connector.dart';
import 'package:gulf_coast_mesh_app/l10n/app_localizations.dart';
import 'package:gulf_coast_mesh_app/screens/region_scope_picker_screen.dart';
import 'package:gulf_coast_mesh_app/services/map_tile_cache_service.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget wrap(Widget home) {
    final connector = MeshCoreConnector();
    final tileCache = MapTileCacheService();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MeshCoreConnector>.value(value: connector),
        Provider<MapTileCacheService>.value(value: tileCache),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: home,
      ),
    );
  }

  testWidgets('RegionScopePickerScreen lays out without errors', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const RegionScopePickerScreen(
          promptSubtitle: 'Choose where messages can flood',
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.takeException(), isNull);
    expect(find.text('Region scope'), findsOneWidget);
    expect(find.text('Set scope'), findsOneWidget);
  });

  testWidgets('RegionScopePickerScreen pushes via route on small screen', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      wrap(
        Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push<String?>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RegionScopePickerScreen(
                          promptSubtitle: 'Choose where messages can flood',
                        ),
                      ),
                    );
                  },
                  child: const Text('open'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.takeException(), isNull);
    expect(find.text('Set scope'), findsOneWidget);
    expect(find.text('Louisiana'), findsWidgets);
  });

  testWidgets('legacy MSY selection returns the current send scope', (
    tester,
  ) async {
    String? selected;
    await tester.pumpWidget(
      wrap(
        Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                selected = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RegionScopePickerScreen(
                      initialScope: 'gc-la-msy-mm',
                    ),
                  ),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('us-la-msy'), findsWidgets);
    await tester.tap(find.text('Set scope'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(selected, 'us-la-msy');
    expect(tester.takeException(), isNull);
  });
}

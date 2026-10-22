import 'package:image/image.dart' as image;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_connector.dart';
import 'package:gulf_coast_mesh_app/helpers/demo_weather_api2.dart';
import 'package:gulf_coast_mesh_app/screens/weather_screen.dart';
import 'package:gulf_coast_mesh_app/services/map_tile_cache_service.dart';
import 'package:gulf_coast_mesh_app/services/weather_api_service.dart';
import 'package:gulf_coast_mesh_app/widgets/weather_radar_panel.dart';
import 'package:provider/provider.dart';

import '../support/fake_weather_connector.dart';
import '../support/weather_api2_fixtures.dart';

class _Tiles extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) =>
      MemoryImage(image.encodePng(image.Image(width: 1, height: 1)));
}

class _MapCache implements MapTileCacheService {
  @override
  final TileProvider tileProvider = _Tiles();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late FakeWeatherConnector connector;
  late WeatherApiService weather;
  setUp(() {
    connector = FakeWeatherConnector();
    weather = WeatherApiService(connector);
    connector.onSend = (request) {
      for (final reply in demoWeatherApi2Replies(request)) {
        connector.emit(reply);
      }
    };
  });
  tearDown(() {
    weather.dispose();
    connector.dispose();
  });

  Future<void> mount(
    WidgetTester tester, {
    Size size = const Size(390, 1000),
    Brightness brightness = Brightness.light,
    double textScale = 1,
    bool settle = true,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<WeatherApiService>.value(value: weather),
          ChangeNotifierProvider<MeshCoreConnector>.value(value: connector),
          Provider<MapTileCacheService>.value(value: _MapCache()),
        ],
        child: MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: brightness,
            ),
          ),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
          home: const WeatherScreen(isTabActive: true),
        ),
      ),
    );
    if (settle) await tester.pumpAndSettle();
  }

  testWidgets('loading and timeout use plain language and retry works', (
    tester,
  ) async {
    connector.onSend = (_) {};
    await mount(tester, settle: false);
    await tester.pump();
    expect(find.text('Waiting on response'), findsOneWidget);
    expect(find.textContaining('bot'), findsNothing);
    await tester.pump(const Duration(seconds: 61));
    await tester.pumpAndSettle();
    expect(find.text('No response yet. Try again.'), findsOneWidget);
    connector.onSend = (request) {
      for (final reply in demoWeatherApi2Replies(request)) {
        connector.emit(reply);
      }
    };
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(weather.status, WeatherStatus.ready);
    expect(find.text('Bot & Reports'), findsNothing);
  });

  testWidgets(
    'current-only weather can be refreshed without requesting a forecast',
    (tester) async {
      connector.onSend = (request) {
        if (request == 'bot api2') {
          connector.emit(
            positional(2, [
              2,
              [140, 16],
              ['F', 'mph', '%'],
            ]),
          );
        } else {
          for (final reply in demoWeatherApi2Replies(request)) {
            connector.emit(reply);
          }
        }
      };
      await mount(tester);
      await tester.enterText(find.byType(TextField).first, '00601');
      await tester.tap(find.text('Get weather'));
      await tester.pumpAndSettle();
      expect(weather.currentSummary, isNotNull);
      await tester.tap(find.byTooltip('Refresh weather'));
      await tester.pumpAndSettle();
      expect(connector.sent.last, 'wx 00601 api2');
      expect(connector.sent.where((s) => s.contains(' all ')), isEmpty);
    },
  );

  testWidgets('failed refresh keeps the last weather visible', (tester) async {
    await mount(tester);
    await tester.enterText(find.byType(TextField).first, '00601');
    await tester.tap(find.text('Get weather'));
    await tester.pumpAndSettle();
    final previous = weather.report;
    connector.onSend = (_) {};
    await tester.tap(find.byTooltip('Refresh weather'));
    await tester.pump();
    expect(find.text('Waiting on response'), findsOneWidget);
    expect(find.text('ZIP 00601'), findsOneWidget);
    await tester.pump(const Duration(seconds: 61));
    await tester.pumpAndSettle();
    expect(weather.report, same(previous));
    expect(find.text('No response yet. Try again.'), findsOneWidget);
    connector.onSend = (request) {
      for (final reply in demoWeatherApi2Replies(request)) {
        connector.emit(reply);
      }
    };
    await tester.tap(find.byTooltip('Refresh weather'));
    await tester.pumpAndSettle();
    expect(weather.status, WeatherStatus.ready);
    expect(weather.errorMessage, isNull);
  });

  for (final brightness in Brightness.values) {
    for (final width in [390.0, 1100.0]) {
      testWidgets('weather fits $brightness at $width with larger text', (
        tester,
      ) async {
        await mount(
          tester,
          size: Size(width, 1100),
          brightness: brightness,
          textScale: 1.6,
        );
        await tester.enterText(find.byType(TextField).first, '00601');
        await tester.tap(find.text('Get weather'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.drag(find.byType(ListView).first, const Offset(0, -650));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('Radar'));
        await tester.pumpAndSettle();
        await tester.dragFrom(
          tester.getTopLeft(find.byType(ListView).last) + const Offset(4, 700),
          const Offset(0, -900),
        );
        await tester.pumpAndSettle();
        expect(find.text('What the colors mean'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets(
    'forecast shows feels-like and remains editable after a bad ZIP',
    (tester) async {
      await mount(tester);
      await tester.enterText(find.byType(TextField).first, '00601');
      await tester.tap(find.text('Get weather'));
      await tester.pumpAndSettle();
      expect(find.text('ZIP 00601'), findsOneWidget);
      expect(find.text('Feels like 89°F'), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, '123');
      await tester.tap(find.text('Get weather'));
      await tester.pumpAndSettle();
      expect(
        find.text('Enter a valid five-digit U.S. ZIP code.'),
        findsOneWidget,
      );
      expect(
        tester.widget<TextField>(find.byType(TextField).first).enabled,
        true,
      );
      expect(find.text('ZIP 00601'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('temperature control switches the forecast between F and C', (
    tester,
  ) async {
    await mount(tester);
    await tester.enterText(find.byType(TextField).first, '00601');
    await tester.tap(find.text('Get weather'));
    await tester.pumpAndSettle();

    expect(find.text('84°F'), findsWidgets);
    await tester.tap(find.text('°C'));
    await tester.pumpAndSettle();
    expect(find.text('29°C'), findsWidgets);
    expect(find.text('84°F'), findsNothing);

    await tester.tap(find.text('°F'));
    await tester.pumpAndSettle();
    expect(find.text('84°F'), findsWidgets);
  });

  testWidgets(
    'radar selection sends nothing until Load and renders a complete grid',
    (tester) async {
      await mount(tester);
      await tester.tap(find.text('Radar'));
      await tester.pumpAndSettle();
      expect(connector.sent, ['bot api2']);
      expect(find.byType(TextField), findsNothing);
      await tester.tapAt(tester.getCenter(find.byType(FlutterMap)));
      await tester.pump(const Duration(milliseconds: 350));
      expect(connector.sent, ['bot api2']);
      await tester.ensureVisible(find.text('Load radar'));
      await tester.tap(find.text('Load radar'));
      await tester.pumpAndSettle();
      expect(connector.sent.last, startsWith('wx radar '));
      expect(connector.sent.last, endsWith(' now api2'));
      expect(find.textContaining('Recorded weather'), findsOneWidget);
      expect(weather.radar!['c'], hasLength(812));
      final sends = connector.sent.length;
      await tester.ensureVisible(find.byTooltip('Next hour'));
      await tester.tap(find.byTooltip('Next hour'));
      await tester.pumpAndSettle();
      expect(find.text('In 1 hour'), findsOneWidget);
      expect(connector.sent, hasLength(sends));
      expect(
        find.text('Place or time changed. Load radar to see your selection.'),
        findsOneWidget,
      );
      await tester.ensureVisible(find.text('Load radar'));
      await tester.tap(find.text('Load radar'));
      await tester.pumpAndSettle();
      expect(connector.sent.last, endsWith(' +1h api2'));
      expect(
        find.text('Place or time changed. Load radar to see your selection.'),
        findsNothing,
      );
      await tester.ensureVisible(find.text('Back to now'));
      await tester.tap(find.text('Back to now'));
      await tester.pumpAndSettle();
      expect(find.text('Now'), findsOneWidget);
      expect(connector.sent, hasLength(sends + 1));

      expect(tester.takeException(), isNull);
    },
  );

  test('radar captions use product times and identify model guidance', () {
    final radar = decodeFrames([forecastRadarVector]);
    final caption = weatherRadarCaption(radar);
    expect(caption, contains('Expected weather'));
    expect(caption, contains('An estimate of what may happen'));
    expect(caption, contains('local time'));
    final observed = decodeFrames(observedRadarVectors);
    expect(
      weatherRadarCaption(observed),
      isNot(contains('An estimate of what may happen')),
    );
  });

  test(
    'radar placement is north-up and preserves missing versus dry cells',
    () {
      final north = weatherRadarPoint(30, -91, 0, 80.4672);
      final east = weatherRadarPoint(30, -91, 80.4672, 0);
      expect(north.latitude, greaterThan(30));
      expect(north.longitude, closeTo(-91, 0.00001));
      expect(east.longitude, greaterThan(-91));
      final radar = decodeFrames([forecastRadarVector]);
      final polygons = weatherRadarPolygons(radar);
      expect(
        polygons,
        hasLength(812 - 102),
      ); // Dry cells alone are transparent.
      expect(
        polygons.where((p) => p.color == weatherRadarColors[7]),
        isNotEmpty,
      );
    },
  );

  test('demo supports every API2 operation, including signed radar hours', () {
    for (final command in [
      'bot api2',
      'wx help api2',
      'wx version api2',
      'wx 00601 api2',
      'wx 00601 all api2',
      'ping api2',
      'wx report 00601 api2',
      'wx report stop api2',
      for (var hour = -5; hour <= 5; hour++)
        'wx radar 30.4515 -91.1871 ${hour == 0 ? 'now' : '${hour > 0 ? '+' : ''}${hour}h'} api2',
    ]) {
      final frames = demoWeatherApi2Replies(command, dm: true);
      expect(frames.length, lessThanOrEqualTo(4));
      expect(frames.every((f) => f.length <= 139), true);
      expect(decodeFrames(frames)['k'], isNot('e'), reason: command);
    }
  });
}

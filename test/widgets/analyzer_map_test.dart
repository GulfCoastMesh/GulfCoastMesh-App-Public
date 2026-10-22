import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:latlong2/latlong.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_connector.dart';
import 'package:gulf_coast_mesh_app/helpers/map_initial_location.dart';
import 'package:gulf_coast_mesh_app/l10n/app_localizations.dart';
import 'package:gulf_coast_mesh_app/models/contact.dart';
import 'package:gulf_coast_mesh_app/services/atak_location_broadcast_service.dart';
import 'package:gulf_coast_mesh_app/services/map_tile_cache_service.dart';
import 'package:gulf_coast_mesh_app/services/mesh_analyzer_state.dart';
import 'package:gulf_coast_mesh_app/widgets/analyzer_map.dart';
import 'package:gulf_coast_mesh_app/widgets/analyzer_map_overlays.dart';
import 'package:gulf_coast_mesh_app/screens/mesh_analyzer_screen.dart';
import 'package:gulf_coast_mesh_app/models/channel.dart';
import 'package:gulf_coast_mesh_app/models/channel_message.dart';
import 'package:gulf_coast_mesh_app/models/message.dart';
import 'package:gulf_coast_mesh_app/models/analyzer_packet.dart';
import 'package:gulf_coast_mesh_app/theme/app_theme.dart';
import 'package:provider/provider.dart';

class _Connector extends ChangeNotifier implements MeshCoreConnector {
  @override
  List<Contact> contacts = [];
  @override
  bool isLoadingContacts = false;
  @override
  double? selfLatitude;
  @override
  double? selfLongitude;
  @override
  Stream<Uint8List> get receivedFrames => const Stream.empty();
  @override
  List<Channel> channels = [];
  @override
  List<ChannelMessage> getChannelMessages(Channel channel) => [
    ChannelMessage(
      senderName: 'Bay Station',
      text: 'Good signal across the coast.',
      timestamp: DateTime(2026),
      isOutgoing: false,
    ),
  ];
  @override
  int getUnreadCountForChannel(Channel channel) => 0;
  @override
  List<Message> getMessages(Contact contact) => [];
  void update() => notifyListeners();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Broadcast extends ChangeNotifier
    implements AtakLocationBroadcastService {
  @override
  double? phoneLat;
  @override
  double? phoneLon;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

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

Contact _contact(double lat, double lon) => Contact(
  publicKey: Uint8List(32),
  name: 'Node',
  type: 1,
  pathLength: -1,
  path: Uint8List(0),
  lastSeen: DateTime(2026),
  latitude: lat,
  longitude: lon,
);

void main() {
  late _Connector connector;
  late _Broadcast broadcast;
  late MeshAnalyzerState analyzer;

  setUp(() {
    connector = _Connector();
    broadcast = _Broadcast();
    analyzer = MeshAnalyzerState();
  });
  tearDown(() {
    connector.dispose();
    broadcast.dispose();
    analyzer.dispose();
  });

  Future<MapController> mount(
    WidgetTester tester, {
    bool reducedMotion = false,
    bool active = true,
    bool fullPage = false,
    Brightness brightness = Brightness.light,
    double textScale = 1,
  }) async {
    if (const bool.fromEnvironment('ANALYZER_SCREENSHOTS')) {
      await tester.runAsync(() async {
        final font = FontLoader('Inter')
          ..addFont(rootBundle.load('assets/fonts/Inter-Variable.ttf'));
        await font.load();
        final icons = FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
        await icons.load();
      });
    }
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(
          'dev.flutter.pigeon.wakelock_plus_platform_interface.WakelockPlusApi.toggle',
          (message) async =>
              const StandardMessageCodec().encodeMessage(<Object?>[null]),
        );
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<MeshCoreConnector>.value(value: connector),
          ChangeNotifierProvider<AtakLocationBroadcastService>.value(
            value: broadcast,
          ),
          ChangeNotifierProvider<MeshAnalyzerState>.value(value: analyzer),
          Provider<MapTileCacheService>.value(value: _MapCache()),
        ],
        child: MaterialApp(
          theme: brightness == Brightness.dark
              ? AppTheme.dark()
              : AppTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MediaQuery(
            data: MediaQueryData(
              disableAnimations: reducedMotion,
              textScaler: TextScaler.linear(textScale),
            ),
            child: TickerMode(
              enabled: active,
              child: RepaintBoundary(
                key: const ValueKey('analyzer-preview'),
                child: fullPage
                    ? MeshAnalyzerScreen(isTabActive: active)
                    : const Scaffold(
                        body: SizedBox(
                          width: 360,
                          height: 400,
                          child: AnalyzerMap(),
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    return tester.widget<FlutterMap>(find.byType(FlutterMap)).mapController!;
  }

  Finder marker(Contact contact) =>
      find.byKey(ValueKey('analyzer-node-${contact.publicKeyHex}'));
  final card = find.byKey(const ValueKey('analyzer-node-card'));

  testWidgets(
    'names stay hidden until selected; selection updates and dismisses',
    (tester) async {
      final first = _contact(29, -95);
      final second = _contact(29.15, -95).copyWith(
        publicKey: Uint8List.fromList(List.filled(32, 1)),
        name: 'Second',
      );
      connector.contacts = [first, second];
      await mount(tester);
      expect(find.text('Node'), findsNothing);
      await tester.tap(marker(first));
      await tester.pumpAndSettle();
      expect(card, findsOneWidget);
      expect(find.text('Node'), findsOneWidget);
      connector.contacts[0] = first.copyWith(name: 'Updated');
      connector.update();
      await tester.pump();
      expect(find.text('Updated'), findsOneWidget);
      await tester.tap(marker(first));
      await tester.pumpAndSettle();
      expect(card, findsNothing);
      await tester.tap(marker(second));
      await tester.pumpAndSettle();
      expect(find.text('Second'), findsOneWidget);
      connector.contacts.removeLast();
      connector.update();
      await tester.pumpAndSettle();
      expect(card, findsNothing);
      await tester.tap(find.byTooltip('Show node names'));
      await tester.pumpAndSettle();
      expect(find.text('Updated'), findsOneWidget);
      await tester.tap(find.byTooltip('Hide node names'));
      await tester.pumpAndSettle();
      expect(find.text('Updated'), findsNothing);
    },
  );

  testWidgets(
    'card stays in map bounds while panning and closes on background tap',
    (tester) async {
      final node = _contact(29, -95);
      connector.contacts = [node];
      final controller = await mount(tester, textScale: 2);
      await tester.tap(marker(node));
      await tester.pumpAndSettle();
      final mapRect = tester.getRect(find.byType(FlutterMap));
      for (final offset in [const Offset(25, 25), const Offset(335, 370)]) {
        final camera = controller.camera;
        final center = camera.screenOffsetToLatLng(
          camera.latLngToScreenOffset(const LatLng(29, -95)) +
              Offset(mapRect.width / 2, mapRect.height / 2) -
              offset,
        );
        controller.move(center, camera.zoom);
        await tester.pumpAndSettle();
        final bounds = tester.getRect(card);
        expect(mapRect.contains(bounds.topLeft), isTrue);
        expect(mapRect.contains(bounds.bottomRight), isTrue);
        expect(tester.takeException(), isNull);
      }
      final cardRect = tester.getRect(card);
      final background =
          [const Offset(15, 15), const Offset(345, 15), const Offset(15, 350)]
              .map((offset) => mapRect.topLeft + offset)
              .firstWhere((point) => !cardRect.contains(point));
      await tester.tapAt(background);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(card, findsNothing);
    },
  );

  AnimatedPath path(int index) => AnimatedPath(
    points: [const LatLng(29, -95), LatLng(29.01 + index * .001, -95)],
    createdAt: DateTime.now(),
    packetType: AnalyzerPacketType.channel,
    label: '$index',
  );

  testWidgets('traffic ticker respects reduced motion and hidden screens', (
    tester,
  ) async {
    connector.contacts = [_contact(29, -95)];
    analyzer.addAnimatedPath(path(0));
    await mount(tester);
    await tester.pump(const Duration(milliseconds: 40));
    expect(tester.binding.hasScheduledFrame, isTrue);
    await mount(tester, active: false);
    await tester.pump(const Duration(seconds: 1));
    expect(tester.binding.hasScheduledFrame, isFalse);
    await mount(tester, reducedMotion: true);
    await tester.pump(const Duration(seconds: 1));
    expect(tester.binding.hasScheduledFrame, isFalse);
    final painter = tester
        .widgetList<CustomPaint>(find.byType(CustomPaint))
        .map((w) => w.painter)
        .whereType<AnalyzerTrafficPainter>()
        .single;
    expect(painter.reducedMotion, isTrue);
    analyzer.clearPaths();
    await tester.pumpAndSettle();
  });

  testWidgets(
    'auto follow sees arrivals at the path cap and manual pan cancels it',
    (tester) async {
      connector.contacts = [_contact(29, -95)];
      for (var i = 0; i < 20; i++) {
        analyzer.addAnimatedPath(path(i));
      }
      final controller = await mount(tester);
      analyzer.toggleAutoZoom();
      analyzer.addAnimatedPath(path(21));
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      expect(controller.camera.zoom, greaterThan(10));
      final options = tester
          .widget<FlutterMap>(find.byType(FlutterMap))
          .options;
      options.onPositionChanged!(controller.camera, true);
      controller.move(const LatLng(30, -94), 9);
      await tester.pump(const Duration(seconds: 3));
      expect(controller.camera.center, const LatLng(30, -94));
      expect(controller.camera.zoom, 9);
      analyzer.clearPaths();
      await tester.pumpAndSettle();
    },
  );

  for (final size in [const Size(360, 740), const Size(1280, 800)]) {
    for (final brightness in Brightness.values) {
      testWidgets('page layout $size $brightness', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        connector.contacts = [_contact(29, -95)];
        await mount(
          tester,
          fullPage: true,
          brightness: brightness,
          textScale: 1.5,
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.tap(find.byTooltip('Full screen'));
        await tester.pumpAndSettle();
        expect(analyzer.isFullScreen, isTrue);
        await tester.tap(marker(connector.contacts.first));
        await tester.pumpAndSettle();
        expect(card, findsOneWidget);
        expect(tester.takeException(), isNull);
        connector.channels = [
          Channel(index: 0, name: 'Gulf Coast', psk: Uint8List(16)),
        ];
        connector.update();
        for (var i = 0; i < 5; i++) {
          analyzer.addPacket(
            AnalyzerPacket(
              timestamp: DateTime.now(),
              type: AnalyzerPacketType.channel,
              senderName: 'Bay Station',
              snr: 7.5,
              rssi: -94,
              hopCount: 3,
              pathBytes: Uint8List(0),
              routeType: AnalyzerRouteType.flood,
              payloadType: 5,
              rawHex: '05',
            ),
          );
        }
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        if (const bool.fromEnvironment('ANALYZER_SCREENSHOTS')) {
          analyzer.addAnimatedPath(path(0));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 1200));
          final boundary = tester.renderObject<RenderRepaintBoundary>(
            find.byKey(const ValueKey('analyzer-preview')),
          );
          await tester.runAsync(() async {
            final pixels = await boundary.toImage();
            final bytes = await pixels.toByteData(
              format: ui.ImageByteFormat.png,
            );
            await File(
              '/tmp/analyzer-${size.width.toInt()}-${brightness.name}.png',
            ).writeAsBytes(bytes!.buffer.asUint8List());
            pixels.dispose();
          });
        }
        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
  }

  testWidgets('frames located contacts and preserves subsequent camera moves', (
    tester,
  ) async {
    connector.contacts = [_contact(29, -95), _contact(31, -89), _contact(0, 0)];
    final controller = await mount(tester);
    expect(
      controller.camera.visibleBounds.contains(const LatLng(29, -95)),
      isTrue,
    );
    expect(
      controller.camera.visibleBounds.contains(const LatLng(31, -89)),
      isTrue,
    );
    expect(controller.camera.zoom, greaterThan(kWorldZoom));
    controller.move(const LatLng(35, -100), 8);
    connector.update();
    await tester.pump();
    expect(controller.camera.center, const LatLng(35, -100));
    expect(controller.camera.zoom, 8);
  });

  testWidgets('waits for contact loading and retries an empty overview', (
    tester,
  ) async {
    final controller = await mount(tester);
    expect(controller.camera.center, kFallbackMapCenter);
    connector.isLoadingContacts = true;
    connector.contacts = [_contact(29, -95)];
    connector.update();
    await tester.pump();
    expect(controller.camera.center, kFallbackMapCenter);
    connector.contacts.add(_contact(29, -95));
    connector.isLoadingContacts = false;
    connector.update();
    await tester.pump();
    expect(controller.camera.center, const LatLng(29, -95));
    expect(controller.camera.zoom, 10);
  });

  testWidgets('fits widely separated nodes on a compact map', (tester) async {
    connector.contacts = [_contact(-35, -150), _contact(60, 130)];
    final controller = await mount(tester);
    for (final contact in connector.contacts) {
      expect(
        controller.camera.visibleBounds.contains(
          LatLng(contact.latitude!, contact.longitude!),
        ),
        isTrue,
      );
    }
  });

  testWidgets('prefers phone GPS over node and contacts', (tester) async {
    broadcast.phoneLat = 32;
    broadcast.phoneLon = -90;
    connector.selfLatitude = 30;
    connector.selfLongitude = -95;
    connector.contacts = [_contact(29, -95)];
    final controller = await mount(tester);
    expect(controller.camera.center, const LatLng(32, -90));
    expect(controller.camera.zoom, 10);
  });

  testWidgets('uses node location when phone GPS is invalid', (tester) async {
    broadcast.phoneLat = 0;
    broadcast.phoneLon = 0;
    connector.selfLatitude = 30;
    connector.selfLongitude = -95;
    final controller = await mount(tester);
    expect(controller.camera.center, const LatLng(30, -95));
    expect(controller.camera.zoom, 10);
  });
}

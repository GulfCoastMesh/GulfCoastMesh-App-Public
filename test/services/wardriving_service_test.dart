import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_connector.dart';
import 'package:gulf_coast_mesh_app/l10n/app_localizations.dart';
import 'package:gulf_coast_mesh_app/models/app_settings.dart';
import 'package:gulf_coast_mesh_app/models/channel.dart';
import 'package:gulf_coast_mesh_app/models/wardriving.dart';
import 'package:gulf_coast_mesh_app/models/offline_wardrive_session.dart';
import 'package:gulf_coast_mesh_app/screens/app_settings_screen.dart';
import 'package:gulf_coast_mesh_app/services/app_settings_service.dart';
import 'package:gulf_coast_mesh_app/services/background_service.dart';
import 'package:gulf_coast_mesh_app/services/meshmapper_api_service.dart';
import 'package:gulf_coast_mesh_app/services/meshmapper_queue_service.dart';
import 'package:gulf_coast_mesh_app/services/offline_wardrive_session_service.dart';
import 'package:gulf_coast_mesh_app/services/wardriving_location_service.dart';
import 'package:gulf_coast_mesh_app/services/wardriving_service.dart';
import 'package:gulf_coast_mesh_app/storage/prefs_manager.dart';
import 'package:gulf_coast_mesh_app/theme/app_theme.dart';
import 'package:gulf_coast_mesh_app/widgets/wardriving_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class _Connector extends ChangeNotifier implements MeshCoreConnector {
  final frames = StreamController<Uint8List>.broadcast(sync: true);
  final sentFrames = <Uint8List>[];
  final sentMessages = <String>[];
  bool connected = true;

  @override
  bool get isConnected => connected;
  @override
  bool get isDemoMode => false;
  @override
  Stream<Uint8List> get receivedFrames => frames.stream;
  @override
  Uint8List get selfPublicKey => Uint8List(32);
  @override
  String get selfName => 'Test radio';
  @override
  List<Channel> get channels => [
    Channel(
      index: 1,
      name: '#wardriving',
      psk: Channel.derivePskFromHashtag('#wardriving'),
    ),
  ];
  @override
  Future<void> sendFrame(
    Uint8List data, {
    String? channelSendQueueId,
    bool expectsGenericAck = false,
    void Function(bool success)? completion,
  }) async => sentFrames.add(data);
  @override
  Future<void> sendChannelMessage(
    Channel channel,
    String text, {
    bool addToLocalHistory = true,
  }) async => sentMessages.add(text);
  @override
  Future<int?> getNoiseFloor() async => -110;
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _Settings extends AppSettingsService {
  bool offline = true;
  @override
  AppSettings get settings => AppSettings(
    wardrivingDisclosureAccepted: true,
    wardrivingOfflineMode: offline,
    wardrivingBackgroundEnabled: false,
    wardrivingIntervalSec: 15,
    wardrivingDiscDropEnabled: true,
  );
}

class _SessionApi extends MeshMapperApiService {
  final uploaded = <Map<String, dynamic>>[];
  bool connected = true;

  @override
  bool get hasApiKey => true;
  @override
  bool get hasSession => connected;
  @override
  String? get sessionId => connected ? 'test-session' : null;
  @override
  String get zone => 'TEST';
  @override
  Future<({bool isValid, String? reason, String? message})> checkSessionValid({
    double? lat,
    double? lon,
  }) async => (isValid: connected, reason: null, message: null);
  @override
  Future<MeshMapperApiResponse> checkZoneStatus({
    required double lat,
    required double lon,
    required double accuracyMeters,
    required String appVersion,
  }) async =>
      const MeshMapperApiResponse(data: {'success': true, 'in_zone': true});
  @override
  Future<List<MeshMapperRepeater>> fetchRepeaters(String zone) async => [];
  @override
  Future<Map<String, dynamic>?> submitWardriveData(
    List<Map<String, dynamic>> entries,
  ) async {
    uploaded.addAll(entries);
    return {'success': true};
  }

  @override
  Future<void> disconnect() async {
    connected = false;
  }
}

class _Background extends BackgroundService {
  @override
  Future<void> finishWardriving() async {}
}

class _Sessions extends OfflineWardriveSessionService {
  final saved = <OfflineWardriveSession>[];
  @override
  Future<void> init() async {}
  @override
  List<OfflineWardriveSession> get sessions => saved;
  @override
  Future<void> save(OfflineWardriveSession session) async {
    saved.removeWhere((item) => item.id == session.id);
    saved.add(session);
  }

  @override
  OfflineWardriveSession? get(String id) =>
      saved.where((item) => item.id == id).firstOrNull;
}

DateTime Function() _testNow = DateTime.now;

Position _position(double latitude, {DateTime? timestamp}) => Position(
  latitude: latitude,
  longitude: -90,
  timestamp: timestamp ?? _testNow(),
  accuracy: 5,
  altitude: 0,
  altitudeAccuracy: 1,
  heading: 0,
  headingAccuracy: 1,
  speed: 0,
  speedAccuracy: 1,
);

Uint8List _advertFrame({int repeater = 0xA1}) {
  final advert = Uint8List(105)
    ..[100] = 0x80
    ..setRange(101, 105, 'Node'.codeUnits);
  return Uint8List.fromList([
    0x88, // PUSH_CODE_LOG_RX_DATA
    24, // 6.0 dB SNR
    0xB0, // -80 dBm RSSI
    0x11, // plain flood + ADVERT payload
    1, // one one-byte path hash
    repeater,
    ...advert,
  ]);
}

void main() {
  late _Connector connector;
  late _Settings settings;
  late MeshMapperApiService api;
  late MeshMapperQueueService queue;
  late WardrivingLocationService gps;
  late WardrivingService service;
  late StreamController<Position> positions;
  late Future<Position> Function() fix;
  double latitude = 30;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PrefsManager.reset();
    await PrefsManager.initialize();
  });

  void createService({
    DateTime Function()? now,
    bool offline = true,
    MeshMapperApiService? apiService,
    OfflineWardriveSessionService? offlineSessions,
  }) {
    _testNow = now ?? TestWidgetsFlutterBinding.ensureInitialized().clock.now;
    connector = _Connector();
    settings = _Settings()..offline = offline;
    api = apiService ?? MeshMapperApiService();
    queue = MeshMapperQueueService(apiService: api);
    positions = StreamController<Position>.broadcast(sync: true);
    latitude = 30;
    fix = () async => _position(latitude);
    gps = WardrivingLocationService(
      now: _testNow,
      checkPermission: () async => LocationPermission.whileInUse,
      isLocationServiceEnabled: () async => true,
      positionStream: (_) => positions.stream,
      currentPosition: (_) => fix(),
    );
    service = WardrivingService(
      connector: connector,
      settingsService: settings,
      apiService: api,
      queueService: queue,
      locationService: gps,
      backgroundService: _Background(),
      offlineSessionService: offlineSessions ?? _Sessions(),
      now: _testNow,
    );
  }

  Future<T> completeOperation<T>(
    WidgetTester tester,
    Future<T> operation, {
    Duration advance = Duration.zero,
  }) async {
    var completed = false;
    T? result;
    Object? failure;
    StackTrace? failureStack;
    operation.then(
      (value) {
        result = value;
        completed = true;
      },
      onError: (Object error, StackTrace stack) {
        failure = error;
        failureStack = stack;
        completed = true;
      },
    );
    await tester.pump(advance);
    // Stream cancellation can cross the binding's real/fake async zones.
    // Give both queues bounded turns without advancing additional radio ticks.
    for (var i = 0; !completed && i < 20; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 1)),
      );
      await tester.pump();
    }
    expect(completed, isTrue, reason: 'wardriving operation did not settle');
    if (failure != null) Error.throwWithStackTrace(failure!, failureStack!);
    return result as T;
  }

  Future<void> stopService(WidgetTester tester) => completeOperation(
    tester,
    service.stop(),
    advance: const Duration(seconds: 7),
  );

  tearDown(() async {
    service.dispose();
    await gps.dispose();
    queue.dispose();
    api.dispose();
    settings.dispose();
    connector.dispose();
    await connector.frames.close();
    await positions.close();
    PrefsManager.reset();
  });

  test(
    'stop checkpoints the completed sample with a real event loop',
    () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      createService(now: DateTime.now);
      expect(await service.startActive(), isTrue);
      await Future<void>.delayed(const Duration(seconds: 6));
      await service.stop().timeout(const Duration(seconds: 3));
      expect(service.sessionState, WardrivingSessionState.idle);
      expect(service.offlineSessions.single.samples, hasLength(1));
    },
  );

  testWidgets('start control remains usable before the first GPS fix', (
    tester,
  ) async {
    createService();
    await service.refreshModeAvailability();
    expect(service.availabilityFor(WardrivingMode.passive).enabled, isFalse);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: WardrivingDashboard(
              connector: connector,
              settingsService: settings,
              service: service,
            ),
          ),
        ),
      ),
    );
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Start wardrive'),
    );
    expect(button.onPressed, isNotNull);
    service.dispose();
    queue.dispose();
    await tester.pump();
  });

  testWidgets('radio notifications cannot postpone automatic pings', (
    tester,
  ) async {
    createService();
    expect(await service.startActive(), isTrue);
    await tester.pump();
    expect(connector.sentMessages, hasLength(1));
    await tester.pump(const Duration(seconds: 5));
    latitude += .001;
    for (var i = 0; i < 10; i++) {
      connector.notifyListeners();
      await tester.pump(const Duration(seconds: 1));
    }
    expect(connector.sentMessages, hasLength(2));
    await tester.pump(const Duration(seconds: 5));
    await stopService(tester);
    service.dispose();
    queue.dispose();
    await tester.pump();
  });

  testWidgets(
    'background location cannot transmit during a foreground-only pause',
    (tester) async {
      createService();
      await service.startActive();
      await tester.pump();
      await tester.pump(const Duration(seconds: 5));
      service.didChangeAppLifecycleState(AppLifecycleState.paused);
      latitude += .001;
      await tester.pump(const Duration(seconds: 20));
      positions.add(_position(latitude));
      await tester.pump();
      expect(service.sessionState, WardrivingSessionState.pausedBackground);
      expect(connector.sentMessages, hasLength(1));
      await stopService(tester);
      service.dispose();
      queue.dispose();
      await tester.pump();
    },
  );

  testWidgets(
    'stop during startup prevents a late transmit and parallel starts',
    (tester) async {
      createService();
      final pendingFix = Completer<Position>();
      fix = () => pendingFix.future;
      final starting = service.startActive();
      await tester.pump();
      expect(service.isBusy, isTrue);
      expect(await service.startPassive(), isFalse);
      final stopping = service.stop();
      pendingFix.complete(_position(latitude));
      await tester.pump();
      expect(await completeOperation(tester, starting), isFalse);
      await tester.pump();
      await completeOperation(tester, stopping);
      expect(connector.sentMessages, isEmpty);
      expect(service.isRunning, isFalse);
      expect(gps.isRunning, isFalse);
      service.dispose();
      queue.dispose();
      await tester.pump();
    },
  );

  testWidgets('concurrent manual pings share no tracking window', (
    tester,
  ) async {
    createService();
    final first = service.sendManualPing();
    await tester.pump();
    expect(await service.sendManualPing(), isFalse);
    expect(connector.sentMessages, hasLength(1));
    await tester.pump(const Duration(seconds: 5));
    expect(await completeOperation(tester, first), isTrue);
    expect(service.offlineSessions.single.samples, hasLength(1));
    expect(gps.isRunning, isFalse);
    service.dispose();
    queue.dispose();
    await tester.pump();
  });

  testWidgets('targeted trace waits for movement after an unanswered trace', (
    tester,
  ) async {
    createService();
    expect(await service.startTargeted('AA'), isTrue);
    await tester.pump();
    expect(
      connector.sentFrames.where((frame) => frame.first == 36),
      hasLength(1),
    );

    await tester.pump(const Duration(seconds: 37));
    await tester.pump();
    expect(
      connector.sentFrames.where((frame) => frame.first == 36),
      hasLength(1),
    );

    latitude += .001;
    await tester.pump(const Duration(seconds: 15));
    expect(
      connector.sentFrames.where((frame) => frame.first == 36),
      hasLength(2),
    );

    await stopService(tester);
    service.dispose();
    queue.dispose();
    await tester.pump();
  });

  testWidgets('stop waits for the sent sample and is idempotent', (
    tester,
  ) async {
    createService();
    await service.startActive();
    await tester.pump();
    final first = service.stop();
    final second = service.stop();
    latitude += .001;
    positions.add(_position(latitude));
    await tester.pump(const Duration(seconds: 7));
    await tester.pump();
    await completeOperation(tester, Future.wait([first, second]));
    expect(connector.sentMessages, hasLength(1));
    expect(service.offlineSessions.single.samples, hasLength(1));
    expect(service.sessionState, WardrivingSessionState.idle);
    service.dispose();
    queue.dispose();
    await tester.pump();
  });

  testWidgets('RX batches retain their first location and ignore stale fixes', (
    tester,
  ) async {
    createService();
    expect(await service.startPassive(), isTrue);
    await tester.pump();

    connector.frames.add(_advertFrame());
    await tester.pump();
    positions.add(_position(30.001));
    await tester.pump();
    await tester.pump();

    final rxEvents = service.mapEvents
        .where((event) => event.type == WardrivingEventType.rx)
        .toList();
    expect(rxEvents, hasLength(1));
    expect(rxEvents.single.latitude, 30);
    expect(rxEvents.single.longitude, -90);

    fix = () async => _position(
      30.002,
      timestamp: _testNow().subtract(const Duration(minutes: 10)),
    );
    await tester.pump(const Duration(seconds: 61));
    expect(service.currentLocation, isNull);
    connector.frames.add(_advertFrame(repeater: 0xA2));
    await tester.pump();
    await tester.pump(const Duration(seconds: 15));
    expect(
      service.mapEvents.where((event) => event.type == WardrivingEventType.rx),
      hasLength(1),
    );

    await stopService(tester);
    service.dispose();
    queue.dispose();
    await tester.pump();
  });

  testWidgets('online storage stays fixed through collection and stop', (
    tester,
  ) async {
    final sessionApi = _SessionApi();
    createService(offline: false, apiService: sessionApi);
    expect(await service.startPassive(), isTrue);
    await tester.pump();
    await tester.pump(const Duration(seconds: 7));

    settings.offline = true;
    settings.notifyListeners();
    latitude += .001;
    await tester.pump(const Duration(seconds: 23));
    await tester.pump(const Duration(seconds: 7));
    await stopService(tester);

    // Both samples use the online path; no unsaved offline buffer is created.
    expect(sessionApi.uploaded, hasLength(2));
    expect(service.offlineSessions, isEmpty);
    expect(service.isOfflineMode, isTrue); // next drive uses the new preference
    service.dispose();
    queue.dispose();
    await tester.pump();
  });

  testWidgets('storage mode is captured before startup awaits GPS', (
    tester,
  ) async {
    final sessionApi = _SessionApi();
    createService(offline: false, apiService: sessionApi);
    final pendingFix = Completer<Position>();
    fix = () => pendingFix.future;
    final starting = service.startPassive();
    await tester.pump();
    expect(service.canChangeOfflineMode, isFalse);
    settings.offline = true;
    settings.notifyListeners();
    pendingFix.complete(_position(latitude));
    expect(await completeOperation(tester, starting), isTrue);
    await stopService(tester);
    expect(sessionApi.uploaded, hasLength(1));
    expect(service.offlineSessions, isEmpty);
    service.dispose();
    queue.dispose();
    await tester.pump();
  });

  for (final disconnect in [false, true]) {
    testWidgets(
      'offline in-flight sample survives ${disconnect ? 'disconnect' : 'stop'} after preference changes',
      (tester) async {
        final sessionApi = _SessionApi();
        createService(
          apiService: sessionApi,
          offlineSessions: OfflineWardriveSessionService(),
        );
        expect(await service.startActive(), isTrue);
        await tester.pump();
        expect(connector.sentMessages, hasLength(1));
        settings.offline = false;
        settings.notifyListeners();
        if (disconnect) {
          connector.connected = false;
          connector.notifyListeners();
        }
        await stopService(tester);
        final restored = OfflineWardriveSessionService();
        await restored.init();
        expect(restored.sessions.single.samples, hasLength(1));
        expect(sessionApi.uploaded, isEmpty);
        expect(service.isOfflineMode, isFalse);
        service.dispose();
        queue.dispose();
        await tester.pump();
      },
    );
  }

  testWidgets('failed startup releases storage mode for the next drive', (
    tester,
  ) async {
    createService(offline: false);
    connector.connected = false;
    expect(await completeOperation(tester, service.startPassive()), isFalse);
    expect(service.canChangeOfflineMode, isTrue);

    settings.offline = true;
    connector.connected = true;
    expect(await service.startActive(), isTrue);
    await tester.pump();
    await stopService(tester);
    expect(service.offlineSessions.single.samples, hasLength(1));
    expect(queue.queueCount, 0);
    service.dispose();
    queue.dispose();
    await tester.pump();
  });

  testWidgets('cancelled startup releases storage mode before restarting', (
    tester,
  ) async {
    final sessionApi = _SessionApi();
    createService(offline: false, apiService: sessionApi);
    final pendingFix = Completer<Position>();
    fix = () => pendingFix.future;
    final starting = service.startPassive();
    await tester.pump();
    settings.offline = true;
    settings.notifyListeners();
    final stopping = service.stop();
    pendingFix.complete(_position(latitude));
    expect(await completeOperation(tester, starting), isFalse);
    await completeOperation(tester, stopping);

    fix = () async => _position(latitude);
    expect(await service.startActive(), isTrue);
    await tester.pump();
    await stopService(tester);
    expect(service.offlineSessions.single.samples, hasLength(1));
    expect(sessionApi.uploaded, isEmpty);
    service.dispose();
    queue.dispose();
    await tester.pump();
  });

  testWidgets('manual ping keeps offline storage through a concurrent stop', (
    tester,
  ) async {
    final sessionApi = _SessionApi();
    createService(
      apiService: sessionApi,
      offlineSessions: OfflineWardriveSessionService(),
    );
    final sending = service.sendManualPing();
    await tester.pump();
    expect(connector.sentMessages, hasLength(1));
    settings.offline = false;
    settings.notifyListeners();
    final stopping = service.stop();
    expect(
      await completeOperation(
        tester,
        sending,
        advance: const Duration(seconds: 7),
      ),
      isTrue,
    );
    await completeOperation(tester, stopping);
    final restored = OfflineWardriveSessionService();
    await restored.init();
    expect(restored.sessions.single.samples, hasLength(1));
    expect(sessionApi.uploaded, isEmpty);
    expect(service.canChangeOfflineMode, isTrue);
    expect(service.isOfflineMode, isFalse);
    service.dispose();
    queue.dispose();
    await tester.pump();
  });

  testWidgets('offline setting is locked during startup, collection and stop', (
    tester,
  ) async {
    createService();
    final uiConnector = MeshCoreConnector();
    addTearDown(uiConnector.dispose);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppSettingsService>.value(value: settings),
          ChangeNotifierProvider<MeshCoreConnector>.value(value: uiConnector),
          ChangeNotifierProvider<WardrivingService>.value(value: service),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AppSettingsScreen(),
        ),
      ),
    );
    final toggle = find.widgetWithText(SwitchListTile, 'Offline-session mode');
    await tester.scrollUntilVisible(toggle, 500);
    expect(tester.widget<SwitchListTile>(toggle).onChanged, isNotNull);

    final pendingFix = Completer<Position>();
    fix = () => pendingFix.future;
    final starting = service.startActive();
    await tester.pump();
    expect(tester.widget<SwitchListTile>(toggle).onChanged, isNull);
    expect(
      find.text('Stop wardriving before changing how samples are saved.'),
      findsOneWidget,
    );

    pendingFix.complete(_position(latitude));
    expect(await completeOperation(tester, starting), isTrue);
    expect(tester.widget<SwitchListTile>(toggle).onChanged, isNull);
    final stopping = service.stop();
    await tester.pump();
    expect(tester.widget<SwitchListTile>(toggle).onChanged, isNull);
    await completeOperation(
      tester,
      stopping,
      advance: const Duration(seconds: 7),
    );
    expect(service.canChangeOfflineMode, isTrue);
    await tester.pump();
    expect(tester.widget<SwitchListTile>(toggle).onChanged, isNotNull);
    await tester.pumpWidget(const SizedBox.shrink());
    service.dispose();
    queue.dispose();
    await tester.pump();
  });
}

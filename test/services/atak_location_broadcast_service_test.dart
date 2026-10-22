import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_connector.dart';
import 'package:gulf_coast_mesh_app/models/app_settings.dart';
import 'package:gulf_coast_mesh_app/models/channel.dart';
import 'package:gulf_coast_mesh_app/services/app_settings_service.dart';
import 'package:gulf_coast_mesh_app/services/atak_location_broadcast_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gulf_coast_mesh_app/storage/prefs_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const startLat = 37.7749;
  const startLon = -122.4194;
  const thresholdMeters = 50.0;
  const dist = Distance();
  final movedLat = startLat + (thresholdMeters / 111320);

  late AppSettingsService settingsService;
  late Channel atakChannel;
  late List<({Channel channel, String text, bool addToLocalHistory})>
  sentMessages;
  late List<({double lat, double lon})> nodeLocations;
  late bool connected;
  late List<Channel> channels;
  late Future<({double lat, double lon})?> Function() readPosition;
  late Future<bool> Function() hasLocationPermission;
  late DateTime fakeNow;
  AtakLocationBroadcastService? service;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await PrefsManager.initialize();
  });

  setUp(() async {
    settingsService = AppSettingsService();
    atakChannel = Channel(
      index: 1,
      name: '#atak',
      psk: Channel.derivePskFromHashtag('atak'),
    );
    sentMessages = [];
    nodeLocations = [];
    connected = true;
    channels = [atakChannel];
    readPosition = () async => (lat: startLat, lon: startLon);
    hasLocationPermission = () async => true;
    fakeNow = DateTime.utc(2026, 6, 5, 12, 0, 0);

    await settingsService.updateSettings(
      AppSettings(
        atakChannelIndex: atakChannel.index,
        atakChannelName: atakChannel.name,
        atakLocationBroadcastEnabled: true,
        atakMovementDistanceMeters: thresholdMeters,
        atakMinSendIntervalSec: 60,
      ),
    );
  });

  tearDown(() {
    service?.dispose();
    service = null;
  });

  AtakLocationBroadcastService createService() {
    final host = ChangeNotifier();
    return AtakLocationBroadcastService(
      connector: MeshCoreConnector(),
      settingsService: settingsService,
      readPosition: () async => readPosition(),
      hasLocationPermission: hasLocationPermission,
      tickInterval: Duration.zero,
      isConnected: () => connected,
      getChannels: () => channels,
      getSelfName: () => 'Alpha-1',
      sendChannelMessage: (channel, text, {addToLocalHistory = true}) async {
        sentMessages.add((
          channel: channel,
          text: text,
          addToLocalHistory: addToLocalHistory,
        ));
      },
      setNodeLocation: ({required lat, required lon}) async {
        nodeLocations.add((lat: lat, lon: lon));
      },
      addConnectorListener: host.addListener,
      removeConnectorListener: host.removeListener,
      now: () => fakeNow,
    );
  }

  group('AtakLocationBroadcastService', () {
    test('does not send when location permission is denied', () async {
      hasLocationPermission = () async => false;
      service = createService();
      await service!.refreshForTest();
      await service!.tickForTest();

      expect(sentMessages, isEmpty);
    });

    test('does not send when broadcast is disabled', () async {
      await settingsService.updateSettings(
        settingsService.settings.copyWith(atakLocationBroadcastEnabled: false),
      );
      service = createService();
      await service!.refreshForTest();
      await service!.tickForTest();

      expect(sentMessages, isEmpty);
    });

    test('never reads phone GPS while broadcast is disabled', () async {
      var positionReads = 0;
      readPosition = () async {
        positionReads++;
        return (lat: startLat, lon: startLon);
      };
      await settingsService.updateSettings(
        settingsService.settings.copyWith(atakLocationBroadcastEnabled: false),
      );
      service = createService();
      await service!.refreshForTest();

      expect(positionReads, 0);
    });

    test('reads phone GPS only while broadcast is enabled', () async {
      var positionReads = 0;
      readPosition = () async {
        positionReads++;
        return (lat: startLat, lon: startLon);
      };
      service = createService();
      await service!.refreshForTest();
      expect(positionReads, 1);

      await settingsService.updateSettings(
        settingsService.settings.copyWith(atakLocationBroadcastEnabled: false),
      );
      await service!.refreshForTest();

      expect(positionReads, 1);
    });

    test('does not send when disconnected', () async {
      connected = false;
      service = createService();
      await service!.refreshForTest();
      await service!.tickForTest();

      expect(sentMessages, isEmpty);
    });

    test('does not send when no channel is selected', () async {
      await settingsService.updateSettings(
        settingsService.settings.copyWith(atakChannelIndex: null),
      );
      service = createService();
      await service!.refreshForTest();
      await service!.tickForTest();

      expect(sentMessages, isEmpty);
    });

    test('sends first position immediately when broadcast starts', () async {
      service = createService();
      await service!.refreshForTest();

      expect(sentMessages, hasLength(1));
      expect(sentMessages.first.text, contains('a:v1|pos|'));
    });

    test('exposes phone GPS position after broadcast starts', () async {
      service = createService();
      await service!.refreshForTest();

      expect(service!.phoneLat, startLat);
      expect(service!.phoneLon, startLon);
      expect(service!.broadcastLat, startLat);
      expect(service!.broadcastLon, startLon);
    });

    test('does not poll phone GPS when broadcast is disabled', () async {
      await settingsService.updateSettings(
        settingsService.settings.copyWith(atakLocationBroadcastEnabled: false),
      );
      service = createService();
      await service!.refreshForTest();

      expect(service!.phoneLat, isNull);
      expect(service!.phoneLon, isNull);
      expect(service!.broadcastLat, isNull);
      expect(service!.broadcastLon, isNull);
      expect(sentMessages, isEmpty);
    });

    test(
      'clears phone and broadcast position when broadcast is disabled',
      () async {
        service = createService();
        await service!.refreshForTest();
        expect(service!.broadcastLat, startLat);
        expect(service!.phoneLat, startLat);

        await settingsService.updateSettings(
          settingsService.settings.copyWith(
            atakLocationBroadcastEnabled: false,
          ),
        );
        await service!.refreshForTest();

        expect(service!.broadcastLat, isNull);
        expect(service!.broadcastLon, isNull);
        expect(service!.phoneLat, isNull);
        expect(service!.phoneLon, isNull);
      },
    );

    test('updates broadcast position even when mesh send is gated', () async {
      service = createService();
      await service!.refreshForTest();
      expect(service!.broadcastLat, startLat);

      const movedLat = 38.0;
      readPosition = () async => (lat: movedLat, lon: startLon);
      await service!.tickForTest();

      expect(sentMessages, hasLength(1));
      expect(service!.broadcastLat, movedLat);
    });

    test('sends first position when coordinates are available', () async {
      service = createService();
      await service!.refreshForTest();
      await service!.tickForTest();

      expect(sentMessages, hasLength(1));
      expect(sentMessages.first.channel.index, atakChannel.index);
      expect(sentMessages.first.addToLocalHistory, isFalse);
      expect(sentMessages.first.text, contains('a:v1|pos|'));
    });

    test('does not send again before interval elapses', () async {
      service = createService();
      await service!.refreshForTest();
      await service!.tickForTest();
      await service!.tickForTest();

      expect(sentMessages, hasLength(1));
    });

    test(
      'sends again after movement and interval thresholds are met',
      () async {
        var tick = 0;
        readPosition = () async {
          tick++;
          if (tick == 1) {
            return (lat: startLat, lon: startLon);
          }
          return (lat: movedLat, lon: startLon);
        };

        service = createService();
        await service!.refreshForTest();
        await service!.tickForTest();
        expect(sentMessages, hasLength(1));

        fakeNow = fakeNow.add(const Duration(seconds: 30));
        await service!.tickForTest();
        expect(sentMessages, hasLength(1));

        fakeNow = fakeNow.add(const Duration(seconds: 30));
        await service!.tickForTest();
        expect(sentMessages, hasLength(2));
        expect(
          dist(const LatLng(startLat, startLon), LatLng(movedLat, startLon)),
          greaterThanOrEqualTo(thresholdMeters),
        );
      },
    );

    test('calls setNodeLocation when sync setting is enabled', () async {
      await settingsService.updateSettings(
        settingsService.settings.copyWith(atakSyncNodeAdvertLocation: true),
      );
      service = createService();
      await service!.refreshForTest();
      await service!.tickForTest();

      expect(nodeLocations, hasLength(1));
      expect(nodeLocations.first.lat, startLat);
      expect(nodeLocations.first.lon, startLon);
      expect(sentMessages, hasLength(1));
    });

    test(
      'does not call setNodeLocation when sync setting is disabled',
      () async {
        service = createService();
        await service!.refreshForTest();
        await service!.tickForTest();

        expect(nodeLocations, isEmpty);
        expect(sentMessages, hasLength(1));
      },
    );

    test('does not send when app is backgrounded', () async {
      service = createService();
      service!.didChangeAppLifecycleState(AppLifecycleState.paused);
      await service!.refreshForTest();
      await service!.tickForTest();

      expect(sentMessages, isEmpty);
    });

    test(
      'dispose during permission check cannot resume location work',
      () async {
        final permission = Completer<bool>();
        var positionReads = 0;
        hasLocationPermission = () => permission.future;
        readPosition = () async {
          positionReads++;
          return (lat: startLat, lon: startLon);
        };
        final localService = createService();

        final refreshing = localService.refreshForTest();
        await pumpEventQueue();
        localService.dispose();
        permission.complete(true);
        await refreshing;

        expect(positionReads, 0);
        await localService.tickForTest();
        expect(positionReads, 0);
      },
    );

    test('transient position errors do not escape timer work', () async {
      readPosition = () async => throw StateError('GPS unavailable');
      service = createService();

      await expectLater(service!.refreshForTest(), completes);
      expect(sentMessages, isEmpty);
    });

    test('an older permission result cannot override a newer denial', () async {
      final firstPermission = Completer<bool>();
      final secondPermission = Completer<bool>();
      var permissionCall = 0;
      var positionReads = 0;
      hasLocationPermission = () {
        permissionCall++;
        return permissionCall == 1
            ? firstPermission.future
            : secondPermission.future;
      };
      readPosition = () async {
        positionReads++;
        return (lat: startLat, lon: startLon);
      };
      service = createService();

      final older = service!.refreshForTest();
      final newer = service!.refreshForTest();
      secondPermission.complete(false);
      await newer;
      firstPermission.complete(true);
      await older;

      expect(positionReads, 0);
      expect(sentMessages, isEmpty);
    });
  });
}

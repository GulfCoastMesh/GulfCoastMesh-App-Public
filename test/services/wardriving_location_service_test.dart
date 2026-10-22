import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gulf_coast_mesh_app/services/wardriving_location_service.dart';

Position position({
  double latitude = 29.7,
  double longitude = -95.3,
  double accuracy = 10,
  DateTime? timestamp,
}) => Position(
  latitude: latitude,
  longitude: longitude,
  timestamp: timestamp ?? DateTime.utc(2026, 1, 1),
  accuracy: accuracy,
  altitude: 0,
  altitudeAccuracy: 1,
  heading: 0,
  headingAccuracy: 1,
  speed: 0,
  speedAccuracy: 1,
);

void main() {
  test('rejects invalid, zero, inaccurate, and stale positions', () {
    final now = DateTime.utc(2026, 1, 1, 1);
    final service = WardrivingLocationService(now: () => now);
    expect(service.isValidPosition(position(timestamp: now)), isTrue);
    expect(
      service.isValidPosition(position(latitude: 91, timestamp: now)),
      isFalse,
    );
    expect(
      service.isValidPosition(
        position(latitude: 0, longitude: 0, timestamp: now),
      ),
      isFalse,
    );
    expect(
      service.isValidPosition(position(accuracy: 101, timestamp: now)),
      isFalse,
    );
    expect(
      service.isValidPosition(
        position(timestamp: now.subtract(const Duration(seconds: 61))),
      ),
      isFalse,
    );
    expect(
      service.isFreshLocation(
        ValidatedWardrivingLocation.fromPosition(
          position(timestamp: now.subtract(const Duration(seconds: 61))),
        ),
      ),
      isFalse,
    );
  });

  test('starts with high accuracy and emits only validated fixes', () async {
    final positions = StreamController<Position>();
    late LocationSettings settings;
    final now = DateTime.utc(2026, 1, 1, 1);
    final service = WardrivingLocationService(
      now: () => now,
      isLocationServiceEnabled: () async => true,
      checkPermission: () async => LocationPermission.whileInUse,
      positionStream: (value) {
        settings = value;
        return positions.stream;
      },
    );
    final emitted = <ValidatedWardrivingLocation>[];
    final subscription = service.locations.listen(emitted.add);
    expect(await service.start(), isTrue);
    expect(settings.accuracy, LocationAccuracy.high);
    expect(settings.distanceFilter, 10);
    positions.add(position(timestamp: now, latitude: 30));
    positions.add(position(timestamp: now, latitude: 91));
    await pumpEventQueue();
    expect(emitted, hasLength(1));
    expect(service.lastLocation!.latitude, 30);
    await service.dispose();
    await subscription.cancel();
    await positions.close();
  });

  test('requests permission and reports denied or disabled states', () async {
    final statuses = <WardrivingLocationStatus>[];
    final disabled = WardrivingLocationService(
      isLocationServiceEnabled: () async => false,
    );
    statuses.addAll([]);
    expect(await disabled.start(), isFalse);
    expect(disabled.status, WardrivingLocationStatus.serviceDisabled);
    await disabled.dispose();

    var requested = false;
    final denied = WardrivingLocationService(
      isLocationServiceEnabled: () async => true,
      checkPermission: () async => LocationPermission.denied,
      requestPermission: () async {
        requested = true;
        return LocationPermission.deniedForever;
      },
    );
    expect(await denied.start(), isFalse);
    expect(requested, isTrue);
    expect(denied.status, WardrivingLocationStatus.permissionDenied);
    await denied.dispose();
  });

  test('requires an Always grant for background wardriving', () async {
    var requests = 0;
    final granted = WardrivingLocationService(
      checkPermission: () async => LocationPermission.whileInUse,
      requestPermission: () async {
        requests++;
        return LocationPermission.always;
      },
    );
    expect(await granted.ensureBackgroundPermission(), isTrue);
    expect(requests, 1);
    await granted.dispose();

    final rejected = WardrivingLocationService(
      checkPermission: () async => LocationPermission.whileInUse,
      requestPermission: () async => LocationPermission.whileInUse,
    );
    expect(await rejected.ensureBackgroundPermission(), isFalse);
    expect(rejected.status, WardrivingLocationStatus.permissionDenied);
    await rejected.dispose();
  });

  test('uses Apple background stream settings on iOS', () async {
    final positions = StreamController<Position>();
    late LocationSettings captured;
    final service = WardrivingLocationService(
      targetPlatform: () => TargetPlatform.iOS,
      isLocationServiceEnabled: () async => true,
      checkPermission: () async => LocationPermission.always,
      positionStream: (settings) {
        captured = settings;
        return positions.stream;
      },
    );

    expect(await service.start(background: true), isTrue);
    expect(captured, isA<AppleSettings>());
    final apple = captured as AppleSettings;
    expect(apple.allowBackgroundLocationUpdates, isTrue);
    expect(apple.pauseLocationUpdatesAutomatically, isFalse);
    await service.dispose();
    await positions.close();
  });

  test(
    'upgrades an existing foreground watcher to background settings',
    () async {
      final foreground = StreamController<Position>();
      final background = StreamController<Position>();
      final settings = <LocationSettings>[];
      final service = WardrivingLocationService(
        targetPlatform: () => TargetPlatform.android,
        isLocationServiceEnabled: () async => true,
        checkPermission: () async => LocationPermission.always,
        positionStream: (value) {
          settings.add(value);
          return settings.length == 1 ? foreground.stream : background.stream;
        },
      );

      expect(await service.start(), isTrue);
      expect(await service.start(background: true), isTrue);
      expect(settings, hasLength(2));
      expect(settings.first, isA<LocationSettings>());
      expect(settings.last, isA<AndroidSettings>());
      await service.dispose();
      await foreground.close();
      await background.close();
    },
  );

  test('releases a completed stream so it can be restarted', () async {
    final first = StreamController<Position>();
    final second = StreamController<Position>();
    var starts = 0;
    final service = WardrivingLocationService(
      isLocationServiceEnabled: () async => true,
      checkPermission: () async => LocationPermission.always,
      positionStream: (_) => ++starts == 1 ? first.stream : second.stream,
    );

    expect(await service.start(), isTrue);
    await first.close();
    await pumpEventQueue();
    expect(service.isRunning, isFalse);
    expect(service.status, WardrivingLocationStatus.error);
    expect(await service.start(), isTrue);
    expect(starts, 2);
    await service.dispose();
    await second.close();
  });

  test('releases an errored stream so it can be restarted', () async {
    final first = StreamController<Position>();
    final second = StreamController<Position>();
    var starts = 0;
    final service = WardrivingLocationService(
      isLocationServiceEnabled: () async => true,
      checkPermission: () async => LocationPermission.always,
      positionStream: (_) => ++starts == 1 ? first.stream : second.stream,
    );

    expect(await service.start(), isTrue);
    first.addError(StateError('GPS unavailable'));
    await pumpEventQueue();
    expect(service.isRunning, isFalse);
    expect(first.hasListener, isFalse);
    expect(await service.start(), isTrue);
    expect(starts, 2);
    await service.dispose();
    await second.close();
  });

  test(
    'start waits for an in-progress stop before creating a watcher',
    () async {
      final cancel = Completer<void>();
      final first = StreamController<Position>(onCancel: () => cancel.future);
      final second = StreamController<Position>();
      var starts = 0;
      final service = WardrivingLocationService(
        isLocationServiceEnabled: () async => true,
        checkPermission: () async => LocationPermission.always,
        positionStream: (_) => ++starts == 1 ? first.stream : second.stream,
      );

      expect(await service.start(), isTrue);
      final stopping = service.stop();
      final restarting = service.start();
      await pumpEventQueue();
      expect(starts, 1);
      cancel.complete();
      await stopping;
      expect(await restarting, isTrue);
      expect(starts, 2);
      await service.dispose();
      await second.close();
    },
  );

  test(
    'gets, validates, stores, and emits a fresh high-accuracy fix',
    () async {
      final now = DateTime.utc(2026, 1, 1, 1);
      late LocationSettings settings;
      final service = WardrivingLocationService(
        now: () => now,
        currentPosition: (value) async {
          settings = value;
          return position(timestamp: now, latitude: 30);
        },
      );
      final emitted = <ValidatedWardrivingLocation>[];
      final listener = service.locations.listen(emitted.add);

      final fresh = await service.getFreshLocation();
      expect(fresh!.latitude, 30);
      expect(service.lastLocation, same(fresh));
      expect(settings.accuracy, LocationAccuracy.high);
      expect(settings.timeLimit, const Duration(seconds: 10));
      await pumpEventQueue();
      expect(emitted, [fresh]);
      await listener.cancel();
      await service.dispose();
    },
  );

  test('discard a fresh fix that arrives after stop', () async {
    final current = Completer<Position>();
    final service = WardrivingLocationService(
      currentPosition: (_) => current.future,
    );

    final pending = service.getFreshLocation();
    await service.stop();
    current.complete(position(timestamp: DateTime.now().toUtc()));
    expect(await pending, isNull);
    expect(service.lastLocation, isNull);
    await service.dispose();
  });

  test(
    'reports permission API failures without propagating an exception',
    () async {
      final service = WardrivingLocationService(
        isLocationServiceEnabled: () async => true,
        checkPermission: () async => throw StateError('permission API failed'),
      );

      expect(await service.start(), isFalse);
      expect(service.status, WardrivingLocationStatus.error);
      await service.dispose();
    },
  );

  test('dispose during permission check cannot start a GPS stream', () async {
    final permission = Completer<LocationPermission>();
    var streamStarts = 0;
    final service = WardrivingLocationService(
      isLocationServiceEnabled: () async => true,
      checkPermission: () => permission.future,
      positionStream: (_) {
        streamStarts++;
        return const Stream<Position>.empty();
      },
    );

    final starting = service.start();
    await pumpEventQueue();
    await service.dispose();
    permission.complete(LocationPermission.always);

    expect(await starting, isFalse);
    expect(streamStarts, 0);
    expect(service.status, WardrivingLocationStatus.stopped);
  });

  test('concurrent starts share one permission and stream operation', () async {
    final permission = Completer<LocationPermission>();
    var permissionChecks = 0;
    var streamStarts = 0;
    final service = WardrivingLocationService(
      isLocationServiceEnabled: () async => true,
      checkPermission: () {
        permissionChecks++;
        return permission.future;
      },
      positionStream: (_) {
        streamStarts++;
        return const Stream<Position>.empty();
      },
    );

    final first = service.start();
    final second = service.start();
    permission.complete(LocationPermission.always);

    expect(await first, isTrue);
    expect(await second, isTrue);
    expect(permissionChecks, 1);
    expect(streamStarts, 1);
    await service.dispose();
  });

  test('stop during permission check prevents a late stream start', () async {
    final permission = Completer<LocationPermission>();
    var streamStarts = 0;
    final service = WardrivingLocationService(
      isLocationServiceEnabled: () async => true,
      checkPermission: () => permission.future,
      positionStream: (_) {
        streamStarts++;
        return const Stream<Position>.empty();
      },
    );

    final starting = service.start();
    await pumpEventQueue();
    await service.stop();
    permission.complete(LocationPermission.always);

    expect(await starting, isFalse);
    expect(streamStarts, 0);
    expect(service.status, WardrivingLocationStatus.stopped);
    await service.dispose();
  });
}

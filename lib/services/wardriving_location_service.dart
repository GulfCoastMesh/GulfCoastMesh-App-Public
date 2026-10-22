import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// A location accepted for wardriving uploads and map markers.
class ValidatedWardrivingLocation {
  final double latitude;
  final double longitude;
  final double accuracyMeters;
  final DateTime timestamp;

  const ValidatedWardrivingLocation({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    required this.timestamp,
  });

  factory ValidatedWardrivingLocation.fromPosition(Position position) =>
      ValidatedWardrivingLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracyMeters: position.accuracy,
        timestamp: position.timestamp,
      );
}

enum WardrivingLocationStatus {
  stopped,
  starting,
  running,
  permissionDenied,
  serviceDisabled,
  error,
}

typedef WardrivingPositionStream =
    Stream<Position> Function(LocationSettings settings);
typedef WardrivingCurrentPosition =
    Future<Position> Function(LocationSettings settings);

/// Owns the GPS stream used by wardriving.
///
/// The geolocator boundary is injectable so validation can be tested without
/// a device or a platform location provider. It intentionally does not fall
/// back to a last-known position: stale fixes must never be uploaded.
class WardrivingLocationService {
  static const double minDistanceMeters = 25;
  static const double maxAccuracyMeters = 100;
  static const Duration maxAge = Duration(seconds: 60);

  final WardrivingPositionStream _positionStream;
  final WardrivingCurrentPosition _currentPosition;
  final Future<LocationPermission> Function() _checkPermission;
  final Future<LocationPermission> Function() _requestPermission;
  final Future<bool> Function() _isLocationServiceEnabled;
  final DateTime Function() _now;
  final TargetPlatform Function() _targetPlatform;

  StreamSubscription<Position>? _subscription;
  Future<bool>? _startOperation;
  Future<void>? _stopOperation;
  int _startGeneration = 0;
  int _streamGeneration = 0;
  bool _usesBackgroundSettings = false;
  final _locationController =
      StreamController<ValidatedWardrivingLocation>.broadcast();
  final _statusController =
      StreamController<WardrivingLocationStatus>.broadcast();
  ValidatedWardrivingLocation? _lastLocation;
  WardrivingLocationStatus _status = WardrivingLocationStatus.stopped;
  bool _disposed = false;

  WardrivingLocationService({
    WardrivingPositionStream? positionStream,
    WardrivingCurrentPosition? currentPosition,
    Future<LocationPermission> Function()? checkPermission,
    Future<LocationPermission> Function()? requestPermission,
    Future<bool> Function()? isLocationServiceEnabled,
    DateTime Function()? now,
    TargetPlatform Function()? targetPlatform,
  }) : _positionStream =
           positionStream ??
           ((settings) =>
               Geolocator.getPositionStream(locationSettings: settings)),
       _currentPosition =
           currentPosition ??
           ((settings) =>
               Geolocator.getCurrentPosition(locationSettings: settings)),
       _checkPermission = checkPermission ?? Geolocator.checkPermission,
       _requestPermission = requestPermission ?? Geolocator.requestPermission,
       _isLocationServiceEnabled =
           isLocationServiceEnabled ?? Geolocator.isLocationServiceEnabled,
       _now = now ?? DateTime.now,
       _targetPlatform = targetPlatform ?? (() => defaultTargetPlatform);

  Stream<ValidatedWardrivingLocation> get locations =>
      _locationController.stream;
  Stream<WardrivingLocationStatus> get statusStream => _statusController.stream;
  ValidatedWardrivingLocation? get lastLocation => _lastLocation;
  WardrivingLocationStatus get status => _status;
  bool get isRunning => _subscription != null;

  Future<bool> start({bool background = false}) async {
    if (_disposed) return false;
    final pending = _startOperation;
    if (pending != null) {
      final started = await pending;
      if (!started || !background || _usesBackgroundSettings) return started;
      return start(background: true);
    }
    final stopping = _stopOperation;
    if (stopping != null) await stopping;
    if (_disposed) return false;
    if (isRunning) {
      if (!background || _usesBackgroundSettings) return true;
      await _cancelActiveSubscription();
    }
    final generation = ++_startGeneration;
    final operation = _start(background: background, generation: generation);
    _startOperation = operation;
    try {
      return await operation;
    } finally {
      if (identical(_startOperation, operation)) {
        _startOperation = null;
      }
    }
  }

  Future<bool> _start({
    required bool background,
    required int generation,
  }) async {
    _setStatus(WardrivingLocationStatus.starting);
    try {
      if (!await _isLocationServiceEnabled()) {
        if (!_isStartCurrent(generation)) return false;
        _setStatus(WardrivingLocationStatus.serviceDisabled);
        return false;
      }
      if (!_isStartCurrent(generation)) return false;
      var permission = await _checkPermission();
      if (!_isStartCurrent(generation)) return false;
      if (permission == LocationPermission.denied) {
        permission = await _requestPermission();
        if (!_isStartCurrent(generation)) return false;
      }
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        _setStatus(WardrivingLocationStatus.permissionDenied);
        return false;
      }
    } catch (_) {
      if (!_isStartCurrent(generation)) return false;
      _setStatus(WardrivingLocationStatus.error);
      return false;
    }
    try {
      final settings = background && _targetPlatform() == TargetPlatform.iOS
          ? AppleSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 10,
              activityType: ActivityType.automotiveNavigation,
              allowBackgroundLocationUpdates: true,
              pauseLocationUpdatesAutomatically: false,
              showBackgroundLocationIndicator: true,
            )
          : background && _targetPlatform() == TargetPlatform.android
          ? AndroidSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 10,
              intervalDuration: const Duration(seconds: 5),
            )
          : const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 10,
            );
      if (!_isStartCurrent(generation)) return false;
      final streamGeneration = ++_streamGeneration;
      final subscription = _positionStream(settings).listen(
        (position) {
          if (streamGeneration == _streamGeneration) {
            _handlePosition(position);
          }
        },
        onError: (Object error, StackTrace stackTrace) =>
            _finishStream(streamGeneration),
        onDone: () => _finishStream(streamGeneration),
      );
      if (!_isStartCurrent(generation)) {
        await subscription.cancel();
        return false;
      }
      _subscription = subscription;
      _usesBackgroundSettings = background;
      _setStatus(WardrivingLocationStatus.running);
      return true;
    } catch (_) {
      if (_isStartCurrent(generation)) {
        _setStatus(WardrivingLocationStatus.error);
      }
      return false;
    }
  }

  /// Requests the platform's background/Always location grant before an
  /// automatic wardrive is allowed to advertise continued background work.
  Future<bool> ensureBackgroundPermission() async {
    if (_disposed) return false;
    try {
      var permission = await _checkPermission();
      if (_disposed) return false;
      if (permission == LocationPermission.always) return true;
      if (permission == LocationPermission.denied) {
        permission = await _requestPermission();
        if (_disposed) return false;
      }
      if (permission == LocationPermission.whileInUse) {
        permission = await _requestPermission();
        if (_disposed) return false;
      }
      if (permission != LocationPermission.always) {
        _setStatus(WardrivingLocationStatus.permissionDenied);
        return false;
      }
      return true;
    } catch (_) {
      if (!_disposed) _setStatus(WardrivingLocationStatus.error);
      return false;
    }
  }

  Future<void> stop() async {
    _startGeneration++;
    final pendingStop = _stopOperation;
    if (pendingStop != null) {
      await pendingStop;
      _setStatus(WardrivingLocationStatus.stopped);
      return;
    }
    final cancellation = _cancelActiveSubscription();
    _stopOperation = cancellation;
    await cancellation;
    if (identical(_stopOperation, cancellation)) _stopOperation = null;
    _setStatus(WardrivingLocationStatus.stopped);
  }

  /// Requests a current high-accuracy fix when the movement-filtered stream
  /// has not produced one yet. It never falls back to a stale cached location.
  Future<ValidatedWardrivingLocation?> getFreshLocation() async {
    if (_disposed) return null;
    final generation = _startGeneration;
    try {
      final position = await _currentPosition(
        const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      if (!_isStartCurrent(generation)) return null;
      final location = validate(position);
      if (location == null) return null;
      _lastLocation = location;
      _locationController.add(location);
      return location;
    } catch (_) {
      if (_isStartCurrent(generation)) {
        _setStatus(WardrivingLocationStatus.error);
      }
      return null;
    }
  }

  bool isValidPosition(Position position) => validate(position) != null;

  bool _isStartCurrent(int generation) =>
      !_disposed && generation == _startGeneration;

  bool isFreshLocation(ValidatedWardrivingLocation location) {
    final age = _now().difference(location.timestamp);
    return !age.isNegative && age <= maxAge;
  }

  ValidatedWardrivingLocation? validate(Position position) {
    final lat = position.latitude;
    final lon = position.longitude;
    final accuracy = position.accuracy;
    final age = _now().difference(position.timestamp);
    if (!lat.isFinite || !lon.isFinite || lat.abs() > 90 || lon.abs() > 180) {
      return null;
    }
    if (lat == 0 && lon == 0) return null;
    if (!accuracy.isFinite || accuracy < 0 || accuracy > maxAccuracyMeters) {
      return null;
    }
    if (age > maxAge || age.isNegative) return null;
    return ValidatedWardrivingLocation.fromPosition(position);
  }

  void _handlePosition(Position position) {
    if (_disposed) return;
    final location = validate(position);
    if (location == null) return;
    _lastLocation = location;
    _locationController.add(location);
  }

  Future<void> _cancelActiveSubscription() async {
    // Cancel may result in a delayed onDone. Invalidate it before cancelling so
    // that it cannot release a subsequently started subscription.
    _streamGeneration++;
    final subscription = _subscription;
    _subscription = null;
    _usesBackgroundSettings = false;
    await subscription?.cancel();
  }

  void _finishStream(int streamGeneration) {
    if (_disposed || streamGeneration != _streamGeneration) return;
    final subscription = _subscription;
    _subscription = null;
    _usesBackgroundSettings = false;
    _streamGeneration++;
    if (subscription != null) unawaited(subscription.cancel());
    _setStatus(WardrivingLocationStatus.error);
  }

  void _setStatus(WardrivingLocationStatus value) {
    _status = value;
    if (!_statusController.isClosed) _statusController.add(value);
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await stop();
    await _locationController.close();
    await _statusController.close();
  }
}

import 'dart:async';

import 'package:flutter/widgets.dart';

import '../connector/meshcore_connector.dart';
import '../helpers/atak_broadcast_policy.dart';
import '../helpers/atak_channel_helper.dart';
import '../helpers/atak_location_access.dart';
import '../helpers/tactical_map_payload.dart';
import '../models/channel.dart';
import '../services/app_settings_service.dart';

class AtakLocationBroadcastService extends ChangeNotifier
    with WidgetsBindingObserver {
  static const Duration _defaultTickInterval = Duration(seconds: 10);

  final AppSettingsService _settingsService;
  final Future<({double lat, double lon})?> Function() _readPosition;
  final Future<bool> Function() _hasLocationPermission;
  final Duration _tickInterval;
  final bool Function() _isConnected;
  final List<Channel> Function() _getChannels;
  final String? Function() _getSelfName;
  final Future<void> Function(
    Channel channel,
    String text, {
    bool addToLocalHistory,
  })
  _sendChannelMessage;
  final Future<void> Function({required double lat, required double lon})
  _setNodeLocation;
  final void Function(VoidCallback listener) _addConnectorListener;
  final void Function(VoidCallback listener) _removeConnectorListener;
  final DateTime Function() _now;

  Timer? _timer;
  bool _isRunning = false;
  bool _tickInFlight = false;
  double? _lastSentLat;
  double? _lastSentLon;
  DateTime? _lastSentAt;
  double? _broadcastLat;
  double? _broadcastLon;
  double? _phoneLat;
  double? _phoneLon;
  bool _isForeground = true;
  bool _hasPermission = false;
  bool _disposed = false;
  int _refreshGeneration = 0;
  VoidCallback? _connectorListener;
  VoidCallback? _settingsListener;

  double? get broadcastLat => _broadcastLat;
  double? get broadcastLon => _broadcastLon;
  double? get phoneLat => _phoneLat;
  double? get phoneLon => _phoneLon;

  AtakLocationBroadcastService({
    required MeshCoreConnector connector,
    required AppSettingsService settingsService,
    Future<({double lat, double lon})?> Function()? readPosition,
    Future<bool> Function()? hasLocationPermission,
    Duration tickInterval = _defaultTickInterval,
    bool Function()? isConnected,
    List<Channel> Function()? getChannels,
    String? Function()? getSelfName,
    Future<void> Function(
      Channel channel,
      String text, {
      bool addToLocalHistory,
    })?
    sendChannelMessage,
    Future<void> Function({required double lat, required double lon})?
    setNodeLocation,
    void Function(VoidCallback listener)? addConnectorListener,
    void Function(VoidCallback listener)? removeConnectorListener,
    DateTime Function()? now,
  }) : _settingsService = settingsService,
       _readPosition =
           readPosition ??
           (() async {
             final position = await readAtakPosition();
             if (position == null) return null;
             return (lat: position.lat, lon: position.lon);
           }),
       _hasLocationPermission =
           hasLocationPermission ?? hasAtakLocationPermission,
       _tickInterval = tickInterval,
       _isConnected =
           isConnected ??
           (() => connector.isConnected && !connector.isDemoMode),
       _getChannels = getChannels ?? (() => connector.channels),
       _getSelfName = getSelfName ?? (() => connector.selfName),
       _sendChannelMessage =
           sendChannelMessage ??
           ((channel, text, {addToLocalHistory = true}) =>
               connector.sendChannelMessage(
                 channel,
                 text,
                 addToLocalHistory: addToLocalHistory,
               )),
       _setNodeLocation =
           setNodeLocation ??
           (({required lat, required lon}) =>
               connector.setNodeLocation(lat: lat, lon: lon)),
       _addConnectorListener = addConnectorListener ?? connector.addListener,
       _removeConnectorListener =
           removeConnectorListener ?? connector.removeListener,
       _now = now ?? (() => DateTime.now().toUtc()) {
    _settingsListener = _onStateChanged;
    _connectorListener = _onStateChanged;
    _settingsService.addListener(_settingsListener!);
    _addConnectorListener(_connectorListener!);
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> ensureStarted() => _refreshPermissionAndSync();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _isForeground = true;
        unawaited(_refreshPermissionAndSync());
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        _isForeground = false;
        unawaited(_syncTimer());
    }
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _timer = null;
    if (_settingsListener != null) {
      _settingsService.removeListener(_settingsListener!);
    }
    if (_connectorListener != null) {
      _removeConnectorListener(_connectorListener!);
    }
    super.dispose();
  }

  void _onStateChanged() {
    unawaited(_refreshPermissionAndSync());
  }

  Future<void> _refreshPermissionAndSync() async {
    if (_disposed) return;
    final generation = ++_refreshGeneration;
    try {
      final hasPermission = await _hasLocationPermission();
      if (_disposed || generation != _refreshGeneration) return;
      _hasPermission = hasPermission;
    } catch (_) {
      if (_disposed || generation != _refreshGeneration) return;
      _hasPermission = false;
    }
    if (!_hasPermission) {
      _clearBroadcastState();
      _clearPhonePosition();
    }
    await _syncTimer();
  }

  Future<void> _syncTimer() async {
    if (_disposed) return;
    final shouldBroadcast = _shouldRunBroadcast();

    if (shouldBroadcast) {
      if (!_isRunning) {
        _isRunning = true;
        await _locationTick();
        if (_tickInterval != Duration.zero) {
          _timer = Timer.periodic(
            _tickInterval,
            (_) => unawaited(_locationTick()),
          );
        }
      }
    } else {
      _isRunning = false;
      _timer?.cancel();
      _timer = null;
      _lastSentLat = null;
      _lastSentLon = null;
      _lastSentAt = null;
      _clearBroadcastPosition();
      _clearPhonePosition();
    }
  }

  void _clearBroadcastState() {
    _lastSentLat = null;
    _lastSentLon = null;
    _lastSentAt = null;
    _clearBroadcastPosition();
  }

  void _clearBroadcastPosition() {
    if (_broadcastLat == null && _broadcastLon == null) return;
    _broadcastLat = null;
    _broadcastLon = null;
    _notifyIfActive();
  }

  void _clearPhonePosition() {
    if (_phoneLat == null && _phoneLon == null) return;
    _phoneLat = null;
    _phoneLon = null;
    _notifyIfActive();
  }

  void _updateBroadcastPosition(double lat, double lon) {
    if (_broadcastLat == lat && _broadcastLon == lon) return;
    _broadcastLat = lat;
    _broadcastLon = lon;
    _notifyIfActive();
  }

  void _updatePhonePosition(double lat, double lon) {
    if (!isValidMapCoordinate(lat, lon)) return;
    if (_phoneLat == lat && _phoneLon == lon) return;
    _phoneLat = lat;
    _phoneLon = lon;
    _notifyIfActive();
  }

  void _notifyIfActive() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  bool _shouldRunBroadcast() {
    final settings = _settingsService.settings;
    return _isForeground &&
        settings.atakLocationBroadcastEnabled &&
        settings.atakChannelIndex != null &&
        _isConnected() &&
        _hasPermission;
  }

  Channel? _selectedChannel() {
    final settings = _settingsService.settings;
    return resolveAtakChannel(
      _getChannels(),
      index: settings.atakChannelIndex,
      name: settings.atakChannelName,
    );
  }

  @visibleForTesting
  Future<void> refreshForTest() => _refreshPermissionAndSync();

  @visibleForTesting
  Future<void> tickForTest() => _locationTick();

  Future<void> _locationTick() async {
    if (_disposed) return;
    if (_tickInFlight) return;
    if (!_isForeground) return;
    _tickInFlight = true;
    try {
      if (!await _hasLocationPermission()) {
        if (_disposed) return;
        _hasPermission = false;
        _clearBroadcastState();
        _clearPhonePosition();
        await _syncTimer();
        return;
      }
      if (_disposed) return;
      _hasPermission = true;

      final coords = await _readPosition();
      if (_disposed) return;
      if (coords == null) return;

      final lat = coords.lat;
      final lon = coords.lon;
      _updatePhonePosition(lat, lon);

      if (!_shouldRunBroadcast()) return;

      final settings = _settingsService.settings;
      final channel = _selectedChannel();
      if (channel == null) return;

      final now = _now();
      _updateBroadcastPosition(lat, lon);

      if (!shouldBroadcastAtakPosition(
        lat: lat,
        lon: lon,
        lastLat: _lastSentLat,
        lastLon: _lastSentLon,
        lastSentAt: _lastSentAt,
        minIntervalSec: settings.atakMinSendIntervalSec,
        movementMeters: settings.atakMovementDistanceMeters,
        now: now,
      )) {
        return;
      }

      if (settings.atakSyncNodeAdvertLocation) {
        await _setNodeLocation(lat: lat, lon: lon);
        if (_disposed) return;
      }

      final payload = TacticalMapPayload.formatPosition(
        lat: lat,
        lon: lon,
        timestampSeconds: now.millisecondsSinceEpoch ~/ 1000,
        name: _getSelfName() ?? 'Me',
      );

      await _sendChannelMessage(channel, payload, addToLocalHistory: false);
      if (_disposed) return;

      _lastSentLat = lat;
      _lastSentLon = lon;
      _lastSentAt = now;
    } catch (_) {
      // Permission, GPS, and mesh I/O are platform/network boundaries. A
      // transient failure must not escape an unawaited periodic timer callback.
    } finally {
      _tickInFlight = false;
    }
  }
}

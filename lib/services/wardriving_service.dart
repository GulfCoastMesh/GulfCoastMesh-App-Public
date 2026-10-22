import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../connector/meshcore_connector.dart';
import '../connector/meshcore_protocol.dart';
import '../helpers/meshmapper_wire_tag.dart';
import '../helpers/meshmapper_coverage.dart';
import '../helpers/wardriving_channel_helper.dart';
import '../helpers/wardriving_crypto.dart';
import '../helpers/wardriving_packet.dart';
import '../models/channel.dart';
import '../models/app_settings.dart';
import '../models/wardriving.dart';
import '../models/wardriving_queue_item.dart';
import '../services/app_settings_service.dart';
import '../services/meshmapper_api_service.dart';
import '../services/meshmapper_queue_service.dart';
import '../services/background_service.dart';
import '../services/offline_wardrive_session_service.dart';
import 'wardriving_location_service.dart';
import '../models/offline_wardrive_session.dart';
import '../wardriving/wardriving_trackers.dart';

class WardrivingService extends ChangeNotifier with WidgetsBindingObserver {
  static const Duration echoWindow = Duration(seconds: 5);

  final MeshCoreConnector _connector;
  final AppSettingsService _settingsService;
  final MeshMapperApiService _apiService;
  final MeshMapperQueueService _queueService;
  final WardrivingLocationService _locationService;
  final BackgroundService _backgroundService;
  final OfflineWardriveSessionService _offlineSessionService;
  final DateTime Function() _now;

  WardrivingMode _mode = WardrivingMode.off;
  WardrivingSessionState _sessionState = WardrivingSessionState.idle;
  String? _statusMessage;
  int _txCount = 0;
  int _rxCount = 0;
  int _discCount = 0;
  int _traceCount = 0;
  bool _hybridNextIsDiscovery = true;
  bool _isForeground = true;
  bool _disposed = false;

  Timer? _modeTimer;
  Duration? _modeTimerInterval;
  Future<void>? _controlOperation;
  Future<void>? _stopOperation;
  bool _stopping = false;
  bool? _sessionOffline;
  bool? _lastConnected;
  AppSettings? _lastSettings;
  StreamSubscription<Uint8List>? _frameSubscription;
  StreamSubscription<ValidatedWardrivingLocation>? _locationSubscription;
  StreamSubscription<DateTime>? _backgroundTickSubscription;
  final WardrivingTxTracker _txTracker = WardrivingTxTracker();
  final WardrivingDiscTracker _discTracker = WardrivingDiscTracker();
  final WardrivingTraceTracker _traceTracker = WardrivingTraceTracker();
  final WardrivingRxLogger _rxLogger = WardrivingRxLogger();
  final List<WardrivingMapEvent> _mapEvents = <WardrivingMapEvent>[];

  double? _lastAccuracyMeters;
  double? _lastSentLat;
  double? _lastSentLon;
  String? _appVersion;
  int _discTagCounter = 0;
  DateTime? _lastDiscoveryAt;
  DateTime? _lastZoneCheckAt;
  bool _zoneAllowed = true;
  ValidatedWardrivingLocation? _rxBatchLocation;
  DateTime? _lastManualPingAt;
  DateTime? _lastAutomaticOperationAt;
  String? _targetRepeaterId;
  bool _tickInFlight = false;
  Future<void>? _activeOperation;
  Future<void> _pendingRxFlush = Future<void>.value();
  Completer<ValidatedWardrivingLocation>? _firstLocationCompleter;
  double _firstLocationMaxAccuracy =
      WardrivingLocationService.maxAccuracyMeters;
  String? _offlineSessionId;
  List<Map<String, dynamic>> _offlineSamples = <Map<String, dynamic>>[];
  List<MeshMapperRepeater> _repeaters = const [];
  bool _loadingRepeaters = false;
  bool _loadingModeAvailability = false;
  Map<WardrivingMode, WardrivingModeAvailability> _modeAvailability = {};

  VoidCallback? _connectorListener;
  VoidCallback? _settingsListener;
  VoidCallback? _queueListener;

  WardrivingService({
    required MeshCoreConnector connector,
    required AppSettingsService settingsService,
    required MeshMapperApiService apiService,
    required MeshMapperQueueService queueService,
    WardrivingLocationService? locationService,
    BackgroundService? backgroundService,
    OfflineWardriveSessionService? offlineSessionService,
    DateTime Function()? now,
  }) : _connector = connector,
       _settingsService = settingsService,
       _apiService = apiService,
       _queueService = queueService,
       _locationService = locationService ?? WardrivingLocationService(),
       _backgroundService = backgroundService ?? BackgroundService(),
       _now = now ?? DateTime.now,
       _offlineSessionService =
           offlineSessionService ?? OfflineWardriveSessionService() {
    _connectorListener = _onDependenciesChanged;
    _settingsListener = _onDependenciesChanged;
    _queueListener = notifyListeners;
    _connector.addListener(_connectorListener!);
    _settingsService.addListener(_settingsListener!);
    _queueService.addListener(_queueListener!);
    WidgetsBinding.instance.addObserver(this);

    _rxLogger.onBatchReady = (repeaters) {
      final location = _rxBatchLocation;
      _rxBatchLocation = null;
      if (location == null) return;
      _pendingRxFlush = _pendingRxFlush.then(
        (_) => _onRxBatchReady(repeaters, location),
      );
    };
    _apiService.onSessionIdChanged = (_, _) =>
        _queueService.dropStaleTaggedItems();
    _apiService.onSessionError = (reason, message) {
      final failure = message ?? reason;
      _sessionState = WardrivingSessionState.error;
      _statusMessage = failure;
      unawaited(stop(preserveError: failure));
      notifyListeners();
    };
    _queueService.onItemsDropped = (count) {
      _statusMessage = 'Dropped $count wardriving sample(s) (server rejected)';
      notifyListeners();
    };

    unawaited(_loadAppVersion());
    _frameSubscription = _connector.receivedFrames.listen(_onFrame);
    _locationSubscription = _locationService.locations.listen(_onLocation);
    _backgroundTickSubscription = _backgroundService.wardrivingTicks.listen((
      _,
    ) {
      if (isRunning && !_isForeground) unawaited(_runModeTick());
    });
  }

  WardrivingMode get mode => _mode;
  WardrivingSessionState get sessionState => _sessionState;
  String? get statusMessage => _statusMessage;
  bool get isRunning => _mode != WardrivingMode.off;
  bool get isBusy => _controlOperation != null || _stopping;
  bool get canChangeOfflineMode => !isRunning && !isBusy;

  // Keep collection, uploads, and final persistence on the same storage path
  // even if settings change while a start, sample, or stop is awaiting I/O.
  bool get isOfflineMode =>
      _sessionOffline ?? _settingsService.settings.wardrivingOfflineMode;
  bool get _canOperate =>
      !_disposed &&
      !_stopping &&
      _connector.isConnected &&
      !_connector.isDemoMode &&
      (_isForeground || _settingsService.settings.wardrivingBackgroundEnabled);
  bool get canStartTxModes =>
      isOfflineMode ||
      !_apiService.hasSession ||
      (_apiService.txAllowed && !_apiService.floodDisabled);
  bool get canUpload => _apiService.rxAllowed;
  bool get hasApiKey => _apiService.hasApiKey;
  bool get enforceHybrid => _apiService.enforceHybrid;
  bool get floodDisabled => _apiService.floodDisabled;
  bool get hasSession => _apiService.hasSession;
  int get minModeInterval => _apiService.minModeInterval;
  String? get coverageZone => _apiService.zone;
  ValidatedWardrivingLocation? get currentLocation {
    final location = _locationService.lastLocation;
    return location != null && _locationService.isFreshLocation(location)
        ? location
        : null;
  }

  List<WardrivingMapEvent> get mapEvents => List.unmodifiable(_mapEvents);
  List<OfflineWardriveSession> get offlineSessions =>
      _offlineSessionService.sessions;
  int? get currentNoiseFloor => _connector.lastNoiseFloor;
  List<MeshMapperRepeater> get repeaters => List.unmodifiable(_repeaters);
  bool get isLoadingRepeaters => _loadingRepeaters;
  bool get isLoadingModeAvailability => _loadingModeAvailability;
  List<WardrivingModeAvailability> get modeAvailability => WardrivingMode.values
      .where((mode) => mode != WardrivingMode.off)
      .map(
        (mode) =>
            _modeAvailability[mode] ??
            WardrivingModeAvailability(
              mode: mode,
              enabled: false,
              reason: 'Checking availability…',
            ),
      )
      .toList(growable: false);
  WardrivingModeAvailability availabilityFor(WardrivingMode mode) =>
      _modeAvailability[mode] ??
      WardrivingModeAvailability(
        mode: mode,
        enabled: false,
        reason: 'Checking availability…',
      );

  /// Computes the local/session gates without starting a wardrive.
  static Map<WardrivingMode, WardrivingModeAvailability>
  evaluateModeAvailability({
    required bool connected,
    required bool apiConfigured,
    required bool gpsAvailable,
    required bool offline,
    required bool hasSession,
    required bool txAllowed,
    required bool floodDisabled,
    required bool hybridEnforced,
    required String targetRepeaterId,
    required bool targetExists,
    bool zoneRestricted = false,
  }) {
    String? common() {
      if (!connected) return 'Connect a MeshCore device first';
      if (!gpsAvailable) return 'Waiting for a valid GPS fix';
      if (!offline && !apiConfigured) {
        return 'API not configured for this build';
      }
      if (!offline && zoneRestricted) {
        return 'Outside the MeshMapper coverage zone';
      }
      return null;
    }

    WardrivingModeAvailability result(WardrivingMode mode, {bool tx = false}) {
      final base = common();
      if (base != null) {
        return WardrivingModeAvailability(
          mode: mode,
          enabled: false,
          reason: base,
        );
      }
      if (tx && !offline && hasSession && !txAllowed) {
        return WardrivingModeAvailability(
          mode: mode,
          enabled: false,
          reason: 'TX is not allowed for this session',
        );
      }
      if (tx && mode != WardrivingMode.targeted && !offline && floodDisabled) {
        return WardrivingModeAvailability(
          mode: mode,
          enabled: false,
          reason: 'Flood traffic is disabled for this session',
        );
      }
      if (tx && !offline && hybridEnforced && mode == WardrivingMode.active) {
        return WardrivingModeAvailability(
          mode: mode,
          enabled: false,
          reason: 'This session requires Hybrid mode',
        );
      }
      return WardrivingModeAvailability(mode: mode, enabled: true);
    }

    final targeted = targetRepeaterId.trim().isEmpty
        ? const WardrivingModeAvailability(
            mode: WardrivingMode.targeted,
            enabled: false,
            reason: 'Select a target repeater first',
          )
        : (!targetExists
              ? const WardrivingModeAvailability(
                  mode: WardrivingMode.targeted,
                  enabled: false,
                  reason: 'Target repeater is unavailable in this zone',
                )
              : result(WardrivingMode.targeted, tx: true));
    return {
      WardrivingMode.passive: result(WardrivingMode.passive),
      WardrivingMode.active: result(WardrivingMode.active, tx: true),
      WardrivingMode.hybrid: result(WardrivingMode.hybrid, tx: true),
      WardrivingMode.targeted: targeted,
    };
  }

  Future<void> refreshModeAvailability() async {
    if (_disposed || _loadingModeAvailability) return;
    _loadingModeAvailability = true;
    notifyListeners();
    try {
      final location = currentLocation;
      var zoneRestricted = false;
      if (!isOfflineMode &&
          !_apiService.hasSession &&
          location != null &&
          (_lastZoneCheckAt == null ||
              _now().difference(_lastZoneCheckAt!) >=
                  const Duration(minutes: 1))) {
        final response = await _apiService.checkZoneStatus(
          lat: location.latitude,
          lon: location.longitude,
          accuracyMeters: location.accuracyMeters,
          appVersion: _appVersion ?? 'gulf-coast-mesh-app',
        );
        zoneRestricted =
            response.isSuccess && response.data?['in_zone'] == false;
      }
      if (!isOfflineMode && _apiService.zone != null && _repeaters.isEmpty) {
        await refreshRepeaters();
      }
      final target = _settingsService.settings.wardrivingTargetRepeaterId;
      _modeAvailability = evaluateModeAvailability(
        connected: _connector.isConnected && !_connector.isDemoMode,
        apiConfigured: hasApiKey,
        gpsAvailable: location != null,
        offline: isOfflineMode,
        hasSession: _apiService.hasSession,
        txAllowed: _apiService.txAllowed,
        floodDisabled: _apiService.floodDisabled,
        hybridEnforced: _apiService.enforceHybrid,
        targetRepeaterId: target,
        targetExists:
            _repeaters.isEmpty ||
            _repeaters.any((r) => r.targetId == target.trim().toUpperCase()),
        zoneRestricted: zoneRestricted,
      );
    } finally {
      _loadingModeAvailability = false;
      notifyListeners();
    }
  }

  WardrivingStats get stats => WardrivingStats(
    txCount: _txCount,
    rxCount: _rxCount,
    discCount: _discCount,
    traceCount: _traceCount,
    uploadedCount: _queueService.uploadedCount,
    queueCount: isOfflineMode
        ? _offlineSamples.length
        : _queueService.queueCount,
  );

  Future<void> ensureStarted() async {
    if (_disposed) return;
    await _offlineSessionService.init();
    await _refreshGps();
    unawaited(refreshModeAvailability());
    _syncModeTimer();
  }

  String? exportOfflineSession(String id) {
    final session = _offlineSessionService.get(id);
    return session == null ? null : jsonEncode(session.toJson());
  }

  Future<void> deleteOfflineSession(String id) async {
    await _offlineSessionService.delete(id);
    notifyListeners();
  }

  Future<bool> uploadOfflineSession(String id) =>
      _runControlOperation(() => _uploadOfflineSession(id));

  Future<bool> _uploadOfflineSession(String id) async {
    final session = _offlineSessionService.get(id);
    if (session == null || session.samples.isEmpty || !hasApiKey) return false;
    if (isRunning) {
      _statusMessage = 'Stop the live wardrive before uploading offline data';
      notifyListeners();
      return false;
    }
    if (!_connector.isConnected ||
        _connector.isDemoMode ||
        !await _locationService.start()) {
      return false;
    }
    String? temporarySessionId;
    try {
      final location = await _waitForValidLocation(maxAccuracyMeters: 50);
      if (_stopping || _disposed) return false;
      if (location == null) {
        _statusMessage = 'GPS unavailable';
        notifyListeners();
        return false;
      }
      temporarySessionId = await _acquireOfflineUploadSession(
        session,
        location,
      );
      if (temporarySessionId == null) {
        return false;
      }
      for (var start = 0; start < session.samples.length; start += 50) {
        if (_stopping || _disposed) return false;
        final end = min(start + 50, session.samples.length);
        final response = await _apiService.submitWardriveDataWithSessionId(
          session.samples.sublist(start, end),
          temporarySessionId,
        );
        if (classifyUploadResponse(response) !=
            MeshMapperUploadResult.success) {
          return false;
        }
      }
      await _offlineSessionService.save(session.copyWith(uploaded: true));
      notifyListeners();
      return true;
    } finally {
      if (temporarySessionId != null) {
        await _apiService.requestAuth(
          reason: 'disconnect',
          sessionId: temporarySessionId,
          skipSessionStore: true,
        );
      }
      if (!isRunning) {
        await _locationService.stop();
        if (_sessionState != WardrivingSessionState.error) {
          _sessionState = WardrivingSessionState.idle;
        }
        notifyListeners();
      }
    }
  }

  Future<String?> _acquireOfflineUploadSession(
    OfflineWardriveSession session,
    ValidatedWardrivingLocation location,
  ) async {
    _sessionState = WardrivingSessionState.acquiring;
    notifyListeners();
    final status = await _apiService.checkZoneStatus(
      lat: location.latitude,
      lon: location.longitude,
      accuracyMeters: location.accuracyMeters,
      appVersion: session.appVersion ?? _appVersion ?? 'gulf-coast-mesh-app',
    );
    if (!status.isSuccess || status.data?['in_zone'] == false) {
      _sessionState = WardrivingSessionState.error;
      _statusMessage = formatMeshMapperZoneStatusError(status);
      notifyListeners();
      return null;
    }
    final iataCode = _apiService.zone;
    if (iataCode == null) {
      _sessionState = WardrivingSessionState.error;
      _statusMessage = 'MeshMapper zone unavailable';
      notifyListeners();
      return null;
    }
    final key =
        session.devicePublicKey ??
        (_connector.selfPublicKey == null
            ? null
            : pubKeyToHex(_connector.selfPublicKey!));
    var response = await _apiService.requestAuth(
      reason: 'connect',
      publicKey: key,
      who: session.deviceName ?? _connector.selfName,
      appVersion: session.appVersion ?? _appVersion,
      power: session.powerWatts,
      model: 'gulf-coast-mesh-app-offline',
      lat: location.latitude,
      lon: location.longitude,
      accuracyMeters: location.accuracyMeters,
      iataCode: iataCode,
      offlineMode: true,
      skipSessionStore: true,
    );
    if (!response.isSuccess && shouldAttemptMeshMapperRegistration(response)) {
      try {
        final contactUri =
            session.contactUri ?? await _connector.exportSelfContactUri();
        response = await _apiService.requestAuth(
          reason: 'register',
          contactUri: contactUri,
          who: session.deviceName ?? _connector.selfName,
          appVersion: session.appVersion ?? _appVersion,
          power: session.powerWatts,
          model: 'gulf-coast-mesh-app-offline',
          lat: location.latitude,
          lon: location.longitude,
          accuracyMeters: location.accuracyMeters,
          iataCode: iataCode,
          offlineMode: true,
          skipSessionStore: true,
        );
      } catch (_) {
        // The friendly auth error below is more useful than transport details.
      }
    }
    final id = response.data?['session_id'] as String?;
    if (!response.isSuccess || id == null || id.isEmpty) {
      _sessionState = WardrivingSessionState.error;
      _statusMessage = formatMeshMapperAuthError(response);
      notifyListeners();
      return null;
    }
    _sessionState = WardrivingSessionState.ready;
    return id;
  }

  Future<bool> startPassive() =>
      _runControlOperation(() => _startMode(WardrivingMode.passive));
  Future<bool> startActive() =>
      _runControlOperation(() => _startMode(WardrivingMode.active));
  Future<bool> startHybrid() =>
      _runControlOperation(() => _startMode(WardrivingMode.hybrid));
  Future<bool> startTargeted([String? repeaterId]) {
    return _runControlOperation(() {
      _targetRepeaterId = repeaterId?.trim().isNotEmpty == true
          ? repeaterId!.trim()
          : _settingsService.settings.wardrivingTargetRepeaterId.trim();
      return _startMode(WardrivingMode.targeted);
    });
  }

  Future<bool> _runControlOperation(Future<bool> Function() action) async {
    if (_disposed || isBusy || isRunning || _tickInFlight) return false;
    final completion = Completer<void>();
    _sessionOffline = _settingsService.settings.wardrivingOfflineMode;
    _controlOperation = completion.future;
    notifyListeners();
    try {
      final result = await action();
      return result;
    } catch (error) {
      _sessionState = WardrivingSessionState.error;
      _statusMessage = 'Wardriving failed: $error';
      return false;
    } finally {
      try {
        if (!isRunning) {
          await _checkpointOfflineSession();
          _offlineSessionId = null;
          _offlineSamples = <Map<String, dynamic>>[];
          await _locationService.stop();
          await _apiService.disconnect();
        }
      } finally {
        _controlOperation = null;
        if (!isRunning && !_stopping) _sessionOffline = null;
        completion.complete();
        notifyListeners();
      }
    }
  }

  /// Sends one TX ping without changing the selected automatic mode or
  /// starting Android background execution.
  Future<bool> sendManualPing() => _runControlOperation(_sendManualPing);

  Future<bool> _sendManualPing() async {
    final lastManual = _lastManualPingAt;
    if (lastManual != null &&
        _now().difference(lastManual) < const Duration(seconds: 15)) {
      _statusMessage = 'Manual ping cooldown is 15 seconds';
      notifyListeners();
      return false;
    }
    if (!await _prepareStart(WardrivingMode.active, automatic: false)) {
      return false;
    }
    if (!_canOperate) return false;
    try {
      final location = await _waitForValidLocation(
        maxAccuracyMeters: isOfflineMode
            ? WardrivingLocationService.maxAccuracyMeters
            : 50,
      );
      if (location == null) {
        _statusMessage = 'GPS unavailable';
        notifyListeners();
        return false;
      }
      if (!_canOperate) return false;
      _setCurrentLocation(location);
      if (!isOfflineMode &&
          !await _ensureSession(location.latitude, location.longitude)) {
        notifyListeners();
        return false;
      }
      if (!isOfflineMode &&
          (!_apiService.txAllowed || _apiService.floodDisabled)) {
        _statusMessage = _apiService.floodDisabled
            ? 'Flood traffic disabled for this session'
            : 'TX not allowed for this session';
        notifyListeners();
        return false;
      }
      await _startOfflineSession();
      if (!_canOperate) return false;
      final sent = await _sendTxPing(location.latitude, location.longitude);
      if (sent) _lastManualPingAt = _now();
      return sent;
    } finally {
      if (!isRunning) {
        if (!isOfflineMode) {
          await _queueService.flush(contactPrefix: contactPrefixForUpload());
          await _apiService.disconnect();
        }
        await _locationService.stop();
        if (_sessionState != WardrivingSessionState.error) {
          _sessionState = WardrivingSessionState.idle;
        }
        notifyListeners();
      }
    }
  }

  Future<bool> _startMode(WardrivingMode requestedMode) async {
    if (!await _prepareStart(requestedMode)) return false;
    if (!_canOperate) return false;
    if (_settingsService.settings.wardrivingBackgroundEnabled &&
        !await _locationService.ensureBackgroundPermission()) {
      _statusMessage =
          'Always location permission is required for background wardriving';
      notifyListeners();
      return false;
    }
    final offline = isOfflineMode;
    final position = await _waitForValidLocation(
      maxAccuracyMeters: offline
          ? WardrivingLocationService.maxAccuracyMeters
          : 50,
    );
    if (position == null) {
      _statusMessage = 'GPS unavailable';
      notifyListeners();
      return false;
    }
    if (!_canOperate) return false;
    _setCurrentLocation(position);
    _lastSentLat = null;
    _lastSentLon = null;
    _lastAutomaticOperationAt = null;

    if (requestedMode == WardrivingMode.active ||
        requestedMode == WardrivingMode.hybrid) {
      if (!offline && !_apiService.txAllowed && _apiService.hasSession) {
        _statusMessage = 'TX not allowed for this session';
        notifyListeners();
        return false;
      }
      if (!offline && _apiService.floodDisabled) {
        _statusMessage = 'Flood traffic disabled for this session';
        notifyListeners();
        return false;
      }
      final channel = await _ensureWardrivingChannel();
      if (channel == null) {
        _statusMessage = 'Could not join #wardriving channel';
        notifyListeners();
        return false;
      }
    }

    final sessionOk =
        offline || await _ensureSession(position.latitude, position.longitude);
    if (!sessionOk) {
      notifyListeners();
      return false;
    }
    if (!_canOperate) return false;
    notifyListeners();

    if (!offline &&
        (requestedMode == WardrivingMode.active ||
            requestedMode == WardrivingMode.hybrid ||
            requestedMode == WardrivingMode.targeted) &&
        !_apiService.txAllowed) {
      _statusMessage = 'TX not allowed for this session';
      notifyListeners();
      return false;
    }

    if (!offline &&
        (requestedMode == WardrivingMode.active ||
            requestedMode == WardrivingMode.hybrid) &&
        _apiService.floodDisabled) {
      _statusMessage = 'Flood traffic disabled for this session';
      notifyListeners();
      return false;
    }

    if (!offline &&
        requestedMode == WardrivingMode.active &&
        _apiService.enforceHybrid) {
      _statusMessage = 'Active mode not available for this session';
      notifyListeners();
      return false;
    }

    await _startOfflineSession();
    if (!_canOperate) return false;
    _mode = requestedMode;
    _sessionState = WardrivingSessionState.running;
    _hybridNextIsDiscovery = true;
    _statusMessage = null;
    _discTracker.hopBytes = _apiService.apiHopBytes;
    if (!offline) unawaited(refreshRepeaters());
    if (!offline) {
      _apiService.enableHeartbeat(gpsProvider: _heartbeatLocation);
    }
    if (_settingsService.settings.wardrivingBackgroundEnabled) {
      unawaited(
        _backgroundService.startWardriving(
          mode: requestedMode.name,
          samples: _mapEvents.length,
        ),
      );
    }
    _syncModeTimer();
    unawaited(_runModeTick());
    notifyListeners();
    return true;
  }

  Future<bool> _prepareStart(
    WardrivingMode requestedMode, {
    bool automatic = true,
  }) async {
    if (_connector.isDemoMode) {
      _statusMessage = 'Wardriving is unavailable in demo mode';
    } else if (!_connector.isConnected) {
      _statusMessage = 'Connect a MeshCore device first';
    } else if (!_settingsService.settings.wardrivingDisclosureAccepted) {
      _statusMessage = 'Accept the wardriving disclosure first';
    } else if (!hasApiKey && !isOfflineMode) {
      _statusMessage = 'MeshMapper API not configured for this build';
    } else if (requestedMode == WardrivingMode.targeted &&
        (_targetRepeaterId ?? '').isEmpty) {
      _statusMessage = 'Select a target repeater first';
    } else if (requestedMode == WardrivingMode.targeted &&
        !RegExp(
          r'^(?:[0-9a-fA-F]{2}|[0-9a-fA-F]{4}|[0-9a-fA-F]{8})$',
        ).hasMatch(_targetRepeaterId ?? '')) {
      _statusMessage = 'Target repeater ID must be hexadecimal';
    } else {
      final started = await _locationService.start(
        background:
            automatic && _settingsService.settings.wardrivingBackgroundEnabled,
      );
      if (!started) {
        _statusMessage = 'Location permission required';
      } else {
        return true;
      }
    }
    notifyListeners();
    return false;
  }

  Future<void> stop({String? preserveError}) {
    final pending = _stopOperation;
    if (pending != null) return pending;
    _stopping = true;
    final operation = _stop(preserveError: preserveError);
    _stopOperation = operation;
    return operation.whenComplete(() {
      _stopOperation = null;
      _stopping = false;
      if (!isRunning) _sessionOffline = null;
      notifyListeners();
    });
  }

  Future<void> _stop({String? preserveError}) async {
    _sessionState = WardrivingSessionState.stopping;
    notifyListeners();
    _modeTimer?.cancel();
    _modeTimer = null;
    await _controlOperation;
    final activeOperation = _activeOperation;
    if (activeOperation != null) await activeOperation;
    _rxLogger.flush();
    await _pendingRxFlush;
    if (!isOfflineMode) {
      await _queueService.flush(contactPrefix: contactPrefixForUpload());
    }
    await _checkpointOfflineSession();
    _mode = WardrivingMode.off;
    _txTracker.stopTracking();
    _discTracker.stopTracking();
    _traceTracker.stopTracking();
    _apiService.disableHeartbeat();
    await _apiService.disconnect();
    await _locationService.stop();
    await _backgroundService.finishWardriving();
    _offlineSessionId = null;
    _offlineSamples = <Map<String, dynamic>>[];
    _repeaters = const [];
    _mapEvents.clear();
    _sessionState = preserveError == null
        ? WardrivingSessionState.idle
        : WardrivingSessionState.error;
    _statusMessage = preserveError;
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final wasForeground = _isForeground;
    _isForeground = state == AppLifecycleState.resumed;
    if (wasForeground != _isForeground && isRunning) {
      final backgroundEnabled =
          _settingsService.settings.wardrivingBackgroundEnabled;
      _sessionState = _isForeground || backgroundEnabled
          ? WardrivingSessionState.running
          : WardrivingSessionState.pausedBackground;
      if (!_isForeground && backgroundEnabled) {
        unawaited(
          _backgroundService.startWardriving(
            mode: _mode.name,
            samples: _mapEvents.length,
          ),
        );
      }
      _syncModeTimer();
      notifyListeners();
    }
  }

  void _onDependenciesChanged() {
    final connected = _connector.isConnected && !_connector.isDemoMode;
    final settings = _settingsService.settings;
    if (_lastConnected == connected && identical(_lastSettings, settings)) {
      return;
    }
    _lastConnected = connected;
    _lastSettings = settings;
    if (!connected && (isRunning || _controlOperation != null)) {
      unawaited(stop());
    }
    _syncModeTimer();
    unawaited(refreshModeAvailability());
    notifyListeners();
  }

  void _syncModeTimer() {
    if (!isRunning || !_canOperate) {
      _modeTimer?.cancel();
      _modeTimer = null;
      return;
    }

    final intervalSec = max(
      _settingsService.settings.wardrivingIntervalSec,
      _apiService.minModeInterval,
    );
    final interval = Duration(seconds: intervalSec);
    if (_modeTimer?.isActive == true && _modeTimerInterval == interval) return;
    _modeTimer?.cancel();
    _modeTimerInterval = interval;
    _modeTimer = Timer.periodic(interval, (_) {
      unawaited(_runModeTick());
    });
  }

  Future<void> _runModeTick() async {
    if (_tickInFlight) return;
    if (!isRunning || !_canOperate) return;
    _tickInFlight = true;
    final operation = Completer<void>();
    _activeOperation = operation.future;
    try {
      // Capture a current hardware fix for automatic samples while driving.
      final position = await _locationService.getFreshLocation();
      if (!_canOperate) return;
      if (position == null) {
        _statusMessage = 'GPS unavailable';
        notifyListeners();
        return;
      }

      if (!_shouldSendForDistance(position.latitude, position.longitude)) {
        return;
      }

      _setCurrentLocation(position);

      if (!isOfflineMode && !await _validateCurrentZone(position)) {
        return;
      }
      if (!_canOperate) return;

      if (!isOfflineMode &&
          _mode != WardrivingMode.passive &&
          (!_apiService.txAllowed ||
              (_mode != WardrivingMode.targeted && _apiService.floodDisabled) ||
              (_mode == WardrivingMode.active && _apiService.enforceHybrid))) {
        _statusMessage =
            'This mode is unavailable for the current MeshMapper session';
        notifyListeners();
        return;
      }

      final now = _now();
      final interval = Duration(
        seconds: max(
          _settingsService.settings.wardrivingIntervalSec,
          _apiService.minModeInterval,
        ),
      );
      if (_lastAutomaticOperationAt != null &&
          now.difference(_lastAutomaticOperationAt!) < interval) {
        return;
      }
      _lastAutomaticOperationAt = now;

      switch (_mode) {
        case WardrivingMode.passive:
          await _sendDiscovery(position.latitude, position.longitude);
        case WardrivingMode.active:
          await _sendTxPing(position.latitude, position.longitude);
        case WardrivingMode.hybrid:
          if (_hybridNextIsDiscovery) {
            await _sendDiscovery(position.latitude, position.longitude);
          } else {
            await _sendTxPing(position.latitude, position.longitude);
          }
          _hybridNextIsDiscovery = !_hybridNextIsDiscovery;
        case WardrivingMode.targeted:
          await _sendTrace(position.latitude, position.longitude);
        case WardrivingMode.off:
          break;
      }
    } finally {
      _tickInFlight = false;
      if (!operation.isCompleted) operation.complete();
      if (identical(_activeOperation, operation.future)) {
        _activeOperation = null;
      }
    }
  }

  Future<bool> _validateCurrentZone(
    ValidatedWardrivingLocation position,
  ) async {
    if (!_apiService.hasSession) {
      final location = await _waitForValidLocation(maxAccuracyMeters: 50);
      if (location == null ||
          !_canOperate ||
          !await _ensureSession(location.latitude, location.longitude)) {
        return false;
      }
      _sessionState = WardrivingSessionState.running;
      _apiService.enableHeartbeat(gpsProvider: _heartbeatLocation);
      return true;
    }
    final now = _now();
    if (_lastZoneCheckAt != null &&
        now.difference(_lastZoneCheckAt!) < const Duration(minutes: 1)) {
      return _zoneAllowed;
    }
    _lastZoneCheckAt = now;
    final previousZone = _apiService.zone;
    final status = await _apiService.checkZoneStatus(
      lat: position.latitude,
      lon: position.longitude,
      accuracyMeters: position.accuracyMeters,
      appVersion: _appVersion ?? 'gulf-coast-mesh-app',
    );
    if (status.error != null ||
        (status.httpStatus != null && status.httpStatus != 200)) {
      _statusMessage = 'MeshMapper zone check deferred (network unavailable)';
      notifyListeners();
      return _zoneAllowed;
    }
    if (!status.isSuccess || status.data?['in_zone'] == false) {
      _zoneAllowed = false;
      _statusMessage = formatMeshMapperZoneStatusError(status);
      notifyListeners();
      return false;
    }
    final currentZone = _apiService.zone;
    if (currentZone == null) {
      _zoneAllowed = false;
      _statusMessage = 'MeshMapper zone unavailable';
      notifyListeners();
      return false;
    }
    _zoneAllowed = true;
    if (previousZone != null &&
        previousZone != currentZone &&
        _apiService.hasSession) {
      await _queueService.flush(contactPrefix: contactPrefixForUpload());
      await _apiService.disconnect();
      if (!await _ensureSession(position.latitude, position.longitude)) {
        return false;
      }
      _apiService.enableHeartbeat(gpsProvider: _heartbeatLocation);
      unawaited(refreshRepeaters());
    }
    return true;
  }

  ({double lat, double lon})? _heartbeatLocation() {
    final location = currentLocation;
    return location == null
        ? null
        : (lat: location.latitude, lon: location.longitude);
  }

  bool _shouldSendForDistance(double lat, double lon) {
    if (_lastSentLat == null || _lastSentLon == null) return true;
    final meters = Geolocator.distanceBetween(
      _lastSentLat!,
      _lastSentLon!,
      lat,
      lon,
    );
    final threshold = max(
      kWardrivingMinDistanceMeters,
      _settingsService.settings.wardrivingMinDistanceMeters,
    );
    return meters >= threshold;
  }

  Future<void> _sendDiscovery(double lat, double lon) async {
    final now = _now();
    if (_lastDiscoveryAt != null &&
        now.difference(_lastDiscoveryAt!) < const Duration(seconds: 30)) {
      return;
    }
    _discTagCounter = (_discTagCounter + 1) & 0x7fffffff;
    final tag = _uint32Bytes(_discTagCounter);
    _discTracker.hopBytes = _apiService.apiHopBytes;
    _discTracker.startTracking(
      tag: tag,
      windowDuration: const Duration(seconds: 7),
    );
    final frame = buildSendDiscoverReqFrame(tag: _discTagCounter);
    try {
      await _connector.sendFrame(frame);
    } catch (_) {
      _discTracker.stopTracking();
      _addMapEvent(WardrivingEventType.discovery, lat, lon, false);
      return;
    }
    _lastDiscoveryAt = now;
    _lastSentLat = lat;
    _lastSentLon = lon;

    await Future<void>.delayed(const Duration(seconds: 7));
    _discTracker.stopTracking();

    final settings = _settingsService.settings;
    final power = powerWattsFromDbm(_connector.currentTxPower);
    final timestamp = now.toUtc();

    if (_discTracker.discoveries.isEmpty) {
      if (_apiService.enforceDiscDrop || settings.wardrivingDiscDropEnabled) {
        final noiseFloor = await _readNoiseFloor();
        await _storeItem(
          WardrivingQueueItem.disc(
            latitude: lat,
            longitude: lon,
            heardRepeats: 'None',
            timestamp: timestamp,
            externalAntenna: settings.wardrivingExternalAntenna,
            powerWatts: power,
            noiseFloor: noiseFloor,
            contactPrefix: contactPrefixForUpload(),
            iata: _apiService.zone,
          ),
        );
        _discCount++;
        _addMapEvent(WardrivingEventType.discovery, lat, lon, false);
      }
      return;
    }

    final noiseFloor = await _readNoiseFloor();
    for (final response in _discTracker.discoveries.values) {
      final repeaterId = response.repeaterId(_apiService.apiHopBytes);
      await _storeItem(
        WardrivingQueueItem.disc(
          latitude: lat,
          longitude: lon,
          heardRepeats:
              '$repeaterId:${response.nodeTypeName}:${response.localSnr.toStringAsFixed(2)}:${response.localRssi}:${response.remoteSnr.toStringAsFixed(2)}:${response.pubkeyHex}',
          timestamp: timestamp,
          externalAntenna: settings.wardrivingExternalAntenna,
          powerWatts: power,
          noiseFloor: noiseFloor,
          contactPrefix: contactPrefixForUpload(),
          iata: _apiService.zone,
        ),
      );
      _discCount++;
      _addMapEvent(
        WardrivingEventType.discovery,
        lat,
        lon,
        true,
        repeaterId: repeaterId,
        snr: response.localSnr,
      );
    }
    notifyListeners();
  }

  Future<bool> _sendTxPing(double lat, double lon) async {
    final channel = await _ensureWardrivingChannel();
    if (channel == null || !_canOperate) return false;
    final timestamp = _now().toUtc();
    final zone = _apiService.zone;

    final settings = _settingsService.settings;
    final power = powerWattsFromDbm(_connector.currentTxPower);
    final offline = isOfflineMode;
    if (!offline && _apiService.resumeCounter >= 2047) {
      _statusMessage = 'MeshMapper session ping limit reached';
      notifyListeners();
      return false;
    }
    final coords = '${lat.toStringAsFixed(5)},${lon.toStringAsFixed(5)}';
    final counter = offline ? null : _apiService.nextPingCounter();
    final wireTagSessionId = offline ? null : _apiService.sessionId;
    final wireTag = counter == null ? null : _currentWireTag(counter: counter);
    if (!offline && wireTag == null) {
      _statusMessage = 'MeshMapper wire tag could not be generated';
      notifyListeners();
      return false;
    }
    final message = offline
        ? 'MM:$coords'
        : settings.wardrivingBroadcastCoordinates
        ? '$wireTag:$coords'
        : wireTag!;

    final channelHash = computeChannelHash(channel.psk);
    _configureTxTracker(settings);
    _txTracker.startTracking(
      payload: message,
      channelHash: channelHash,
      channelKey: channel.psk,
      windowDuration: echoWindow,
    );

    try {
      await _connector.sendChannelMessage(
        channel,
        message,
        addToLocalHistory: false,
      );
    } catch (_) {
      _txTracker.stopTracking();
      _addMapEvent(WardrivingEventType.tx, lat, lon, false);
      return false;
    }

    await Future<void>.delayed(echoWindow);
    _txTracker.stopTracking();

    final echoes = _txTracker.repeaters.values.toList(growable: false);
    final heardRepeats = echoes.isEmpty
        ? 'None'
        : echoes
              .map(
                (echo) =>
                    '${echo.repeaterId}(${echo.snr?.toStringAsFixed(2) ?? 'null'})',
              )
              .join(',');

    final noiseFloor = await _readNoiseFloor();
    await _storeItem(
      WardrivingQueueItem.tx(
        latitude: lat,
        longitude: lon,
        heardRepeats: heardRepeats,
        timestamp: timestamp,
        externalAntenna: settings.wardrivingExternalAntenna,
        powerWatts: power,
        noiseFloor: noiseFloor,
        wireTag: wireTag,
        pingCounter: counter,
        wireTagSessionId: wireTagSessionId,
        contactPrefix: contactPrefixForUpload(),
        iata: zone,
      ),
    );
    _txCount++;
    _lastSentLat = lat;
    _lastSentLon = lon;
    _addMapEvent(
      WardrivingEventType.tx,
      lat,
      lon,
      echoes.isNotEmpty,
      repeaterId: echoes.isEmpty ? null : echoes.first.repeaterId,
      snr: echoes.isEmpty ? null : echoes.first.snr,
    );
    notifyListeners();
    return true;
  }

  Future<void> _sendTrace(double lat, double lon) async {
    final target =
        (_targetRepeaterId ??
                _settingsService.settings.wardrivingTargetRepeaterId)
            .trim()
            .replaceAll(':', '')
            .replaceAll(' ', '');
    final hopBytes = target.length <= 2
        ? 1
        : target.length <= 4
        ? 2
        : 4;
    if (target.length < hopBytes * 2) {
      _statusMessage = 'Target repeater ID is too short';
      notifyListeners();
      return;
    }
    late final Uint8List targetBytes;
    try {
      targetBytes = Uint8List.fromList(
        List<int>.generate(
          hopBytes,
          (index) =>
              int.parse(target.substring(index * 2, index * 2 + 2), radix: 16),
        ),
      );
    } on FormatException {
      _statusMessage = 'Target repeater ID must be hexadecimal';
      notifyListeners();
      return;
    }
    final random = Random.secure();
    final tagValue = random.nextInt(0x7fffffff);
    final tag = _uint32Bytes(tagValue);
    _traceTracker.startTracking(
      tag: tag,
      windowDuration: const Duration(seconds: 7),
    );
    try {
      await _connector.sendFrame(
        buildSendTracePathFrame(
          tag: tagValue,
          target: targetBytes,
          hopBytes: hopBytes,
        ),
      );
    } catch (_) {
      _traceTracker.stopTracking();
      _addMapEvent(
        WardrivingEventType.trace,
        lat,
        lon,
        false,
        repeaterId: target,
      );
      return;
    }
    // A sent trace consumes the movement allowance even when the target does
    // not answer. Otherwise a stationary drive repeatedly probes an absent node.
    _lastSentLat = lat;
    _lastSentLon = lon;
    await Future<void>.delayed(const Duration(seconds: 7));
    final response = _traceTracker.response;
    _traceTracker.stopTracking();
    if (response == null) {
      _addMapEvent(
        WardrivingEventType.trace,
        lat,
        lon,
        false,
        repeaterId: target,
      );
      return;
    }
    final snrs = response.pathSnr;
    final remoteSnr = snrs.isEmpty ? 0.0 : snrs.first;
    final localSnr = snrs.length > 1
        ? snrs[1]
        : _traceTracker.pendingBleSnr ?? remoteSnr;
    final localRssi = _traceTracker.pendingBleRssi;
    final noiseFloor = await _readNoiseFloor();
    final settings = _settingsService.settings;
    await _storeItem(
      WardrivingQueueItem.trace(
        latitude: lat,
        longitude: lon,
        heardRepeats:
            '$target:${localSnr.toStringAsFixed(2)}:${localRssi ?? ''}:${remoteSnr.toStringAsFixed(2)}',
        timestamp: DateTime.now().toUtc(),
        externalAntenna: settings.wardrivingExternalAntenna,
        noiseFloor: noiseFloor,
        powerWatts: powerWattsFromDbm(_connector.currentTxPower),
        contactPrefix: contactPrefixForUpload(),
        iata: _apiService.zone,
      ),
    );
    _traceCount++;
    _lastSentLat = lat;
    _lastSentLon = lon;
    _addMapEvent(
      WardrivingEventType.trace,
      lat,
      lon,
      true,
      repeaterId: target,
      snr: localSnr,
    );
    notifyListeners();
  }

  String? _currentWireTag({int? counter}) {
    final sessionId = _apiService.sessionId;
    if (sessionId == null || sessionId.isEmpty) return null;
    final value = counter ?? max(1, _apiService.resumeCounter);
    try {
      return MeshMapperWireTag.encode(sessionId, value, _apiService.wireKey);
    } catch (_) {
      return null;
    }
  }

  Uint8List _uint32Bytes(int value) => Uint8List.fromList([
    value & 0xff,
    (value >> 8) & 0xff,
    (value >> 16) & 0xff,
    (value >> 24) & 0xff,
  ]);

  Future<int?> _readNoiseFloor() async {
    return await _connector.getNoiseFloor() ?? _connector.lastNoiseFloor;
  }

  void _configureTxTracker(AppSettings settings) {
    _txTracker.carpeaterPrefix = settings.wardrivingCarpeaterPrefix.isEmpty
        ? null
        : settings.wardrivingCarpeaterPrefix;
    _txTracker.disableRssiFilter = settings.wardrivingDisableRssiFilter;
    _txTracker.shouldIgnoreRepeater = settings.wardrivingCarpeaterPrefix.isEmpty
        ? null
        : (id) => WardrivingTxTracker.matchesRepeaterPrefix(
            id,
            settings.wardrivingCarpeaterPrefix,
          );
  }

  void _configureRxLogger() {
    final settings = _settingsService.settings;
    _rxLogger.disableRssiFilter = settings.wardrivingDisableRssiFilter;
    _rxLogger.carpeaterPrefix = settings.wardrivingCarpeaterPrefix.isEmpty
        ? null
        : settings.wardrivingCarpeaterPrefix;
    // Passive logging also hears regional channels that are not installed in
    // the radio's limited channel slots. MeshMapper supplies their hashtags.
    final keys = <Uint8List>[
      Channel.parsePskHex(Channel.publicChannelPsk),
      Channel.derivePskFromHashtag(wardrivingChannelDisplayName),
      for (final name in _apiService.channels)
        if (name.trim().isNotEmpty && name.toLowerCase() != 'public')
          Channel.derivePskFromHashtag(name.trim()),
      if (isOfflineMode)
        for (final channel in _connector.channels)
          if (!channel.isEmpty) channel.psk,
    ];
    _rxLogger.shouldAcceptPacket = (packet) {
      if (!packet.isGroupText) return isValidWardrivingAdvert(packet.payload);
      return keys.any(
        (key) =>
            computeChannelHash(key) == packet.channelHash &&
            decryptGroupTextMessage(key, packet.payload) != null,
      );
    };
  }

  Future<Channel?> _ensureWardrivingChannel() async {
    final existing = findWardrivingChannel(_connector.channels);
    if (existing != null) return existing;
    return joinWardrivingChannel(_connector);
  }

  Future<bool> _ensureSession(
    double lat,
    double lon, {
    bool offlineUpload = false,
  }) async {
    _sessionState = WardrivingSessionState.acquiring;
    notifyListeners();

    if (_apiService.hasSession) {
      final valid = await _apiService.checkSessionValid(lat: lat, lon: lon);
      if (valid.isValid) {
        _sessionState = WardrivingSessionState.ready;
        if (valid.reason == 'transient') {
          _statusMessage = 'Continuing without heartbeat (network blip)';
        }
        return true;
      }
    }

    final selfKey = _connector.selfPublicKey;
    if (selfKey == null) {
      _sessionState = WardrivingSessionState.error;
      _statusMessage = 'Device identity unavailable';
      return false;
    }

    final power = powerWattsFromDbm(_connector.currentTxPower);
    final accuracy = _lastAccuracyMeters ?? 999;
    final zoneStatus = await _apiService.checkZoneStatus(
      lat: lat,
      lon: lon,
      accuracyMeters: accuracy,
      appVersion: _appVersion ?? 'gulf-coast-mesh-app',
    );
    if (zoneStatus.error != null ||
        (zoneStatus.httpStatus != null && zoneStatus.httpStatus != 200)) {
      _sessionState = WardrivingSessionState.error;
      _statusMessage = formatMeshMapperZoneStatusError(zoneStatus);
      return false;
    }
    if (zoneStatus.isSuccess && zoneStatus.data?['in_zone'] == false) {
      _sessionState = WardrivingSessionState.error;
      _statusMessage = formatMeshMapperZoneStatusError(zoneStatus);
      return false;
    }
    if (!zoneStatus.isSuccess) {
      _sessionState = WardrivingSessionState.error;
      _statusMessage = formatMeshMapperZoneStatusError(zoneStatus);
      return false;
    }
    _lastZoneCheckAt = _now();
    _zoneAllowed = true;
    final iataCode = _apiService.zone;
    if (iataCode == null) {
      _sessionState = WardrivingSessionState.error;
      _statusMessage = 'MeshMapper zone unavailable';
      return false;
    }

    final appVersion = _appVersion ?? 'gulf-coast-mesh-app';
    final deviceName = _connector.selfName;
    final publicKeyHex = pubKeyToHex(selfKey);

    final connectResponse = await _apiService.requestAuth(
      reason: 'connect',
      publicKey: publicKeyHex,
      who: deviceName,
      appVersion: appVersion,
      power: power,
      model: 'gulf-coast-mesh-app',
      lat: lat,
      lon: lon,
      accuracyMeters: accuracy,
      iataCode: iataCode,
      offlineMode: offlineUpload,
    );

    if (connectResponse.isSuccess && _apiService.hasSession) {
      _sessionState = WardrivingSessionState.ready;
      return true;
    }

    if (!shouldAttemptMeshMapperRegistration(connectResponse)) {
      _sessionState = WardrivingSessionState.error;
      _statusMessage = formatMeshMapperAuthError(connectResponse);
      return false;
    }

    try {
      final contactUri = await _connector.exportSelfContactUri();
      final registerResponse = await _apiService.requestAuth(
        reason: 'register',
        contactUri: contactUri,
        who: deviceName,
        appVersion: appVersion,
        power: power,
        model: 'gulf-coast-mesh-app',
        lat: lat,
        lon: lon,
        accuracyMeters: accuracy,
        iataCode: iataCode,
        offlineMode: offlineUpload,
      );

      if (registerResponse.isSuccess && _apiService.hasSession) {
        _sessionState = WardrivingSessionState.ready;
        return true;
      }

      _sessionState = WardrivingSessionState.error;
      _statusMessage = formatMeshMapperAuthError(registerResponse);
      return false;
    } catch (_) {
      _sessionState = WardrivingSessionState.error;
      _statusMessage =
          'Companion not found in backend and failed to register via API';
      return false;
    }
  }

  Future<void> refreshRepeaters() async {
    final zone = _apiService.zone;
    if (zone == null || zone.isEmpty || _loadingRepeaters) return;
    _loadingRepeaters = true;
    notifyListeners();
    try {
      _repeaters = await _apiService.fetchRepeaters(zone);
    } finally {
      _loadingRepeaters = false;
      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> inspectCoverageCell(
    MeshMapperCoverageCell cell,
    int gridSize,
  ) async {
    final zone = _apiService.zone;
    if (zone == null) return const [];
    final steps =
        meshMapperCoverageGridSteps[gridSize] ??
        meshMapperCoverageGridSteps[300]!;
    return _apiService.fetchMapData(
      zone: zone,
      lat: (cell.latitudeIndex + 0.5) * steps.$1,
      lon: (cell.longitudeIndex + 0.5) * steps.$2,
      radiusMeters: gridSize * 0.75,
    );
  }

  Future<List<Map<String, dynamic>>> inspectRepeaterCoverage(
    String repeaterId,
  ) async {
    final zone = _apiService.zone;
    if (zone == null || repeaterId.isEmpty) return const [];
    return _apiService.fetchRepeaterCoverage(zone: zone, prefix: repeaterId);
  }

  Future<void> _refreshGps() async {
    final position = _locationService.lastLocation;
    if (position != null) {
      _setCurrentLocation(position);
    }
  }

  void _onFrame(Uint8List frame) {
    if (_disposed || frame.isEmpty) return;

    if (frame[0] == pushCodeLogRxData) {
      final packet = parseLogRxDataFrame(frame);
      if (packet == null) return;

      if (_traceTracker.captureBleMetadata(packet)) return;

      if (isRunning &&
          _canOperate &&
          (_mode == WardrivingMode.passive || _mode == WardrivingMode.hybrid)) {
        final location = currentLocation;
        if (location != null) {
          _configureRxLogger();
          _rxBatchLocation ??= location;
          _rxLogger.record(packet, hopBytes: _apiService.apiHopBytes);
        }
      }

      _txTracker.handlePacket(packet);
      return;
    }

    if (frame[0] == pushCodeControlData) {
      _discTracker.handleControlData(frame);
      return;
    }

    if (frame[0] == pushCodeTraceData) {
      _traceTracker.handleTraceData(frame);
    }
  }

  Future<void> _onRxBatchReady(
    Map<String, double> repeaters,
    ValidatedWardrivingLocation location,
  ) async {
    if (!isRunning || _disposed) return;
    if (_mode != WardrivingMode.passive && _mode != WardrivingMode.hybrid) {
      return;
    }

    final settings = _settingsService.settings;
    final power = powerWattsFromDbm(_connector.currentTxPower);
    final timestamp = DateTime.now().toUtc();

    for (final entry in repeaters.entries) {
      await _storeItem(
        WardrivingQueueItem.rx(
          latitude: location.latitude,
          longitude: location.longitude,
          heardRepeats: '${entry.key}(${entry.value.toStringAsFixed(2)})',
          timestamp: timestamp,
          externalAntenna: settings.wardrivingExternalAntenna,
          powerWatts: power,
          noiseFloor: _connector.lastNoiseFloor,
          contactPrefix: contactPrefixForUpload(),
          iata: _apiService.zone,
        ),
      );
      _rxCount++;
      _addMapEvent(
        WardrivingEventType.rx,
        location.latitude,
        location.longitude,
        true,
        repeaterId: entry.key,
        snr: entry.value,
      );
    }
    unawaited(_checkpointOfflineSession());
    notifyListeners();
  }

  Future<ValidatedWardrivingLocation?> _waitForValidLocation({
    double maxAccuracyMeters = WardrivingLocationService.maxAccuracyMeters,
  }) async {
    final existing = _locationService.lastLocation;
    if (existing != null &&
        _locationService.isFreshLocation(existing) &&
        existing.accuracyMeters <= maxAccuracyMeters) {
      return existing;
    }
    final fresh = await _locationService.getFreshLocation();
    if (fresh != null && fresh.accuracyMeters <= maxAccuracyMeters) {
      return fresh;
    }
    if (!_canOperate) return null;
    _firstLocationMaxAccuracy = maxAccuracyMeters;
    final pending = _firstLocationCompleter ??=
        Completer<ValidatedWardrivingLocation>();
    try {
      return await pending.future.timeout(const Duration(seconds: 15));
    } on TimeoutException {
      return null;
    } finally {
      if (identical(_firstLocationCompleter, pending)) {
        _firstLocationCompleter = null;
      }
    }
  }

  void _onLocation(ValidatedWardrivingLocation location) {
    final batchLocation = _rxBatchLocation;
    if (batchLocation != null &&
        Geolocator.distanceBetween(
              batchLocation.latitude,
              batchLocation.longitude,
              location.latitude,
              location.longitude,
            ) >=
            kWardrivingMinDistanceMeters) {
      _rxLogger.flush();
      _rxBatchLocation = null;
    }
    _setCurrentLocation(location);
    final pending = _firstLocationCompleter;
    if (pending != null &&
        !pending.isCompleted &&
        location.accuracyMeters <= _firstLocationMaxAccuracy) {
      pending.complete(location);
    }
    // iOS may suspend timers while backgrounded but still wake the app for a
    // location update. The shared interval/in-flight gates ensure at most one
    // eligible operation runs for that wakeup.
    if (isRunning && !_isForeground) unawaited(_runModeTick());
  }

  void _setCurrentLocation(ValidatedWardrivingLocation location) {
    _lastAccuracyMeters = location.accuracyMeters;
    notifyListeners();
  }

  void _addMapEvent(
    WardrivingEventType type,
    double latitude,
    double longitude,
    bool successful, {
    String? repeaterId,
    double? snr,
  }) {
    final event = WardrivingMapEvent(
      id: '${DateTime.now().microsecondsSinceEpoch}-${_mapEvents.length}',
      type: type,
      latitude: latitude,
      longitude: longitude,
      timestamp: DateTime.now().toUtc(),
      successful: successful,
      repeaterId: repeaterId,
      snr: snr,
    );
    _mapEvents.add(event);
    if (_mapEvents.length > 200) {
      _mapEvents.removeRange(0, _mapEvents.length - 200);
    }
    if (isRunning && _settingsService.settings.wardrivingBackgroundEnabled) {
      unawaited(
        _backgroundService.updateWardrivingStatus(
          mode: _mode.name,
          samples: _txCount + _rxCount + _discCount + _traceCount,
        ),
      );
    }
    notifyListeners();
  }

  Future<void> _startOfflineSession() async {
    if (!isOfflineMode || _offlineSessionId != null) {
      return;
    }
    await _offlineSessionService.init();
    _offlineSessionId =
        'wardrive-${DateTime.now().toUtc().millisecondsSinceEpoch}-${Random().nextInt(10000)}';
    _offlineSamples = <Map<String, dynamic>>[];
    final key = _connector.selfPublicKey;
    await _offlineSessionService.save(
      OfflineWardriveSession(
        id: _offlineSessionId!,
        createdAt: DateTime.now().toUtc(),
        samples: const [],
        devicePublicKey: key == null ? null : pubKeyToHex(key),
        deviceName: _connector.selfName,
        radioConfig:
            '${_connector.currentFreqHz ?? 0}/${_connector.currentBwHz ?? 0}/SF${_connector.currentSf ?? 0}/CR${_connector.currentCr ?? 0}',
        powerWatts: powerWattsFromDbm(_connector.currentTxPower),
        appVersion: _appVersion,
      ),
    );
  }

  Future<void> _checkpointOfflineSession() async {
    final id = _offlineSessionId;
    if (id == null || _offlineSamples.isEmpty) return;
    final existing = _offlineSessionService.get(id);
    if (existing == null) return;
    await _offlineSessionService.save(
      existing.copyWith(samples: _offlineSamples),
    );
  }

  Future<void> _storeItem(WardrivingQueueItem item) async {
    if (isOfflineMode) {
      _offlineSamples.add(
        item.toApiJson(contactPrefix: contactPrefixForUpload()),
      );
      await _checkpointOfflineSession();
      return;
    }
    await _queueService.enqueue(item);
  }

  String? contactPrefixForUpload() {
    if (!_settingsService.settings.wardrivingIncludeContactKey) return null;
    final key = _connector.selfPublicKey;
    if (key == null || key.isEmpty) return null;
    return pubKeyToHex(key).substring(0, min(12, pubKeyToHex(key).length));
  }

  Future<void> _loadAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      _appVersion = '${info.version}+${info.buildNumber}';
    } catch (_) {
      _appVersion = 'gulf-coast-mesh-app';
    }
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _modeTimer?.cancel();
    _frameSubscription?.cancel();
    _locationSubscription?.cancel();
    _backgroundTickSubscription?.cancel();
    if (_connectorListener != null) {
      _connector.removeListener(_connectorListener!);
    }
    if (_settingsListener != null) {
      _settingsService.removeListener(_settingsListener!);
    }
    if (_queueListener != null) {
      _queueService.removeListener(_queueListener!);
    }
    _txTracker.dispose();
    _discTracker.dispose();
    _traceTracker.dispose();
    _rxLogger.dispose();
    _apiService.onSessionError = null;
    _apiService.onSessionIdChanged = null;
    _queueService.onItemsDropped = null;
    _apiService.disableHeartbeat();
    unawaited(_locationService.dispose());
    super.dispose();
  }
}

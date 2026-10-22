import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../connector/meshcore_protocol.dart';
import '../helpers/atak_channel_helper.dart';
import '../models/app_settings.dart';
import '../models/notification_pref.dart';
import '../models/wardriving.dart';
import '../storage/prefs_manager.dart';
import '../utils/app_logger.dart';

class AppSettingsService extends ChangeNotifier {
  static const String _settingsKey = 'app_settings';
  static const Duration telemetryRemoteLoginWindow = Duration(days: 30);

  AppSettings _settings = AppSettings();
  Future<void> _writeChain = Future.value();

  AppSettings get settings => _settings;

  /// A repeater may be polled only after a recent successful admin login.
  /// Future timestamps are rejected so clock changes cannot make a node
  /// eligible indefinitely.
  bool hasRecentRepeaterLogin(String publicKeyHex, {DateTime? now}) {
    final millis = _settings.repeaterLastSuccessfulLoginMillis[publicKeyHex];
    if (millis == null) return false;

    final reference = now ?? DateTime.now();
    final loginAt = DateTime.fromMillisecondsSinceEpoch(
      millis,
      isUtc: true,
    ).toLocal();
    return !loginAt.isAfter(reference) &&
        !loginAt.isBefore(reference.subtract(telemetryRemoteLoginWindow));
  }

  String batteryChemistryForDevice(String deviceId) {
    final stored = _settings.batteryChemistryByDeviceId[deviceId];
    if (stored == 'liion') return 'nmc';
    return stored ?? 'nmc';
  }

  String batteryChemistryForRepeater(String repeaterPubKeyHex) {
    final stored = _settings.batteryChemistryByRepeaterId[repeaterPubKeyHex];
    if (stored == 'liion') return 'nmc';
    return stored ?? 'nmc';
  }

  int batteryCellCountForDevice(String deviceId) {
    return (_settings.batteryCellCountByDeviceId[deviceId] ?? 1).clamp(1, 4);
  }

  int batteryCellCountForRepeater(String repeaterPubKeyHex) {
    return (_settings.batteryCellCountByRepeaterId[repeaterPubKeyHex] ?? 1)
        .clamp(1, 4);
  }

  Future<void> loadSettings() async {
    final prefs = PrefsManager.instance;
    final jsonStr = prefs.getString(_settingsKey);

    if (jsonStr != null) {
      try {
        final json = jsonDecode(jsonStr) as Map<String, dynamic>;
        final loaded = AppSettings.fromJson(json);
        if (isStoredPublicAtakSelection(loaded.atakChannelName)) {
          _settings = _migrateAtakSettings(loaded);
          await prefs.setString(_settingsKey, jsonEncode(_settings.toJson()));
        } else {
          _settings = loaded;
        }
        notifyListeners();
      } catch (e) {
        // If parsing fails, use defaults
        _settings = AppSettings();
      }
    }
  }

  Future<void> updateSettings(AppSettings newSettings) async {
    _settings = newSettings;
    notifyListeners();

    final prefs = PrefsManager.instance;
    final jsonStr = jsonEncode(_settings.toJson());
    _writeChain = _writeChain
        .catchError((_) {})
        .then((_) => prefs.setString(_settingsKey, jsonStr));
    await _writeChain;
  }

  Future<void> setClearPathOnMaxRetry(bool value) async {
    await updateSettings(_settings.copyWith(clearPathOnMaxRetry: value));
  }

  Future<void> setMapShowRepeaters(bool value) async {
    await updateSettings(_settings.copyWith(mapShowRepeaters: value));
  }

  Future<void> setMapShowChatNodes(bool value) async {
    await updateSettings(_settings.copyWith(mapShowChatNodes: value));
  }

  Future<void> setMapShowOtherNodes(bool value) async {
    await updateSettings(_settings.copyWith(mapShowOtherNodes: value));
  }

  Future<void> setMapTimeFilterHours(double value) async {
    await updateSettings(_settings.copyWith(mapTimeFilterHours: value));
  }

  Future<void> setMapKeyPrefixEnabled(bool value) async {
    await updateSettings(_settings.copyWith(mapKeyPrefixEnabled: value));
  }

  Future<void> setMapKeyPrefix(String value) async {
    await updateSettings(_settings.copyWith(mapKeyPrefix: value));
  }

  Future<void> setMapShowMarkers(bool value) async {
    await updateSettings(_settings.copyWith(mapShowMarkers: value));
  }

  Future<void> setEnableMessageTracing(bool value) async {
    await updateSettings(_settings.copyWith(enableMessageTracing: value));
  }

  Future<void> setMapCacheBounds(Map<String, double>? value) async {
    await updateSettings(_settings.copyWith(mapCacheBounds: value));
  }

  Future<void> setMapCacheZoomRange(int minZoom, int maxZoom) async {
    final safeMin = minZoom <= maxZoom ? minZoom : maxZoom;
    final safeMax = minZoom <= maxZoom ? maxZoom : minZoom;
    await updateSettings(
      _settings.copyWith(mapCacheMinZoom: safeMin, mapCacheMaxZoom: safeMax),
    );
  }

  Future<void> setMapCacheWorldZoomRange(int minZoom, int maxZoom) async {
    final safeMin = minZoom <= maxZoom ? minZoom : maxZoom;
    final safeMax = minZoom <= maxZoom ? maxZoom : minZoom;
    await updateSettings(
      _settings.copyWith(
        mapCacheWorldMinZoom: safeMin,
        mapCacheWorldMaxZoom: safeMax,
      ),
    );
  }

  Future<void> setNotificationsEnabled(bool value) async {
    await updateSettings(_settings.copyWith(notificationsEnabled: value));
  }

  Future<void> setNotifyOnNewMessage(bool value) async {
    await updateSettings(_settings.copyWith(notifyOnNewMessage: value));
  }

  Future<void> setNotifyOnNewChannelMessage(bool value) async {
    await updateSettings(_settings.copyWith(notifyOnNewChannelMessage: value));
  }

  Future<void> setNotifyOnNewAdvert(bool value) async {
    await updateSettings(_settings.copyWith(notifyOnNewAdvert: value));
  }

  Future<void> setAutoRouteRotationEnabled(bool value) async {
    await updateSettings(_settings.copyWith(autoRouteRotationEnabled: value));
  }

  Future<void> setThemeMode(String value) async {
    await updateSettings(_settings.copyWith(themeMode: value));
  }

  Future<void> setLanguageOverride(String? value) async {
    await updateSettings(_settings.copyWith(languageOverride: value));
  }

  Future<void> setAppDebugLogEnabled(bool value) async {
    await updateSettings(_settings.copyWith(appDebugLogEnabled: value));
    // Update the global logger
    appLogger.setEnabled(value);
  }

  Future<void> setDebugLogPromptShown(bool value) async {
    await updateSettings(_settings.copyWith(debugLogPromptShown: value));
  }

  Future<void> setBatteryChemistryForDevice(
    String deviceId,
    String chemistry,
  ) async {
    final updated = Map<String, String>.from(
      _settings.batteryChemistryByDeviceId,
    );
    updated[deviceId] = chemistry;
    await updateSettings(
      _settings.copyWith(batteryChemistryByDeviceId: updated),
    );
  }

  Future<void> setBatteryChemistryForRepeater(
    String repeaterPubKeyHex,
    String chemistry,
  ) async {
    final updated = Map<String, String>.from(
      _settings.batteryChemistryByRepeaterId,
    );
    updated[repeaterPubKeyHex] = chemistry;
    await updateSettings(
      _settings.copyWith(batteryChemistryByRepeaterId: updated),
    );
  }

  Future<void> setBatteryCellCountForDevice(
    String deviceId,
    int cellCount,
  ) async {
    final updated = Map<String, int>.from(_settings.batteryCellCountByDeviceId);
    updated[deviceId] = cellCount.clamp(1, 4);
    await updateSettings(
      _settings.copyWith(batteryCellCountByDeviceId: updated),
    );
  }

  Future<void> setBatteryCellCountForRepeater(
    String repeaterPubKeyHex,
    int cellCount,
  ) async {
    final updated = Map<String, int>.from(
      _settings.batteryCellCountByRepeaterId,
    );
    updated[repeaterPubKeyHex] = cellCount.clamp(1, 4);
    await updateSettings(
      _settings.copyWith(batteryCellCountByRepeaterId: updated),
    );
  }

  Future<void> setUnitSystem(UnitSystem value) async {
    await updateSettings(_settings.copyWith(unitSystem: value));
  }

  Future<void> setNotificationDefaultLevel(NotificationLevel value) async {
    await updateSettings(_settings.copyWith(notificationDefaultLevel: value));
  }

  AppSettings _migrateAtakSettings(AppSettings settings) {
    if (!isStoredPublicAtakSelection(settings.atakChannelName)) {
      return settings;
    }
    return settings.copyWith(
      atakChannelIndex: null,
      atakChannelName: '',
      atakLocationBroadcastEnabled: false,
    );
  }

  Future<void> setAtakChannel({int? index, String name = ''}) async {
    await updateSettings(
      _settings.copyWith(atakChannelIndex: index, atakChannelName: name),
    );
  }

  Future<void> clearAtakChannel() async {
    await updateSettings(
      _settings.copyWith(atakChannelIndex: null, atakChannelName: ''),
    );
  }

  Future<void> setAtakLocationBroadcastEnabled(bool value) async {
    await updateSettings(
      _settings.copyWith(atakLocationBroadcastEnabled: value),
    );
  }

  Future<void> setAtakMovementDistanceMeters(double value) async {
    await updateSettings(_settings.copyWith(atakMovementDistanceMeters: value));
  }

  Future<void> setAtakMinSendIntervalSec(int value) async {
    await updateSettings(_settings.copyWith(atakMinSendIntervalSec: value));
  }

  Future<void> setAtakSyncNodeAdvertLocation(bool value) async {
    await updateSettings(_settings.copyWith(atakSyncNodeAdvertLocation: value));
  }

  Future<void> setTelemetryMonitorEnabled(bool value) async {
    await updateSettings(_settings.copyWith(telemetryMonitorEnabled: value));
  }

  Future<void> setTelemetryIntervalSec(int value) async {
    await updateSettings(
      _settings.copyWith(
        telemetryIntervalSec: clampTelemetryIntervalSec(value),
      ),
    );
  }

  Future<void> setTelemetryRemoteEnabled(bool value) async {
    await updateSettings(_settings.copyWith(telemetryRemoteEnabled: value));
  }

  Future<void> setTelemetryRemoteIntervalSec(int value) async {
    await updateSettings(
      _settings.copyWith(
        telemetryRemoteIntervalSec: clampTelemetryRemoteIntervalSec(value),
      ),
    );
  }

  /// Remote polling is opt-in per node, so this toggles one repeater's
  /// membership rather than replacing the whole list.
  Future<void> setTelemetryRemoteNode(String publicKeyHex, bool enabled) async {
    final keys = _settings.telemetryRemoteNodeKeys.toList();
    final present = keys.contains(publicKeyHex);
    if (enabled == present) return;
    if (enabled) {
      keys.add(publicKeyHex);
    } else {
      keys.remove(publicKeyHex);
    }
    await updateSettings(_settings.copyWith(telemetryRemoteNodeKeys: keys));
  }

  /// Records a confirmed repeater-admin login. This is deliberately separate
  /// from saved passwords: users who choose not to save a password still
  /// explicitly authenticated with the repeater.
  Future<void> recordSuccessfulRepeaterLogin(
    String publicKeyHex, {
    DateTime? at,
  }) async {
    final timestamps = Map<String, int>.from(
      _settings.repeaterLastSuccessfulLoginMillis,
    );
    timestamps[publicKeyHex] = (at ?? DateTime.now())
        .toUtc()
        .millisecondsSinceEpoch;
    await updateSettings(
      _settings.copyWith(repeaterLastSuccessfulLoginMillis: timestamps),
    );
  }

  Future<void> setTelemetryAlertsEnabled(bool value) async {
    await updateSettings(_settings.copyWith(telemetryAlertsEnabled: value));
  }

  Future<void> setTelemetryLowBatteryMillivolts(int value) async {
    await updateSettings(
      _settings.copyWith(telemetryLowBatteryMillivolts: value),
    );
  }

  Future<void> setTelemetryNoiseFloorAlertDbm(int value) async {
    await updateSettings(
      _settings.copyWith(telemetryNoiseFloorAlertDbm: value),
    );
  }

  Future<void> setWardrivingDisclosureAccepted(bool value) async {
    await updateSettings(
      _settings.copyWith(wardrivingDisclosureAccepted: value),
    );
  }

  Future<void> setWardrivingIntervalSec(int value) async {
    final clamped = value < kWardrivingMinIntervalSec
        ? kWardrivingMinIntervalSec
        : value;
    await updateSettings(_settings.copyWith(wardrivingIntervalSec: clamped));
  }

  Future<void> setWardrivingMinDistanceMeters(double value) async {
    await updateSettings(
      _settings.copyWith(
        wardrivingMinDistanceMeters: value < kWardrivingMinDistanceMeters
            ? kWardrivingMinDistanceMeters
            : value,
      ),
    );
  }

  Future<void> setWardrivingExternalAntenna(bool value) async {
    await updateSettings(_settings.copyWith(wardrivingExternalAntenna: value));
  }

  Future<void> setWardrivingCarpeaterPrefix(String value) async {
    await updateSettings(_settings.copyWith(wardrivingCarpeaterPrefix: value));
  }

  Future<void> setWardrivingDisableRssiFilter(bool value) async {
    await updateSettings(
      _settings.copyWith(wardrivingDisableRssiFilter: value),
    );
  }

  Future<void> setWardrivingIncludeContactKey(bool value) async {
    await updateSettings(
      _settings.copyWith(wardrivingIncludeContactKey: value),
    );
  }

  Future<void> setWardrivingDiscDropEnabled(bool value) async {
    await updateSettings(_settings.copyWith(wardrivingDiscDropEnabled: value));
  }

  Future<void> setWardrivingBroadcastCoordinates(bool value) async {
    await updateSettings(
      _settings.copyWith(wardrivingBroadcastCoordinates: value),
    );
  }

  Future<void> setWardrivingBackgroundEnabled(bool value) async {
    await updateSettings(
      _settings.copyWith(wardrivingBackgroundEnabled: value),
    );
  }

  Future<void> setWardrivingCoverageEnabled(bool value) async {
    await updateSettings(_settings.copyWith(wardrivingCoverageEnabled: value));
  }

  Future<void> setWardrivingCoverageGridSize(int value) async {
    await updateSettings(
      _settings.copyWith(wardrivingCoverageGridSize: value == 100 ? 100 : 300),
    );
  }

  Future<void> setWardrivingCoverageOpacity(double value) async {
    await updateSettings(
      _settings.copyWith(wardrivingCoverageOpacity: value.clamp(0.1, 1.0)),
    );
  }

  Future<void> setWardrivingTargetRepeaterId(String value) async {
    await updateSettings(
      _settings.copyWith(wardrivingTargetRepeaterId: value.trim()),
    );
  }

  Future<void> setWardrivingOfflineMode(bool value) async {
    await updateSettings(_settings.copyWith(wardrivingOfflineMode: value));
  }

  Future<void> setCompanionPathHashMode(int mode) async {
    if (!isValidPathHashMode(mode)) return;
    await updateSettings(_settings.copyWith(companionPathHashMode: mode));
  }

  Future<void> setMeshAnalyzerEnabled(bool value) async {
    await updateSettings(_settings.copyWith(meshAnalyzerEnabled: value));
  }

  Future<void> setLayoutMode(AppLayoutMode value) async {
    await updateSettings(_settings.copyWith(layoutMode: value));
  }

  Future<void> setChatFilter(String value) async {
    await updateSettings(_settings.copyWith(chatFilter: value));
  }

  Future<void> setChatSortMode(String value) async {
    await updateSettings(_settings.copyWith(chatSortMode: value));
  }

  Future<void> setNodeCategoryFilter(String value) async {
    await updateSettings(_settings.copyWith(nodeCategoryFilter: value));
  }

  Future<void> setRichLinkPreviewsEnabled(bool value) async {
    await updateSettings(_settings.copyWith(richLinkPreviewsEnabled: value));
  }

  Future<void> setExperimentalWeatherEnabled(bool value) async {
    await updateSettings(_settings.copyWith(experimentalWeatherEnabled: value));
  }

  Future<void> setExperimentalNodeBlockingEnabled(bool value) async {
    await updateSettings(
      _settings.copyWith(experimentalNodeBlockingEnabled: value),
    );
  }
}

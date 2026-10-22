import '../connector/meshcore_protocol.dart';
import 'map_offline_region.dart';
import 'notification_pref.dart';
import 'wardriving.dart';

enum UnitSystem { metric, imperial }

enum AppLayoutMode { auto, mobile, tablet }

extension AppLayoutModeValue on AppLayoutMode {
  String get value {
    switch (this) {
      case AppLayoutMode.mobile:
        return 'mobile';
      case AppLayoutMode.tablet:
        return 'tablet';
      case AppLayoutMode.auto:
        return 'auto';
    }
  }

  static AppLayoutMode fromValue(String? value) {
    switch (value) {
      case 'mobile':
        return AppLayoutMode.mobile;
      case 'tablet':
        return AppLayoutMode.tablet;
      default:
        return AppLayoutMode.auto;
    }
  }
}

extension UnitSystemValue on UnitSystem {
  String get value {
    switch (this) {
      case UnitSystem.imperial:
        return 'imperial';
      case UnitSystem.metric:
        return 'metric';
    }
  }
}

class AppSettings {
  static const Object _unset = Object();

  final bool clearPathOnMaxRetry;
  final bool mapShowRepeaters;
  final bool mapShowChatNodes;
  final bool mapShowOtherNodes;
  final double mapTimeFilterHours; // 0 = all time
  final bool mapKeyPrefixEnabled;
  final String mapKeyPrefix;
  final bool mapShowMarkers;
  final bool enableMessageTracing;
  final Map<String, double>? mapCacheBounds;
  final int mapCacheMinZoom;
  final int mapCacheMaxZoom;
  final int mapCacheWorldMinZoom;
  final int mapCacheWorldMaxZoom;
  final bool notificationsEnabled;
  final bool notifyOnNewMessage;
  final bool notifyOnNewChannelMessage;
  final bool notifyOnNewAdvert;
  final bool autoRouteRotationEnabled;
  final String themeMode;
  final String? languageOverride; // null = system default
  final bool appDebugLogEnabled;
  final bool debugLogPromptShown;
  final Map<String, String> batteryChemistryByDeviceId;
  final Map<String, String> batteryChemistryByRepeaterId;
  final Map<String, int> batteryCellCountByDeviceId;
  final Map<String, int> batteryCellCountByRepeaterId;
  final UnitSystem unitSystem;
  final int? atakChannelIndex;
  final String atakChannelName;
  final bool atakLocationBroadcastEnabled;
  final bool atakSyncNodeAdvertLocation;
  final double atakMovementDistanceMeters;
  final int atakMinSendIntervalSec;
  final bool telemetryMonitorEnabled;
  final int telemetryIntervalSec;
  final bool telemetryRemoteEnabled;
  final int telemetryRemoteIntervalSec;

  /// Repeater public keys the user opted into background polling, by hex key.
  final List<String> telemetryRemoteNodeKeys;

  /// Most recent successful repeater-admin login, as UTC milliseconds since
  /// the epoch, keyed by repeater public key hex.
  final Map<String, int> repeaterLastSuccessfulLoginMillis;
  final bool telemetryAlertsEnabled;
  final int telemetryLowBatteryMillivolts;
  final int telemetryNoiseFloorAlertDbm;
  final bool wardrivingDisclosureAccepted;
  final int wardrivingIntervalSec;
  final double wardrivingMinDistanceMeters;
  final bool wardrivingExternalAntenna;
  final String wardrivingCarpeaterPrefix;
  final bool wardrivingDisableRssiFilter;
  final bool wardrivingIncludeContactKey;
  final bool wardrivingDiscDropEnabled;
  final bool wardrivingBroadcastCoordinates;
  final bool wardrivingBackgroundEnabled;
  final bool wardrivingCoverageEnabled;
  final int wardrivingCoverageGridSize;
  final double wardrivingCoverageOpacity;
  final String wardrivingTargetRepeaterId;
  final bool wardrivingOfflineMode;
  final int companionPathHashMode;
  final bool meshAnalyzerEnabled;
  final AppLayoutMode layoutMode;
  final NotificationLevel notificationDefaultLevel;
  final String chatFilter;
  final String chatSortMode;
  final String nodeCategoryFilter;

  /// Enable local previews for HTTP(S) rich-message links.
  final bool richLinkPreviewsEnabled;

  final bool experimentalWeatherEnabled;
  final bool experimentalNodeBlockingEnabled;

  AppSettings({
    this.clearPathOnMaxRetry = false,
    this.mapShowRepeaters = true,
    this.mapShowChatNodes = true,
    this.mapShowOtherNodes = true,
    this.mapTimeFilterHours = 0, // Default to all time
    this.mapKeyPrefixEnabled = false,
    this.mapKeyPrefix = '',
    this.mapShowMarkers = true,
    this.enableMessageTracing = false,
    this.mapCacheBounds,
    this.mapCacheMinZoom = 10,
    this.mapCacheMaxZoom = 15,
    this.mapCacheWorldMinZoom = kMapWorldOverviewDefaultMinZoom,
    this.mapCacheWorldMaxZoom = kMapWorldOverviewDefaultMaxZoom,
    this.notificationsEnabled = true,
    this.notifyOnNewMessage = true,
    this.notifyOnNewChannelMessage = true,
    this.notifyOnNewAdvert = true,
    this.autoRouteRotationEnabled = false,
    this.themeMode = 'system',
    this.languageOverride,
    this.appDebugLogEnabled = false,
    this.debugLogPromptShown = false,
    Map<String, String>? batteryChemistryByDeviceId,
    Map<String, String>? batteryChemistryByRepeaterId,
    Map<String, int>? batteryCellCountByDeviceId,
    Map<String, int>? batteryCellCountByRepeaterId,
    this.unitSystem = UnitSystem.metric,
    this.atakChannelIndex,
    this.atakChannelName = '',
    this.atakLocationBroadcastEnabled = false,
    this.atakSyncNodeAdvertLocation = false,
    this.atakMovementDistanceMeters = 50,
    this.atakMinSendIntervalSec = 60,
    this.telemetryMonitorEnabled = false,
    this.telemetryIntervalSec = kTelemetryDefaultIntervalSec,
    this.telemetryRemoteEnabled = false,
    this.telemetryRemoteIntervalSec = kTelemetryRemoteDefaultIntervalSec,
    this.telemetryRemoteNodeKeys = const [],
    this.repeaterLastSuccessfulLoginMillis = const {},
    this.telemetryAlertsEnabled = true,
    this.telemetryLowBatteryMillivolts = kTelemetryDefaultLowBatteryMv,
    this.telemetryNoiseFloorAlertDbm = kTelemetryDefaultNoiseFloorDbm,
    this.wardrivingDisclosureAccepted = false,
    this.wardrivingIntervalSec = kWardrivingMinIntervalSec,
    this.wardrivingMinDistanceMeters = 50,
    this.wardrivingExternalAntenna = false,
    this.wardrivingCarpeaterPrefix = '',
    this.wardrivingDisableRssiFilter = false,
    this.wardrivingIncludeContactKey = false,
    this.wardrivingDiscDropEnabled = false,
    this.wardrivingBroadcastCoordinates = false,
    this.wardrivingBackgroundEnabled = false,
    this.wardrivingCoverageEnabled = true,
    this.wardrivingCoverageGridSize = 300,
    this.wardrivingCoverageOpacity = 0.45,
    this.wardrivingTargetRepeaterId = '',
    this.wardrivingOfflineMode = false,
    this.companionPathHashMode = defaultPathHashMode,
    this.meshAnalyzerEnabled = false,
    this.layoutMode = AppLayoutMode.auto,
    this.notificationDefaultLevel = NotificationLevel.all,
    this.chatFilter = 'all',
    this.chatSortMode = 'recent',
    this.nodeCategoryFilter = 'contacts',
    this.richLinkPreviewsEnabled = true,
    this.experimentalWeatherEnabled = false,
    this.experimentalNodeBlockingEnabled = false,
  }) : batteryChemistryByDeviceId = batteryChemistryByDeviceId ?? {},
       batteryChemistryByRepeaterId = batteryChemistryByRepeaterId ?? {},
       batteryCellCountByDeviceId = batteryCellCountByDeviceId ?? {},
       batteryCellCountByRepeaterId = batteryCellCountByRepeaterId ?? {};

  Map<String, dynamic> toJson() {
    return {
      'clear_path_on_max_retry': clearPathOnMaxRetry,
      'map_show_repeaters': mapShowRepeaters,
      'map_show_chat_nodes': mapShowChatNodes,
      'map_show_other_nodes': mapShowOtherNodes,
      'map_time_filter_hours': mapTimeFilterHours,
      'map_key_prefix_enabled': mapKeyPrefixEnabled,
      'map_key_prefix': mapKeyPrefix,
      'map_show_markers': mapShowMarkers,
      'enable_message_tracing': enableMessageTracing,
      'map_cache_bounds': mapCacheBounds,
      'map_cache_min_zoom': mapCacheMinZoom,
      'map_cache_max_zoom': mapCacheMaxZoom,
      'map_cache_world_min_zoom': mapCacheWorldMinZoom,
      'map_cache_world_max_zoom': mapCacheWorldMaxZoom,
      'notifications_enabled': notificationsEnabled,
      'notify_on_new_message': notifyOnNewMessage,
      'notify_on_new_channel_message': notifyOnNewChannelMessage,
      'notify_on_new_advert': notifyOnNewAdvert,
      'auto_route_rotation_enabled': autoRouteRotationEnabled,
      'theme_mode': themeMode,
      'language_override': languageOverride,
      'app_debug_log_enabled': appDebugLogEnabled,
      'debug_log_prompt_shown': debugLogPromptShown,
      'battery_chemistry_by_device_id': batteryChemistryByDeviceId,
      'battery_chemistry_by_repeater_id': batteryChemistryByRepeaterId,
      'battery_cell_count_by_device_id': batteryCellCountByDeviceId,
      'battery_cell_count_by_repeater_id': batteryCellCountByRepeaterId,
      'unit_system': unitSystem.value,
      'atak_channel_index': atakChannelIndex,
      'atak_channel_name': atakChannelName,
      'atak_location_broadcast_enabled': atakLocationBroadcastEnabled,
      'atak_sync_node_advert_location': atakSyncNodeAdvertLocation,
      'atak_movement_distance_meters': atakMovementDistanceMeters,
      'atak_min_send_interval_sec': atakMinSendIntervalSec,
      'telemetry_monitor_enabled': telemetryMonitorEnabled,
      'telemetry_interval_sec': telemetryIntervalSec,
      'telemetry_remote_enabled': telemetryRemoteEnabled,
      'telemetry_remote_interval_sec': telemetryRemoteIntervalSec,
      'telemetry_remote_node_keys': telemetryRemoteNodeKeys,
      'repeater_last_successful_login_millis':
          repeaterLastSuccessfulLoginMillis,
      'telemetry_alerts_enabled': telemetryAlertsEnabled,
      'telemetry_low_battery_mv': telemetryLowBatteryMillivolts,
      'telemetry_noise_floor_dbm': telemetryNoiseFloorAlertDbm,
      'wardriving_disclosure_accepted': wardrivingDisclosureAccepted,
      'wardriving_interval_sec': wardrivingIntervalSec,
      'wardriving_min_distance_meters': wardrivingMinDistanceMeters,
      'wardriving_external_antenna': wardrivingExternalAntenna,
      'wardriving_carpeater_prefix': wardrivingCarpeaterPrefix,
      'wardriving_disable_rssi_filter': wardrivingDisableRssiFilter,
      'wardriving_include_contact_key': wardrivingIncludeContactKey,
      'wardriving_disc_drop_enabled': wardrivingDiscDropEnabled,
      'wardriving_broadcast_coordinates': wardrivingBroadcastCoordinates,
      'wardriving_background_enabled': wardrivingBackgroundEnabled,
      'wardriving_coverage_enabled': wardrivingCoverageEnabled,
      'wardriving_coverage_grid_size': wardrivingCoverageGridSize,
      'wardriving_coverage_opacity': wardrivingCoverageOpacity,
      'wardriving_target_repeater_id': wardrivingTargetRepeaterId,
      'wardriving_offline_mode': wardrivingOfflineMode,
      'companion_path_hash_mode': companionPathHashMode,
      'mesh_analyzer_enabled': meshAnalyzerEnabled,
      'layout_mode': layoutMode.value,
      'notification_default_level': notificationDefaultLevel.value,
      'chat_filter': chatFilter,
      'chat_sort_mode': chatSortMode,
      'node_category_filter': nodeCategoryFilter,
      'rich_link_previews_enabled': richLinkPreviewsEnabled,
      'experimental_weather_enabled': experimentalWeatherEnabled,
      'experimental_node_blocking_enabled': experimentalNodeBlockingEnabled,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    bool readBool(String key, bool fallback) =>
        json[key] is bool ? json[key] as bool : fallback;
    int readInt(String key, int fallback) =>
        json[key] is num ? (json[key] as num).toInt() : fallback;
    int? readNullableInt(String key) =>
        json[key] is num ? (json[key] as num).toInt() : null;
    double readDouble(String key, double fallback) =>
        json[key] is num ? (json[key] as num).toDouble() : fallback;
    String readString(String key, String fallback) =>
        json[key] is String ? json[key] as String : fallback;
    String? readNullableString(String key) =>
        json[key] is String ? json[key] as String : null;
    Map<String, String> readStringMap(String key) {
      final value = json[key];
      if (value is! Map) return {};
      return value.map(
        (mapKey, mapValue) => MapEntry(mapKey.toString(), mapValue.toString()),
      );
    }

    Map<String, int> readIntMap(String key) {
      final value = json[key];
      if (value is! Map) return {};
      return value.map(
        (mapKey, mapValue) =>
            MapEntry(mapKey.toString(), mapValue is num ? mapValue.toInt() : 1),
      );
    }

    Map<String, double>? readBounds() {
      final value = json['map_cache_bounds'];
      if (value is! Map) return null;
      final result = <String, double>{};
      for (final entry in value.entries) {
        if (entry.value is num) {
          result[entry.key.toString()] = (entry.value as num).toDouble();
        }
      }
      return result.isEmpty ? null : result;
    }

    UnitSystem parseUnitSystem(dynamic value) {
      if (value is String && value.toLowerCase() == 'imperial') {
        return UnitSystem.imperial;
      }
      return UnitSystem.metric;
    }

    return AppSettings(
      clearPathOnMaxRetry: readBool('clear_path_on_max_retry', false),
      mapShowRepeaters: readBool('map_show_repeaters', true),
      mapShowChatNodes: readBool('map_show_chat_nodes', true),
      mapShowOtherNodes: readBool('map_show_other_nodes', true),
      mapTimeFilterHours: readDouble('map_time_filter_hours', 0),
      mapKeyPrefixEnabled: readBool('map_key_prefix_enabled', false),
      mapKeyPrefix: readString('map_key_prefix', ''),
      mapShowMarkers: readBool('map_show_markers', true),
      enableMessageTracing: readBool('enable_message_tracing', false),
      mapCacheBounds: readBounds(),
      mapCacheMinZoom: readInt('map_cache_min_zoom', 10),
      mapCacheMaxZoom: readInt('map_cache_max_zoom', 15),
      mapCacheWorldMinZoom: readInt(
        'map_cache_world_min_zoom',
        kMapWorldOverviewDefaultMinZoom,
      ),
      mapCacheWorldMaxZoom: readInt(
        'map_cache_world_max_zoom',
        kMapWorldOverviewDefaultMaxZoom,
      ),
      notificationsEnabled: readBool('notifications_enabled', true),
      notifyOnNewMessage: readBool('notify_on_new_message', true),
      notifyOnNewChannelMessage: readBool(
        'notify_on_new_channel_message',
        true,
      ),
      notifyOnNewAdvert: readBool('notify_on_new_advert', true),
      autoRouteRotationEnabled: readBool('auto_route_rotation_enabled', false),
      themeMode: readString('theme_mode', 'system'),
      languageOverride: readNullableString('language_override'),
      appDebugLogEnabled: readBool('app_debug_log_enabled', false),
      debugLogPromptShown: readBool('debug_log_prompt_shown', false),
      batteryChemistryByDeviceId: readStringMap(
        'battery_chemistry_by_device_id',
      ),
      batteryChemistryByRepeaterId: readStringMap(
        'battery_chemistry_by_repeater_id',
      ),
      batteryCellCountByDeviceId: readIntMap('battery_cell_count_by_device_id'),
      batteryCellCountByRepeaterId: readIntMap(
        'battery_cell_count_by_repeater_id',
      ),
      unitSystem: parseUnitSystem(json['unit_system']),
      atakChannelIndex: readNullableInt('atak_channel_index'),
      atakChannelName: readString('atak_channel_name', ''),
      atakLocationBroadcastEnabled: readBool(
        'atak_location_broadcast_enabled',
        false,
      ),
      atakSyncNodeAdvertLocation: readBool(
        'atak_sync_node_advert_location',
        false,
      ),
      atakMovementDistanceMeters: readDouble(
        'atak_movement_distance_meters',
        50,
      ),
      atakMinSendIntervalSec: readInt('atak_min_send_interval_sec', 60),
      telemetryMonitorEnabled: readBool('telemetry_monitor_enabled', false),
      telemetryIntervalSec: clampTelemetryIntervalSec(
        readNullableInt('telemetry_interval_sec'),
      ),
      telemetryRemoteEnabled: readBool('telemetry_remote_enabled', false),
      telemetryRemoteIntervalSec: clampTelemetryRemoteIntervalSec(
        readNullableInt('telemetry_remote_interval_sec'),
      ),
      telemetryRemoteNodeKeys:
          (json['telemetry_remote_node_keys'] as List?)
              ?.whereType<String>()
              .toList() ??
          const [],
      repeaterLastSuccessfulLoginMillis: readIntMap(
        'repeater_last_successful_login_millis',
      ),
      telemetryAlertsEnabled: readBool('telemetry_alerts_enabled', true),
      telemetryLowBatteryMillivolts:
          readNullableInt('telemetry_low_battery_mv') ??
          kTelemetryDefaultLowBatteryMv,
      telemetryNoiseFloorAlertDbm:
          readNullableInt('telemetry_noise_floor_dbm') ??
          kTelemetryDefaultNoiseFloorDbm,
      wardrivingDisclosureAccepted: readBool(
        'wardriving_disclosure_accepted',
        false,
      ),
      wardrivingIntervalSec: _clampWardrivingIntervalSec(
        readNullableInt('wardriving_interval_sec'),
      ),
      wardrivingMinDistanceMeters: _clampWardrivingDistanceMeters(
        json['wardriving_min_distance_meters'] is num
            ? (json['wardriving_min_distance_meters'] as num).toDouble()
            : null,
      ),
      wardrivingExternalAntenna: readBool('wardriving_external_antenna', false),
      wardrivingCarpeaterPrefix: readString('wardriving_carpeater_prefix', ''),
      wardrivingDisableRssiFilter: readBool(
        'wardriving_disable_rssi_filter',
        false,
      ),
      wardrivingIncludeContactKey: readBool(
        'wardriving_include_contact_key',
        false,
      ),
      wardrivingDiscDropEnabled: readBool(
        'wardriving_disc_drop_enabled',
        false,
      ),
      wardrivingBroadcastCoordinates: readBool(
        'wardriving_broadcast_coordinates',
        false,
      ),
      wardrivingBackgroundEnabled: readBool(
        'wardriving_background_enabled',
        false,
      ),
      wardrivingCoverageEnabled: readBool('wardriving_coverage_enabled', true),
      wardrivingCoverageGridSize: json['wardriving_coverage_grid_size'] == 100
          ? 100
          : 300,
      wardrivingCoverageOpacity: readDouble(
        'wardriving_coverage_opacity',
        0.45,
      ).clamp(0.1, 1.0),
      wardrivingTargetRepeaterId: readString(
        'wardriving_target_repeater_id',
        '',
      ),
      wardrivingOfflineMode: readBool('wardriving_offline_mode', false),
      companionPathHashMode: readInt(
        'companion_path_hash_mode',
        defaultPathHashMode,
      ),
      meshAnalyzerEnabled: readBool('mesh_analyzer_enabled', false),
      layoutMode: AppLayoutModeValue.fromValue(
        readNullableString('layout_mode'),
      ),
      notificationDefaultLevel: NotificationLevelValue.fromValue(
        readNullableInt('notification_default_level'),
      ),
      chatFilter: readString('chat_filter', 'all'),
      chatSortMode: readString('chat_sort_mode', 'recent'),
      nodeCategoryFilter: readString('node_category_filter', 'contacts'),
      richLinkPreviewsEnabled: readBool('rich_link_previews_enabled', true),
      experimentalWeatherEnabled:
          json['experimental_weather_enabled'] as bool? ?? false,
      experimentalNodeBlockingEnabled: readBool(
        'experimental_node_blocking_enabled',
        false,
      ),
    );
  }

  AppSettings copyWith({
    bool? clearPathOnMaxRetry,
    bool? mapShowRepeaters,
    bool? mapShowChatNodes,
    bool? mapShowOtherNodes,
    double? mapTimeFilterHours,
    bool? mapKeyPrefixEnabled,
    String? mapKeyPrefix,
    bool? mapShowMarkers,
    bool? enableMessageTracing,
    Object? mapCacheBounds = _unset,
    int? mapCacheMinZoom,
    int? mapCacheMaxZoom,
    int? mapCacheWorldMinZoom,
    int? mapCacheWorldMaxZoom,
    bool? notificationsEnabled,
    bool? notifyOnNewMessage,
    bool? notifyOnNewChannelMessage,
    bool? notifyOnNewAdvert,
    bool? autoRouteRotationEnabled,
    String? themeMode,
    Object? languageOverride = _unset,
    bool? appDebugLogEnabled,
    bool? debugLogPromptShown,
    Map<String, String>? batteryChemistryByDeviceId,
    Map<String, String>? batteryChemistryByRepeaterId,
    Map<String, int>? batteryCellCountByDeviceId,
    Map<String, int>? batteryCellCountByRepeaterId,
    UnitSystem? unitSystem,
    Object? atakChannelIndex = _unset,
    String? atakChannelName,
    bool? atakLocationBroadcastEnabled,
    bool? atakSyncNodeAdvertLocation,
    double? atakMovementDistanceMeters,
    int? atakMinSendIntervalSec,
    bool? telemetryMonitorEnabled,
    int? telemetryIntervalSec,
    bool? telemetryRemoteEnabled,
    int? telemetryRemoteIntervalSec,
    List<String>? telemetryRemoteNodeKeys,
    Map<String, int>? repeaterLastSuccessfulLoginMillis,
    bool? telemetryAlertsEnabled,
    int? telemetryLowBatteryMillivolts,
    int? telemetryNoiseFloorAlertDbm,
    bool? wardrivingDisclosureAccepted,
    int? wardrivingIntervalSec,
    double? wardrivingMinDistanceMeters,
    bool? wardrivingExternalAntenna,
    String? wardrivingCarpeaterPrefix,
    bool? wardrivingDisableRssiFilter,
    bool? wardrivingIncludeContactKey,
    bool? wardrivingDiscDropEnabled,
    bool? wardrivingBroadcastCoordinates,
    bool? wardrivingBackgroundEnabled,
    bool? wardrivingCoverageEnabled,
    int? wardrivingCoverageGridSize,
    double? wardrivingCoverageOpacity,
    String? wardrivingTargetRepeaterId,
    bool? wardrivingOfflineMode,
    int? companionPathHashMode,
    bool? meshAnalyzerEnabled,
    AppLayoutMode? layoutMode,
    NotificationLevel? notificationDefaultLevel,
    String? chatFilter,
    String? chatSortMode,
    String? nodeCategoryFilter,
    bool? richLinkPreviewsEnabled,
    bool? experimentalWeatherEnabled,
    bool? experimentalNodeBlockingEnabled,
  }) {
    return AppSettings(
      clearPathOnMaxRetry: clearPathOnMaxRetry ?? this.clearPathOnMaxRetry,
      mapShowRepeaters: mapShowRepeaters ?? this.mapShowRepeaters,
      mapShowChatNodes: mapShowChatNodes ?? this.mapShowChatNodes,
      mapShowOtherNodes: mapShowOtherNodes ?? this.mapShowOtherNodes,
      mapTimeFilterHours: mapTimeFilterHours ?? this.mapTimeFilterHours,
      mapKeyPrefixEnabled: mapKeyPrefixEnabled ?? this.mapKeyPrefixEnabled,
      mapKeyPrefix: mapKeyPrefix ?? this.mapKeyPrefix,
      mapShowMarkers: mapShowMarkers ?? this.mapShowMarkers,
      enableMessageTracing: enableMessageTracing ?? this.enableMessageTracing,
      mapCacheBounds: mapCacheBounds == _unset
          ? this.mapCacheBounds
          : mapCacheBounds as Map<String, double>?,
      mapCacheMinZoom: mapCacheMinZoom ?? this.mapCacheMinZoom,
      mapCacheMaxZoom: mapCacheMaxZoom ?? this.mapCacheMaxZoom,
      mapCacheWorldMinZoom: mapCacheWorldMinZoom ?? this.mapCacheWorldMinZoom,
      mapCacheWorldMaxZoom: mapCacheWorldMaxZoom ?? this.mapCacheWorldMaxZoom,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notifyOnNewMessage: notifyOnNewMessage ?? this.notifyOnNewMessage,
      notifyOnNewChannelMessage:
          notifyOnNewChannelMessage ?? this.notifyOnNewChannelMessage,
      notifyOnNewAdvert: notifyOnNewAdvert ?? this.notifyOnNewAdvert,
      autoRouteRotationEnabled:
          autoRouteRotationEnabled ?? this.autoRouteRotationEnabled,
      themeMode: themeMode ?? this.themeMode,
      languageOverride: languageOverride == _unset
          ? this.languageOverride
          : languageOverride as String?,
      appDebugLogEnabled: appDebugLogEnabled ?? this.appDebugLogEnabled,
      debugLogPromptShown: debugLogPromptShown ?? this.debugLogPromptShown,
      batteryChemistryByDeviceId:
          batteryChemistryByDeviceId ?? this.batteryChemistryByDeviceId,
      batteryChemistryByRepeaterId:
          batteryChemistryByRepeaterId ?? this.batteryChemistryByRepeaterId,
      batteryCellCountByDeviceId:
          batteryCellCountByDeviceId ?? this.batteryCellCountByDeviceId,
      batteryCellCountByRepeaterId:
          batteryCellCountByRepeaterId ?? this.batteryCellCountByRepeaterId,
      unitSystem: unitSystem ?? this.unitSystem,
      atakChannelIndex: atakChannelIndex == _unset
          ? this.atakChannelIndex
          : atakChannelIndex as int?,
      atakChannelName: atakChannelName ?? this.atakChannelName,
      atakLocationBroadcastEnabled:
          atakLocationBroadcastEnabled ?? this.atakLocationBroadcastEnabled,
      atakSyncNodeAdvertLocation:
          atakSyncNodeAdvertLocation ?? this.atakSyncNodeAdvertLocation,
      atakMovementDistanceMeters:
          atakMovementDistanceMeters ?? this.atakMovementDistanceMeters,
      atakMinSendIntervalSec:
          atakMinSendIntervalSec ?? this.atakMinSendIntervalSec,
      telemetryMonitorEnabled:
          telemetryMonitorEnabled ?? this.telemetryMonitorEnabled,
      telemetryIntervalSec: telemetryIntervalSec ?? this.telemetryIntervalSec,
      telemetryRemoteEnabled:
          telemetryRemoteEnabled ?? this.telemetryRemoteEnabled,
      telemetryRemoteIntervalSec:
          telemetryRemoteIntervalSec ?? this.telemetryRemoteIntervalSec,
      telemetryRemoteNodeKeys:
          telemetryRemoteNodeKeys ?? this.telemetryRemoteNodeKeys,
      repeaterLastSuccessfulLoginMillis:
          repeaterLastSuccessfulLoginMillis ??
          this.repeaterLastSuccessfulLoginMillis,
      telemetryAlertsEnabled:
          telemetryAlertsEnabled ?? this.telemetryAlertsEnabled,
      telemetryLowBatteryMillivolts:
          telemetryLowBatteryMillivolts ?? this.telemetryLowBatteryMillivolts,
      telemetryNoiseFloorAlertDbm:
          telemetryNoiseFloorAlertDbm ?? this.telemetryNoiseFloorAlertDbm,
      wardrivingDisclosureAccepted:
          wardrivingDisclosureAccepted ?? this.wardrivingDisclosureAccepted,
      wardrivingIntervalSec:
          wardrivingIntervalSec ?? this.wardrivingIntervalSec,
      wardrivingMinDistanceMeters:
          wardrivingMinDistanceMeters ?? this.wardrivingMinDistanceMeters,
      wardrivingExternalAntenna:
          wardrivingExternalAntenna ?? this.wardrivingExternalAntenna,
      wardrivingCarpeaterPrefix:
          wardrivingCarpeaterPrefix ?? this.wardrivingCarpeaterPrefix,
      wardrivingDisableRssiFilter:
          wardrivingDisableRssiFilter ?? this.wardrivingDisableRssiFilter,
      wardrivingIncludeContactKey:
          wardrivingIncludeContactKey ?? this.wardrivingIncludeContactKey,
      wardrivingDiscDropEnabled:
          wardrivingDiscDropEnabled ?? this.wardrivingDiscDropEnabled,
      wardrivingBroadcastCoordinates:
          wardrivingBroadcastCoordinates ?? this.wardrivingBroadcastCoordinates,
      wardrivingBackgroundEnabled:
          wardrivingBackgroundEnabled ?? this.wardrivingBackgroundEnabled,
      wardrivingCoverageEnabled:
          wardrivingCoverageEnabled ?? this.wardrivingCoverageEnabled,
      wardrivingCoverageGridSize:
          wardrivingCoverageGridSize ?? this.wardrivingCoverageGridSize,
      wardrivingCoverageOpacity:
          wardrivingCoverageOpacity ?? this.wardrivingCoverageOpacity,
      wardrivingTargetRepeaterId:
          wardrivingTargetRepeaterId ?? this.wardrivingTargetRepeaterId,
      wardrivingOfflineMode:
          wardrivingOfflineMode ?? this.wardrivingOfflineMode,
      companionPathHashMode:
          companionPathHashMode ?? this.companionPathHashMode,
      meshAnalyzerEnabled: meshAnalyzerEnabled ?? this.meshAnalyzerEnabled,
      layoutMode: layoutMode ?? this.layoutMode,
      notificationDefaultLevel:
          notificationDefaultLevel ?? this.notificationDefaultLevel,
      chatFilter: chatFilter ?? this.chatFilter,
      chatSortMode: chatSortMode ?? this.chatSortMode,
      nodeCategoryFilter: nodeCategoryFilter ?? this.nodeCategoryFilter,
      richLinkPreviewsEnabled:
          richLinkPreviewsEnabled ?? this.richLinkPreviewsEnabled,
      experimentalWeatherEnabled:
          experimentalWeatherEnabled ?? this.experimentalWeatherEnabled,
      experimentalNodeBlockingEnabled:
          experimentalNodeBlockingEnabled ??
          this.experimentalNodeBlockingEnabled,
    );
  }
}

int _clampWardrivingIntervalSec(int? value) {
  final resolved = value ?? kWardrivingMinIntervalSec;
  return resolved < kWardrivingMinIntervalSec
      ? kWardrivingMinIntervalSec
      : resolved;
}

double _clampWardrivingDistanceMeters(double? value) {
  final resolved = value ?? 50;
  return resolved < kWardrivingMinDistanceMeters
      ? kWardrivingMinDistanceMeters
      : resolved;
}

/// Local telemetry sampling runs over an already-open companion link, so the
/// floor here only guards against pointless churn — not airtime.
const int kTelemetryMinIntervalSec = 15;
const int kTelemetryDefaultIntervalSec = 60;

/// Remote polling costs LoRa airtime on every request *and* reply. Keep the
/// choices deliberately sparse so a user can select a useful monitoring
/// cadence without accidentally creating a high-airtime background job.
const List<int> kTelemetryRemoteIntervalOptionsSec = <int>[
  3 * 60 * 60,
  24 * 60 * 60,
  48 * 60 * 60,
];
const int kTelemetryRemoteDefaultIntervalSec = 3 * 60 * 60;

const int kTelemetryDefaultLowBatteryMv = 3400;
const int kTelemetryDefaultNoiseFloorDbm = -90;

int clampTelemetryIntervalSec(int? value) {
  final resolved = value ?? kTelemetryDefaultIntervalSec;
  return resolved < kTelemetryMinIntervalSec
      ? kTelemetryMinIntervalSec
      : resolved;
}

int clampTelemetryRemoteIntervalSec(int? value) {
  final resolved = value ?? kTelemetryRemoteDefaultIntervalSec;
  return kTelemetryRemoteIntervalOptionsSec.contains(resolved)
      ? resolved
      : kTelemetryRemoteDefaultIntervalSec;
}

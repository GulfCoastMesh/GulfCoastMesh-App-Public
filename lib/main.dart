import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'l10n/app_localizations.dart';
import 'l10n/l10n.dart';
import 'package:provider/provider.dart';

import 'connector/meshcore_connector.dart';
import 'screens/splash_screen.dart';
import 'screens/scanner_screen.dart';
import 'services/storage_service.dart';
import 'services/message_retry_service.dart';
import 'services/path_history_service.dart';
import 'services/app_settings_service.dart';
import 'services/blocked_nodes_service.dart';
import 'services/notification_navigator.dart';
import 'services/notification_service.dart';
import 'services/frame_debug_log_service.dart';
import 'services/app_debug_log_service.dart';
import 'services/crash_log_service.dart';
import 'services/background_service.dart';
import 'services/car_messaging_service.dart';
import 'services/connection_profile_service.dart';
import 'services/telemetry_monitor_service.dart';
import 'services/map_tile_cache_service.dart';
import 'services/atak_location_broadcast_service.dart';
import 'services/meshmapper_api_service.dart';
import 'services/meshmapper_coverage_service.dart';
import 'services/meshmapper_queue_service.dart';
import 'services/wardriving_service.dart';
import 'services/mesh_analyzer_state.dart';
import 'services/weather_api_service.dart';
import 'storage/prefs_manager.dart';
import 'theme/app_theme.dart';
import 'utils/app_logger.dart';

/// Storefront screenshots may opt into a locale without changing user-facing
/// language preferences in normal builds.
const _captureLocale = String.fromEnvironment('CAPTURE_LOCALE');
const _captureTheme = String.fromEnvironment('CAPTURE_THEME');

/// Shared with [NotificationNavigator] so a tapped notification can open its
/// conversation regardless of what screen is on top.
final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Android 15 draws every targetSdk 35+ app edge-to-edge whether it opts in or
  // not, so opt in explicitly and handle insets ourselves rather than inheriting
  // whatever the platform decides. Harmless on older Android and on iOS.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  if (!kIsWeb) FlutterForegroundTask.initCommunicationPort();
  // Initialize SharedPreferences cache
  await PrefsManager.initialize();

  // Capture uncaught errors so a debug report filed after a crash actually
  // has something in it, even if app debug logging was never turned on.
  final crashLogService = CrashLogService();
  final previousOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    crashLogService.record(details.exception, details.stack);
    previousOnError?.call(details);
  };
  final previousPlatformOnError = PlatformDispatcher.instance.onError;
  PlatformDispatcher.instance.onError = (error, stack) {
    crashLogService.record(error, stack);
    // Returning true suppresses the engine's own printing of the error, so
    // reproduce it here — otherwise a real crash during testing would only
    // show up in the debug report, never in the console someone's watching.
    debugPrint('Uncaught error: $error\n$stack');
    return previousPlatformOnError?.call(error, stack) ?? true;
  };

  // Initialize services
  final storage = StorageService();
  final connector = MeshCoreConnector();
  final pathHistoryService = PathHistoryService(storage);
  final retryService = MessageRetryService();
  final appSettingsService = AppSettingsService();
  final blockedNodesService = BlockedNodesService();
  final frameDebugLogService = FrameDebugLogService();
  final appDebugLogService = AppDebugLogService();
  final backgroundService = BackgroundService();
  final mapTileCacheService = MapTileCacheService();

  // Load settings
  await appSettingsService.loadSettings();
  await blockedNodesService.load();

  // Initialize app logger
  appLogger.initialize(
    appDebugLogService,
    enabled: appSettingsService.settings.appDebugLogEnabled,
  );

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();
  final notificationNavigator = NotificationNavigator(
    navigatorKey: navigatorKey,
    connector: connector,
  );
  notificationService.onNotificationTapped = notificationNavigator.open;
  final launchPayload = await notificationService.getLaunchPayload();
  await backgroundService.initialize();
  _registerThirdPartyLicenses();

  // Wire up connector with services
  connector.initialize(
    retryService: retryService,
    pathHistoryService: pathHistoryService,
    appSettingsService: appSettingsService,
    frameDebugLogService: frameDebugLogService,
    appDebugLogService: appDebugLogService,
    backgroundService: backgroundService,
    blockedNodesService: blockedNodesService,
  );

  await connector.loadContactCache();
  await connector.loadChannelSettings();
  await connector.loadCachedChannels();

  // Load persisted channel messages
  await connector.loadAllChannelMessages();
  await connector.loadUnreadState();

  final atakBroadcastService = AtakLocationBroadcastService(
    connector: connector,
    settingsService: appSettingsService,
  );
  await atakBroadcastService.ensureStarted();

  final meshMapperApiService = MeshMapperApiService();
  final meshMapperCoverageService = MeshMapperCoverageService(
    api: meshMapperApiService,
  );
  final meshMapperQueueService = MeshMapperQueueService(
    apiService: meshMapperApiService,
  );
  final wardrivingService = WardrivingService(
    connector: connector,
    settingsService: appSettingsService,
    apiService: meshMapperApiService,
    queueService: meshMapperQueueService,
    backgroundService: backgroundService,
  );
  await wardrivingService.ensureStarted();

  final meshAnalyzerState = MeshAnalyzerState();
  final weatherApiService = WeatherApiService(connector);

  final connectionProfileService = ConnectionProfileService();
  await connectionProfileService.load();

  final telemetryMonitorService = TelemetryMonitorService(
    connector: connector,
    settingsService: appSettingsService,
  );
  await telemetryMonitorService.start();

  // Android Auto reads mesh messages aloud and sends dictated replies back
  // through this same connector. No-op off Android.
  CarMessagingService(connector: connector).start();

  runApp(
    MeshCoreApp(
      connector: connector,
      retryService: retryService,
      pathHistoryService: pathHistoryService,
      storage: storage,
      appSettingsService: appSettingsService,
      blockedNodesService: blockedNodesService,
      frameDebugLogService: frameDebugLogService,
      appDebugLogService: appDebugLogService,
      crashLogService: crashLogService,
      mapTileCacheService: mapTileCacheService,
      atakBroadcastService: atakBroadcastService,
      wardrivingService: wardrivingService,
      connectionProfileService: connectionProfileService,
      telemetryMonitorService: telemetryMonitorService,
      meshMapperCoverageService: meshMapperCoverageService,
      meshAnalyzerState: meshAnalyzerState,
      weatherApiService: weatherApiService,
    ),
  );

  if (launchPayload != null) {
    notificationNavigator.openOnceConnected(launchPayload);
  }
}

void _registerThirdPartyLicenses() {
  LicenseRegistry.addLicense(() async* {
    yield const LicenseEntryWithLineBreaks(
      <String>['Open-Meteo Elevation API Data'],
      '''
Data used by LOS elevation lookups is provided by Open-Meteo.

Open-Meteo terms and attribution:
https://open-meteo.com/en/terms

Elevation API:
https://open-meteo.com/en/docs/elevation-api

Attribution license reference:
Creative Commons Attribution 4.0 International (CC BY 4.0)
https://creativecommons.org/licenses/by/4.0/
''',
    );
  });
}

class MeshCoreApp extends StatelessWidget {
  final MeshCoreConnector connector;
  final MessageRetryService retryService;
  final PathHistoryService pathHistoryService;
  final StorageService storage;
  final AppSettingsService appSettingsService;
  final BlockedNodesService blockedNodesService;
  final FrameDebugLogService frameDebugLogService;
  final AppDebugLogService appDebugLogService;
  final CrashLogService crashLogService;
  final MapTileCacheService mapTileCacheService;
  final AtakLocationBroadcastService atakBroadcastService;
  final WardrivingService wardrivingService;
  final MeshMapperCoverageService meshMapperCoverageService;
  final MeshAnalyzerState meshAnalyzerState;
  final WeatherApiService weatherApiService;
  final ConnectionProfileService connectionProfileService;
  final TelemetryMonitorService telemetryMonitorService;

  const MeshCoreApp({
    super.key,
    required this.connector,
    required this.retryService,
    required this.pathHistoryService,
    required this.storage,
    required this.appSettingsService,
    required this.blockedNodesService,
    required this.frameDebugLogService,
    required this.appDebugLogService,
    required this.crashLogService,
    required this.mapTileCacheService,
    required this.atakBroadcastService,
    required this.wardrivingService,
    required this.meshMapperCoverageService,
    required this.meshAnalyzerState,
    required this.weatherApiService,
    required this.connectionProfileService,
    required this.telemetryMonitorService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: connector),
        ChangeNotifierProvider.value(value: retryService),
        ChangeNotifierProvider.value(value: pathHistoryService),
        ChangeNotifierProvider.value(value: appSettingsService),
        ChangeNotifierProvider.value(value: blockedNodesService),
        ChangeNotifierProvider.value(value: frameDebugLogService),
        ChangeNotifierProvider.value(value: appDebugLogService),
        ChangeNotifierProvider.value(value: crashLogService),
        Provider.value(value: storage),
        Provider.value(value: mapTileCacheService),
        ChangeNotifierProvider.value(value: atakBroadcastService),
        ChangeNotifierProvider.value(value: wardrivingService),
        ChangeNotifierProvider.value(value: meshMapperCoverageService),
        ChangeNotifierProvider.value(value: meshAnalyzerState),
        ChangeNotifierProvider.value(value: weatherApiService),
        ChangeNotifierProvider.value(value: connectionProfileService),
        ChangeNotifierProvider.value(value: telemetryMonitorService),
      ],
      child: Consumer<AppSettingsService>(
        builder: (context, settingsService, child) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            title: 'Gulf Coast Mesh App',
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            locale: _captureLocale.isEmpty
                ? _localeFromSetting(settingsService.settings.languageOverride)
                : Locale(_captureLocale),
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: _themeModeFromSetting(
              _captureTheme.isEmpty
                  ? settingsService.settings.themeMode
                  : _captureTheme,
            ),
            builder: (context, child) {
              // Update notification service with resolved locale
              final locale = Localizations.localeOf(context);
              NotificationService().setLocale(locale);
              final content = child ?? const SizedBox.shrink();
              // Screens without an AppBar get no overlay style of their own, so
              // set it here from the resolved theme. AppBar pushes its own
              // AnnotatedRegion further down the tree, which wins where present.
              return AnnotatedRegion<SystemUiOverlayStyle>(
                value: systemOverlayStyleFor(
                  Theme.of(context).colorScheme.brightness,
                ),
                child: Consumer<MeshCoreConnector>(
                  builder: (context, connector, _) {
                    if (!connector.isDemoMode) return content;
                    return Column(
                      children: [
                        const _DemoModeBanner(),
                        // The banner already consumed the status-bar inset, so
                        // strip it before the app's own Scaffolds/AppBars
                        // consume it a second time and leave a doubled gap.
                        Expanded(
                          child: MediaQuery.removePadding(
                            context: context,
                            removeTop: true,
                            child: content,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
            home: const SplashScreen(),
          );
        },
      ),
    );
  }

  ThemeMode _themeModeFromSetting(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Locale? _localeFromSetting(String? languageCode) {
    if (languageCode == null) return null;
    return Locale(languageCode);
  }
}

class _DemoModeBanner extends StatelessWidget {
  const _DemoModeBanner();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    return Material(
      color: colors.tertiaryContainer,
      child: SafeArea(
        bottom: false,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 42),
          child: Row(
            children: [
              const SizedBox(width: 12),
              Icon(Icons.science, size: 20, color: colors.onTertiaryContainer),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.demo_bannerLabel,
                  style: TextStyle(
                    color: colors.onTertiaryContainer,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => _confirmExit(context),
                icon: const Icon(Icons.exit_to_app, size: 18),
                label: Text(l10n.demo_exit),
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmExit(BuildContext context) async {
    final l10n = context.l10n;
    final exit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.demo_exitTitle),
        content: Text(l10n.demo_exitMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.demo_exitStay),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.demo_exit),
          ),
        ],
      ),
    );
    if (exit != true || !context.mounted) return;
    await context.read<MeshCoreConnector>().exitDemoMode();
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const ScannerScreen()),
      (_) => false,
    );
    final messenger = navigatorKey.currentContext == null
        ? null
        : ScaffoldMessenger.maybeOf(navigatorKey.currentContext!);
    messenger?.showSnackBar(SnackBar(content: Text(l10n.demo_ended)));
  }
}

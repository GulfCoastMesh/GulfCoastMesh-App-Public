@TestOn('browser')
library;

import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// Register the app's existing endorsed plugin; widget tests skip registration.
// ignore: depend_on_referenced_packages
import 'package:flutter_blue_plus_web/flutter_blue_plus_web.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:http/http.dart' as http;
import 'package:gulf_coast_mesh_app/main.dart' as app;
import 'package:gulf_coast_mesh_app/screens/app_settings_screen.dart';
import 'package:gulf_coast_mesh_app/screens/flasher_screen.dart';
import 'package:gulf_coast_mesh_app/screens/home_screen.dart';
import 'package:gulf_coast_mesh_app/screens/scanner_screen.dart';
import 'package:gulf_coast_mesh_app/screens/settings_screen.dart';
import 'package:gulf_coast_mesh_app/services/background_service.dart';
import 'package:gulf_coast_mesh_app/services/notification_service.dart';
import 'package:gulf_coast_mesh_app/storage/prefs_manager.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  FlutterBluePlusWeb.registerWith(webPluginRegistrar);
  test('native background and notification services safely skip web', () async {
    final background = BackgroundService();
    await background.initialize();
    background.keepAliveText = 'Test';
    expect(await background.start(), isTrue);
    await background.startWardriving();
    await background.updateWardrivingStatus(mode: 'test');
    await background.finishWardriving();
    await background.stop();
    final notifications = NotificationService();
    await notifications.initialize();
    expect(await notifications.getLaunchPayload(), isNull);
    expect(await notifications.requestPermissions(), isFalse);
  });

  testWidgets('browser startup reaches Scanner, demo mode and Settings', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'demo_history_cleanup_v1': true});
    PrefsManager.reset();
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('flutter.baseflow.com/geolocator'),
      (call) async => call.method == 'isLocationServiceEnabled' ? false : 0,
    );
    PackageInfo.setMockInitialValues(
      appName: 'MeshCore',
      packageName: 'meshcore.test',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
    await tester.binding.setSurfaceSize(const Size(1000, 900));
    final previousFlutterError = FlutterError.onError;
    final previousPlatformError = PlatformDispatcher.instance.onError;
    final appTimers = <Timer>[];
    app.MeshCoreApp? running;
    try {
      await tester.runAsync(() async {
        final response = await http.get(
          Uri.base.resolve('/assets/assets/fonts/Inter-Variable.ttf'),
        );
        expect(response.statusCode, 200);
        final font = FontLoader('Inter')
          ..addFont(Future.value(ByteData.sublistView(response.bodyBytes)));
        await font.load();
      });
      // main also owns process-lifetime services outside the widget tree,
      // including the upload queue. Tear down their timers with this test.
      await runZoned(
        app.main,
        zoneSpecification: ZoneSpecification(
          createPeriodicTimer: (self, parent, zone, period, callback) {
            final timer = parent.createPeriodicTimer(zone, period, callback);
            appTimers.add(timer);
            return timer;
          },
        ),
      );
      // Keep Flutter's test error reporting active after main installs its
      // production crash handlers.
      FlutterError.onError = (details) {
        debugPrintSynchronously(details.toString());
        previousFlutterError?.call(details);
      };
      PlatformDispatcher.instance.onError = previousPlatformError;
      expect(tester.takeException(), isNull);
      await tester.pump();
      running = tester.widget<app.MeshCoreApp>(find.byType(app.MeshCoreApp));
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(find.byType(ScannerScreen), findsOneWidget);
      expect(find.byIcon(Icons.usb), findsNothing);
      expect(find.byIcon(Icons.lan_outlined), findsNothing);

      await tester.tap(find.byIcon(Icons.science_outlined));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(FilledButton),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(running.connector.isDemoMode, isTrue);
      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);
      final flasherTile = find.widgetWithText(
        ListTile,
        'Flash Device Firmware',
      );
      await tester.scrollUntilVisible(flasherTile, 300);
      await tester.pumpAndSettle();
      await tester.tap(flasherTile);
      await tester.pumpAndSettle();
      expect(find.byType(FlasherScreen), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();

      final appSettingsTile = find.widgetWithText(ListTile, 'App Settings');
      await tester.scrollUntilVisible(appSettingsTile, -500);
      await tester.pumpAndSettle();
      await tester.tap(appSettingsTile);
      await tester.pumpAndSettle();
      expect(find.byType(AppSettingsScreen), findsOneWidget);
      final offlineToggle = find.widgetWithText(
        SwitchListTile,
        'Offline-session mode',
      );
      await tester.scrollUntilVisible(offlineToggle, 500);
      await tester.pumpAndSettle();
      expect(tester.widget<SwitchListTile>(offlineToggle).onChanged, isNotNull);
      await tester.tap(offlineToggle);
      await tester.pumpAndSettle();
      expect(running.appSettingsService.settings.wardrivingOfflineMode, isTrue);
      expect(running.wardrivingService.isOfflineMode, isTrue);
      expect(tester.takeException(), isNull);
      expect(running.crashLogService.entries, isEmpty);
    } catch (error, stack) {
      debugPrintSynchronously('Browser smoke test error: $error\n$stack');
      rethrow;
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      running?.atakBroadcastService.dispose();
      running?.wardrivingService.dispose();
      running?.telemetryMonitorService.dispose();
      running?.weatherApiService.dispose();
      running?.connector.dispose();
      running?.retryService.dispose();
      running?.pathHistoryService.dispose();
      running?.appSettingsService.dispose();
      running?.connectionProfileService.dispose();
      running?.meshAnalyzerState.dispose();
      running?.meshMapperCoverageService.dispose();
      for (final timer in appTimers) {
        timer.cancel();
      }
      await tester.pump();
      FlutterError.onError = previousFlutterError;
      PlatformDispatcher.instance.onError = previousPlatformError;
      await tester.binding.setSurfaceSize(null);
      PrefsManager.reset();
    }
  });
}

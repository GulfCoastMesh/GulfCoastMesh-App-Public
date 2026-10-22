import 'dart:io';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

class BackgroundService {
  bool _initialized = false;
  final StreamController<DateTime> _wardrivingTickController =
      StreamController<DateTime>.broadcast();

  Stream<DateTime> get wardrivingTicks => _wardrivingTickController.stream;

  void _onTaskData(Object data) {
    if (data is! Map || data['type'] != 'wardriving_tick') return;
    final timestamp = data['timestamp'];
    if (timestamp is int && !_wardrivingTickController.isClosed) {
      _wardrivingTickController.add(
        DateTime.fromMillisecondsSinceEpoch(timestamp),
      );
    }
  }

  Future<void> initialize() async {
    if (kIsWeb || !Platform.isAndroid || _initialized) return;
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'meshcore_background',
        channelName: 'MeshCore Background',
        channelDescription: 'Keeps MeshCore running in the background.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(5000),
        autoRunOnBoot: false,
        allowWifiLock: false,
      ),
    );
    FlutterForegroundTask.addTaskDataCallback(_onTaskData);
    _initialized = true;
  }

  Future<bool> _ensureNotificationPermission({
    required bool requestIfDenied,
  }) async {
    var permission = await FlutterForegroundTask.checkNotificationPermission();
    if (permission != NotificationPermission.granted && requestIfDenied) {
      permission = await FlutterForegroundTask.requestNotificationPermission();
    }
    return permission == NotificationPermission.granted;
  }

  /// Starts the shared keep-alive foreground service.
  ///
  /// Returns false when the keep-alive is degraded (service failed to start
  /// or its notification cannot be shown). The service itself is started
  /// even without notification permission — Android still honors it; the
  /// user just cannot see the notification.
  /// Describes what the keep-alive is protecting. Set from the connector when
  /// a session starts so the notification names the actual transport rather
  /// than always claiming BLE.
  String _keepAliveText = 'Keeping the mesh connection alive';

  set keepAliveText(String value) {
    if (value.isEmpty || value == _keepAliveText) return;
    _keepAliveText = value;
    if (kIsWeb || !Platform.isAndroid) return;
    unawaited(
      FlutterForegroundTask.updateService(
        notificationTitle: 'MeshCore running',
        notificationText: _keepAliveText,
      ),
    );
  }

  Future<bool> start({
    bool requestPermissions = false,
    bool promptBatteryOptimization = false,
  }) async {
    if (kIsWeb || !Platform.isAndroid) return true;
    if (!_initialized) {
      await initialize();
    }
    // Only prompt on user-initiated connects; background reconnects cannot
    // show permission dialogs.
    final notificationsGranted = await _ensureNotificationPermission(
      requestIfDenied: requestPermissions,
    );
    var running = await FlutterForegroundTask.isRunningService;
    if (!running) {
      final result = await FlutterForegroundTask.startService(
        notificationTitle: 'MeshCore running',
        notificationText: _keepAliveText,
        callback: startCallback,
      );
      running = result is ServiceRequestSuccess;
    }
    // Don't block GATT connect on the OEM settings screen.
    if (running && promptBatteryOptimization) {
      unawaited(_promptIgnoreBatteryOptimizations());
    }
    return running && notificationsGranted;
  }

  Future<void> _promptIgnoreBatteryOptimizations() async {
    try {
      if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
        await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      }
    } catch (_) {}
  }

  /// Starts the same foreground service with wardriving-specific status.
  /// The service remains shared with BLE so connecting/disconnecting does not
  /// create competing Android foreground services.
  Future<void> startWardriving({
    String mode = 'active',
    int samples = 0,
  }) async {
    if (kIsWeb || !Platform.isAndroid) return;
    if (!_initialized) await initialize();
    await _ensureNotificationPermission(requestIfDenied: true);
    final running = await FlutterForegroundTask.isRunningService;
    if (!running) {
      await FlutterForegroundTask.startService(
        notificationTitle: 'Wardriving active',
        notificationText: '$mode · $samples samples',
        callback: startCallback,
      );
      return;
    }
    await updateWardrivingStatus(mode: mode, samples: samples);
  }

  Future<void> updateWardrivingStatus({
    required String mode,
    int samples = 0,
  }) async {
    if (kIsWeb ||
        !Platform.isAndroid ||
        !await FlutterForegroundTask.isRunningService) {
      return;
    }
    await FlutterForegroundTask.updateService(
      notificationTitle: 'Wardriving active',
      notificationText: '$mode · $samples samples',
    );
  }

  /// Leaves the shared BLE foreground service alive and restores its normal
  /// notification after a wardriving session ends.
  Future<void> finishWardriving() async {
    if (kIsWeb ||
        !Platform.isAndroid ||
        !await FlutterForegroundTask.isRunningService) {
      return;
    }
    await FlutterForegroundTask.updateService(
      notificationTitle: 'MeshCore running',
      notificationText: _keepAliveText,
    );
  }

  Future<void> stop() async {
    if (kIsWeb || !Platform.isAndroid) return;
    final running = await FlutterForegroundTask.isRunningService;
    if (!running) return;
    await FlutterForegroundTask.stopService();
  }
}

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(_MeshCoreTaskHandler());
}

class _MeshCoreTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {}

  @override
  void onRepeatEvent(DateTime timestamp) {
    // The foreground-task isolate owns the reliable Android cadence and wakes
    // the main isolate, where the live BLE connector and wardrive state live.
    FlutterForegroundTask.sendDataToMain({
      'type': 'wardriving_tick',
      'timestamp': timestamp.millisecondsSinceEpoch,
    });
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {}

  @override
  void onNotificationButtonPressed(String id) {}

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp('/');
  }
}

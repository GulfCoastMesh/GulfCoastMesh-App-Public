import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

enum AppDebugLogLevel { info, warning, error }

class AppDebugLogEntry {
  final DateTime timestamp;
  final AppDebugLogLevel level;
  final String tag;
  final String message;

  AppDebugLogEntry({
    required this.timestamp,
    required this.level,
    required this.tag,
    required this.message,
  });

  String get levelLabel {
    switch (level) {
      case AppDebugLogLevel.info:
        return 'INFO';
      case AppDebugLogLevel.warning:
        return 'WARN';
      case AppDebugLogLevel.error:
        return 'ERROR';
    }
  }

  String get formattedTime {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}:'
        '${timestamp.second.toString().padLeft(2, '0')}.'
        '${timestamp.millisecond.toString().padLeft(3, '0')}';
  }
}

class AppDebugLogService extends ChangeNotifier {
  static const int maxEntries = 1000;
  final List<AppDebugLogEntry> _entries = [];
  bool _enabled = false;
  bool _notifyScheduled = false;

  List<AppDebugLogEntry> get entries => List.unmodifiable(_entries);
  bool get enabled => _enabled;

  void setEnabled(bool value) {
    _enabled = value;
    _notifyListenersSafely();
  }

  void log(
    String message, {
    String tag = 'App',
    AppDebugLogLevel level = AppDebugLogLevel.info,
  }) {
    if (!_enabled) return;

    _entries.add(
      AppDebugLogEntry(
        timestamp: DateTime.now(),
        level: level,
        tag: tag,
        message: message,
      ),
    );

    if (_entries.length > maxEntries) {
      _entries.removeRange(0, _entries.length - maxEntries);
    }

    _notifyListenersSafely();

    // Also print to console for development
    debugPrint('[$tag] $message');
  }

  void info(String message, {String tag = 'App'}) {
    log(message, tag: tag, level: AppDebugLogLevel.info);
  }

  void warn(String message, {String tag = 'App'}) {
    log(message, tag: tag, level: AppDebugLogLevel.warning);
  }

  void error(String message, {String tag = 'App'}) {
    log(message, tag: tag, level: AppDebugLogLevel.error);
  }

  void clear() {
    _entries.clear();
    _notifyListenersSafely();
  }

  /// Mirrors the same pattern as [FrameDebugLogService]: avoid the
  /// "setState/markNeedsBuild called during build" assertion when a log
  /// call happens during the build phase by deferring the notify to the
  /// post-frame callback.
  void _notifyListenersSafely() {
    final phase = SchedulerBinding.instance.schedulerPhase;
    final canNotifyNow =
        phase == SchedulerPhase.idle ||
        phase == SchedulerPhase.postFrameCallbacks;
    if (canNotifyNow) {
      notifyListeners();
      return;
    }

    if (_notifyScheduled) return;
    _notifyScheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _notifyScheduled = false;
      notifyListeners();
    });
  }
}

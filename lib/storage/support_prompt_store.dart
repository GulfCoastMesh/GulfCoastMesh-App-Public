import 'prefs_manager.dart';

/// Tracks whether the one-time "support the community" prompt has been
/// shown, and when the app was first launched so it can be timed.
class SupportPromptStore {
  static const String _firstLaunchKey = 'support_prompt_first_launch_ms';
  static const String _shownKey = 'support_prompt_shown';

  /// Returns the first-launch timestamp, recording it as now if this is the
  /// very first time the app has run.
  Future<DateTime> loadOrInitFirstLaunch() async {
    final prefs = PrefsManager.instance;
    final storedMs = prefs.getInt(_firstLaunchKey);
    if (storedMs != null) {
      return DateTime.fromMillisecondsSinceEpoch(storedMs);
    }
    final now = DateTime.now();
    await prefs.setInt(_firstLaunchKey, now.millisecondsSinceEpoch);
    return now;
  }

  bool hasShownPrompt() => PrefsManager.instance.getBool(_shownKey) ?? false;

  Future<void> markPromptShown() async {
    await PrefsManager.instance.setBool(_shownKey, true);
  }
}

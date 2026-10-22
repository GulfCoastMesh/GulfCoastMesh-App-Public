import '../models/notification_pref.dart';
import 'prefs_manager.dart';

/// Per-channel and per-contact notification preferences.
///
/// [loadChannelPref]/[loadContactPref] read synchronously (the underlying
/// SharedPreferences reads already are) so they can be called inline from
/// the connector's notification-trigger code, which isn't itself async.
class NotificationPrefsStore {
  static const String _levelChannelPrefix = 'notif_level_channel_';
  static const String _soundChannelPrefix = 'notif_sound_channel_';
  static const String _vibrationChannelPrefix = 'notif_vibration_channel_';
  static const String _bannerChannelPrefix = 'notif_banner_channel_';
  static const String _levelContactPrefix = 'notif_level_contact_';
  static const String _soundContactPrefix = 'notif_sound_contact_';
  static const String _vibrationContactPrefix = 'notif_vibration_contact_';
  static const String _bannerContactPrefix = 'notif_banner_contact_';

  NotificationPref loadChannelPref(
    int channelIndex,
    NotificationLevel fallbackLevel,
  ) => _load(
    '$_levelChannelPrefix$channelIndex',
    '$_soundChannelPrefix$channelIndex',
    '$_vibrationChannelPrefix$channelIndex',
    '$_bannerChannelPrefix$channelIndex',
    fallbackLevel,
  );

  Future<void> saveChannelPref(int channelIndex, NotificationPref pref) =>
      _save(
        '$_levelChannelPrefix$channelIndex',
        '$_soundChannelPrefix$channelIndex',
        '$_vibrationChannelPrefix$channelIndex',
        '$_bannerChannelPrefix$channelIndex',
        pref,
      );

  NotificationPref loadContactPref(
    String contactKeyHex,
    NotificationLevel fallbackLevel,
  ) => _load(
    '$_levelContactPrefix$contactKeyHex',
    '$_soundContactPrefix$contactKeyHex',
    '$_vibrationContactPrefix$contactKeyHex',
    '$_bannerContactPrefix$contactKeyHex',
    fallbackLevel,
  );

  Future<void> saveContactPref(String contactKeyHex, NotificationPref pref) =>
      _save(
        '$_levelContactPrefix$contactKeyHex',
        '$_soundContactPrefix$contactKeyHex',
        '$_vibrationContactPrefix$contactKeyHex',
        '$_bannerContactPrefix$contactKeyHex',
        pref,
      );

  NotificationPref _load(
    String levelKey,
    String soundKey,
    String vibrationKey,
    String bannerKey,
    NotificationLevel fallbackLevel,
  ) {
    final prefs = PrefsManager.instance;
    final storedLevel = prefs.getInt(levelKey);
    return NotificationPref(
      level: storedLevel == null
          ? fallbackLevel
          : NotificationLevelValue.fromValue(storedLevel),
      soundEnabled: prefs.getBool(soundKey) ?? true,
      vibrationEnabled: prefs.getBool(vibrationKey) ?? true,
      bannerEnabled: prefs.getBool(bannerKey) ?? true,
    );
  }

  Future<void> _save(
    String levelKey,
    String soundKey,
    String vibrationKey,
    String bannerKey,
    NotificationPref pref,
  ) async {
    final prefs = PrefsManager.instance;
    await prefs.setInt(levelKey, pref.level.value);
    await prefs.setBool(soundKey, pref.soundEnabled);
    await prefs.setBool(vibrationKey, pref.vibrationEnabled);
    await prefs.setBool(bannerKey, pref.bannerEnabled);
  }
}

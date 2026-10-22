enum NotificationLevel { none, all, mentions, custom }

extension NotificationLevelValue on NotificationLevel {
  int get value => index;

  static NotificationLevel fromValue(int? value) {
    if (value == null ||
        value < 0 ||
        value >= NotificationLevel.values.length) {
      return NotificationLevel.all;
    }
    return NotificationLevel.values[value];
  }
}

class NotificationPref {
  final NotificationLevel level;

  /// Only meaningful when [level] is [NotificationLevel.custom].
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool bannerEnabled;

  const NotificationPref({
    required this.level,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.bannerEnabled = true,
  });
}

/// Whether [text] contains an `@[selfName]` mention, matching the app's
/// existing reply/mention syntax (see RichMessageParser).
bool messageMentionsSelf(String text, String? selfName) {
  if (selfName == null || selfName.isEmpty) return false;
  return RegExp('@\\[${RegExp.escape(selfName)}\\]').hasMatch(text);
}

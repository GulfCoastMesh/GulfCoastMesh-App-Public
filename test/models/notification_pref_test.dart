import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/models/notification_pref.dart';

void main() {
  group('messageMentionsSelf', () {
    test('matches an exact @[Name] mention', () {
      expect(
        messageMentionsSelf('hey @[Alice] check this out', 'Alice'),
        isTrue,
      );
    });

    test('does not match a partial name', () {
      expect(
        messageMentionsSelf('hey @[Alicein] check this out', 'Alice'),
        isFalse,
      );
    });

    test('does not match plain text without brackets', () {
      expect(messageMentionsSelf('hey Alice check this out', 'Alice'), isFalse);
    });

    test('returns false for null or empty selfName', () {
      expect(messageMentionsSelf('hey @[Alice]', null), isFalse);
      expect(messageMentionsSelf('hey @[Alice]', ''), isFalse);
    });

    test('is case-sensitive, matching the app\'s existing mention syntax', () {
      expect(messageMentionsSelf('hey @[alice]', 'Alice'), isFalse);
    });
  });

  group('NotificationLevelValue', () {
    test('round-trips through value/fromValue', () {
      for (final level in NotificationLevel.values) {
        expect(NotificationLevelValue.fromValue(level.value), level);
      }
    });

    test('falls back to all for an out-of-range or null value', () {
      expect(NotificationLevelValue.fromValue(null), NotificationLevel.all);
      expect(NotificationLevelValue.fromValue(-1), NotificationLevel.all);
      expect(NotificationLevelValue.fromValue(99), NotificationLevel.all);
    });
  });
}

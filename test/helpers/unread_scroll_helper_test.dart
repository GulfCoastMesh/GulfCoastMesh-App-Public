import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/helpers/unread_scroll_helper.dart';

void main() {
  group('findFirstUnreadIndex', () {
    test('returns null for zero or negative unread count', () {
      expect(findFirstUnreadIndex([1, 2, 3], 0, (_) => true), isNull);
      expect(findFirstUnreadIndex([1, 2, 3], -1, (_) => true), isNull);
    });

    test('simple case: every message qualifies', () {
      // Newest-first list; last 2 are unread -> index 1 is the oldest of them.
      expect(findFirstUnreadIndex([5, 4, 3, 2, 1], 2, (_) => true), 1);
    });

    test('skips non-qualifying messages without consuming the budget', () {
      // Chronologically oldest->newest: A(in) B(out) C(in). unreadCount=2
      // (A and C, since B is outgoing and doesn't count). Newest-first list:
      // [C, B, A]. The correct target is A (index 2), not B (index 1).
      final messages = ['C', 'B', 'A'];
      bool isQualifying(String m) => m != 'B';
      expect(findFirstUnreadIndex(messages, 2, isQualifying), 2);
    });

    test('returns null when fewer qualifying messages than unreadCount', () {
      expect(findFirstUnreadIndex([1, 2], 5, (_) => true), isNull);
    });

    test('returns null when unreadCount only reachable via non-qualifying', () {
      final messages = ['B', 'B', 'B'];
      bool isQualifying(String m) => m != 'B';
      expect(findFirstUnreadIndex(messages, 1, isQualifying), isNull);
    });
  });
}

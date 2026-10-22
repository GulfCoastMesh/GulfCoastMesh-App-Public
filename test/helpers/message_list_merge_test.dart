import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/helpers/message_list_merge.dart';
import 'package:gulf_coast_mesh_app/models/channel_message.dart';
import 'package:gulf_coast_mesh_app/models/message.dart';

void main() {
  group('mergeConversationMessages', () {
    test('keeps disk history and live message during load race', () {
      final key = Uint8List.fromList(List.filled(32, 9));
      final disk = [
        for (var i = 0; i < 3; i++)
          Message(
            senderKey: key,
            text: 'disk-$i',
            timestamp: DateTime.fromMillisecondsSinceEpoch(1_000 + i),
            isOutgoing: false,
            messageId: 'disk-$i',
          ),
      ];
      final live = [
        Message(
          senderKey: key,
          text: 'live',
          timestamp: DateTime.fromMillisecondsSinceEpoch(2_000),
          isOutgoing: false,
          messageId: 'live-1',
          status: MessageStatus.delivered,
        ),
      ];

      final merged = mergeConversationMessages(disk, live);
      expect(merged.map((m) => m.messageId), [
        'disk-0',
        'disk-1',
        'disk-2',
        'live-1',
      ]);
    });

    test('live status wins for matching messageId', () {
      final key = Uint8List.fromList(List.filled(32, 1));
      final disk = [
        Message(
          senderKey: key,
          text: 'hello',
          timestamp: DateTime.fromMillisecondsSinceEpoch(1_000),
          isOutgoing: true,
          messageId: 'm1',
          status: MessageStatus.pending,
        ),
      ];
      final live = [
        Message(
          senderKey: key,
          text: 'hello',
          timestamp: DateTime.fromMillisecondsSinceEpoch(1_000),
          isOutgoing: true,
          messageId: 'm1',
          status: MessageStatus.delivered,
        ),
      ];

      final merged = mergeConversationMessages(disk, live);
      expect(merged, hasLength(1));
      expect(merged.first.status, MessageStatus.delivered);
    });

    test('dedupes null-messageId copies across disk and live', () {
      final key = Uint8List.fromList(List.filled(32, 2));
      final ts = DateTime.fromMillisecondsSinceEpoch(5_000);
      final disk = [
        Message(senderKey: key, text: 'same', timestamp: ts, isOutgoing: false),
      ];
      final live = [
        Message(
          senderKey: key,
          text: 'same',
          timestamp: ts,
          isOutgoing: false,
          status: MessageStatus.delivered,
        ),
      ];

      final merged = mergeConversationMessages(disk, live);
      expect(merged, hasLength(1));
      expect(merged.first.status, MessageStatus.delivered);
    });
  });

  group('mergeChannelMessages', () {
    test('merges disk and live without dropping either', () {
      final disk = [
        ChannelMessage(
          senderName: 'a',
          text: 'one',
          timestamp: DateTime.fromMillisecondsSinceEpoch(1),
          isOutgoing: false,
          messageId: 'c1',
        ),
      ];
      final live = [
        ChannelMessage(
          senderName: 'b',
          text: 'two',
          timestamp: DateTime.fromMillisecondsSinceEpoch(2),
          isOutgoing: false,
          messageId: 'c2',
        ),
      ];

      final merged = mergeChannelMessages(disk, live);
      expect(merged.map((m) => m.messageId), ['c1', 'c2']);
    });
  });

  group('windowNewest', () {
    test('keeps the newest windowSize items', () {
      expect(windowNewest([1, 2, 3, 4, 5], 3), [3, 4, 5]);
      expect(windowNewest([1, 2], 5), [1, 2]);
    });
  });

  group('olderMessagePage', () {
    final all = List<int>.generate(10, (i) => i);

    test('returns the page immediately before the loaded window', () {
      expect(olderMessagePage(all, 4, count: 3), [3, 4, 5]);
    });

    test('clamps to what is actually left instead of over-reading', () {
      expect(olderMessagePage(all, 8, count: 50), [0, 1]);
    });

    test('is empty once the window already covers the whole list', () {
      expect(olderMessagePage(all, 10, count: 5), isEmpty);
    });

    test('is empty when the window somehow exceeds the list', () {
      expect(olderMessagePage(all, 12, count: 5), isEmpty);
    });

    test('is empty for a zero or negative page size', () {
      expect(olderMessagePage(all, 4, count: 0), isEmpty);
      expect(olderMessagePage(all, 4, count: -1), isEmpty);
    });

    test('handles an empty list', () {
      expect(olderMessagePage(<int>[], 0, count: 5), isEmpty);
    });

    test('walks back to the start over repeated pages', () {
      var loaded = 0;
      final seen = <int>[];
      for (var i = 0; i < 5; i++) {
        final page = olderMessagePage(all, loaded, count: 4);
        if (page.isEmpty) break;
        seen.insertAll(0, page);
        loaded += page.length;
      }
      expect(seen, all);
    });
  });
}

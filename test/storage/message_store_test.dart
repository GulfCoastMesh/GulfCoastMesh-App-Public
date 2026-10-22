import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/models/message.dart';
import 'package:gulf_coast_mesh_app/storage/message_store.dart';
import 'package:gulf_coast_mesh_app/storage/prefs_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late MessageStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PrefsManager.reset();
    await PrefsManager.initialize();
    store = MessageStore();
  });

  tearDown(() {
    PrefsManager.reset();
  });

  Message sample({required String text, required DateTime timestamp}) {
    return Message(
      senderKey: Uint8List.fromList(List.filled(32, 1)),
      text: text,
      timestamp: timestamp,
      isOutgoing: true,
      status: MessageStatus.delivered,
    );
  }

  test('round-trip preserves a normal message', () async {
    final ts = DateTime.fromMillisecondsSinceEpoch(1700000000000);
    await store.saveMessages('abc', [sample(text: 'hello', timestamp: ts)]);

    final loaded = await store.loadMessages('abc');
    expect(loaded, hasLength(1));
    expect(loaded.first.text, 'hello');
    expect(loaded.first.timestamp, ts);
  });

  test('one corrupt record does not drop the others', () async {
    final goodA = {
      'senderKey': base64Encode(List.filled(32, 1)),
      'text': 'good A',
      'timestamp': 1700000000000,
      'isOutgoing': true,
      'isCli': false,
      'status': MessageStatus.delivered.index,
      'fourByteRoomContactKey': base64Encode(<int>[]),
    };
    final bad = {
      'senderKey': base64Encode(List.filled(32, 1)),
      'text': 'corrupt',
      'timestamp': 1700000000001,
      'isOutgoing': true,
      'isCli': false,
      'status': 99,
      'fourByteRoomContactKey': base64Encode(<int>[]),
    };
    final goodB = {
      'senderKey': base64Encode(List.filled(32, 1)),
      'text': 'good B',
      'timestamp': 1700000000002,
      'isOutgoing': false,
      'isCli': false,
      'status': MessageStatus.delivered.index,
      'fourByteRoomContactKey': base64Encode(<int>[]),
    };

    await PrefsManager.instance.setString(
      'messages_abc',
      jsonEncode([goodA, bad, goodB]),
    );

    final loaded = await store.loadMessages('abc');
    expect(loaded.map((m) => m.text), ['good A', 'good B']);
  });

  test('top-level invalid json returns empty list', () async {
    await PrefsManager.instance.setString('messages_abc', 'not json');

    final loaded = await store.loadMessages('abc');
    expect(loaded, isEmpty);
  });

  test(
    'legacy media fields are ignored while reactions survive migration',
    () async {
      final message = Message(
        senderKey: Uint8List.fromList(List.filled(32, 1)),
        text: 'VE3:deadbeef:3:1',
        timestamp: DateTime.fromMillisecondsSinceEpoch(1700000000000),
        isOutgoing: false,
        status: MessageStatus.delivered,
        reactionReactors: {
          '👍': ['node-a', 'node-b'],
        },
      );
      await store.saveMessages('abc', [message]);
      final stored =
          jsonDecode(PrefsManager.instance.getString('messages_abc')!)
              as List<dynamic>;
      final legacy = stored.single as Map<String, dynamic>;
      legacy['mediaType'] = 'voice';
      legacy['mediaSessionId'] = 'deadbeef';
      legacy['mediaEnvelope'] = 'VE3:deadbeef:3:1';
      await PrefsManager.instance.setString('messages_abc', jsonEncode(stored));

      final loaded = await store.loadMessages('abc');
      expect(loaded.single.text, 'VE3:deadbeef:3:1');
      expect(loaded.single.reactionReactors['👍'], ['node-a', 'node-b']);
    },
  );
}

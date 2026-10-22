import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/models/channel_message.dart';
import 'package:gulf_coast_mesh_app/storage/channel_message_store.dart';
import 'package:gulf_coast_mesh_app/storage/prefs_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ChannelMessageStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PrefsManager.reset();
    await PrefsManager.initialize();
    store = ChannelMessageStore();
  });

  tearDown(() {
    PrefsManager.reset();
  });

  ChannelMessage sample({required String text, required DateTime timestamp}) {
    return ChannelMessage(
      senderName: 'sender',
      text: text,
      timestamp: timestamp,
      isOutgoing: false,
      status: ChannelMessageStatus.sent,
      channelIndex: 1,
      pathBytes: Uint8List(0),
    );
  }

  test('round-trip preserves a normal channel message', () async {
    final ts = DateTime.fromMillisecondsSinceEpoch(1700000000000);
    await store.saveChannelMessages(1, [sample(text: 'hi', timestamp: ts)]);

    final loaded = await store.loadChannelMessages(1);
    expect(loaded, hasLength(1));
    expect(loaded.first.text, 'hi');
    expect(loaded.first.timestamp, ts);
  });

  test('one corrupt record does not drop the others', () async {
    final goodA = {
      'senderName': 'sender',
      'text': 'good A',
      'timestamp': 1700000000000,
      'isOutgoing': false,
      'status': ChannelMessageStatus.sent.index,
      'channelIndex': 1,
      'pathBytes': base64Encode(<int>[]),
    };
    final bad = {
      'senderName': 'sender',
      'text': 'corrupt',
      'timestamp': 1700000000001,
      'isOutgoing': false,
      'status': 42,
      'channelIndex': 1,
      'pathBytes': base64Encode(<int>[]),
    };
    final goodB = {
      'senderName': 'sender',
      'text': 'good B',
      'timestamp': 1700000000002,
      'isOutgoing': false,
      'status': ChannelMessageStatus.sent.index,
      'channelIndex': 1,
      'pathBytes': base64Encode(<int>[]),
    };

    await PrefsManager.instance.setString(
      'channel_messages_1',
      jsonEncode([goodA, bad, goodB]),
    );

    final loaded = await store.loadChannelMessages(1);
    expect(loaded.map((m) => m.text), ['good A', 'good B']);
  });

  test('top-level invalid json returns empty list', () async {
    await PrefsManager.instance.setString('channel_messages_1', 'not json');

    final loaded = await store.loadChannelMessages(1);
    expect(loaded, isEmpty);
  });

  test('per-reactor reactions survive round-trip', () async {
    final message = ChannelMessage(
      senderName: 'sender',
      text: 'IE4:abcd:3:1:0',
      timestamp: DateTime.fromMillisecondsSinceEpoch(1700000000000),
      isOutgoing: false,
      status: ChannelMessageStatus.sent,
      channelIndex: 1,
      reactionReactors: {
        '❤️': ['node-a'],
      },
    );
    await store.saveChannelMessages(1, [message]);

    final loaded = await store.loadChannelMessages(1);
    expect(loaded.single.text, 'IE4:abcd:3:1:0');
    expect(loaded.single.reactionReactors['❤️'], ['node-a']);
  });
}

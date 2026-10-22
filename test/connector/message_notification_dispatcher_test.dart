import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/connector/message_notification_dispatcher.dart';
import 'package:gulf_coast_mesh_app/models/app_settings.dart';
import 'package:gulf_coast_mesh_app/models/notifiable_message.dart';
import 'package:gulf_coast_mesh_app/models/notification_pref.dart';
import 'package:gulf_coast_mesh_app/services/notification_service.dart';
import 'package:gulf_coast_mesh_app/storage/prefs_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/recording_notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PrefsManager.reset();
    await PrefsManager.initialize();
    // The platform notification plugin is unavailable under test; the
    // NotifiableMessage stream is what these assertions read.
    NotificationService().suppressNotifications(true);
  });

  tearDown(() {
    NotificationService().suppressNotifications(false);
    PrefsManager.reset();
  });

  MessageNotificationDispatcher build({
    AppSettings? settings,
    String? selfName = 'Bravo',
    bool Function(String)? isNodeHidden,
  }) {
    final resolved = settings ?? AppSettings();
    final dispatcher = MessageNotificationDispatcher(
      readSettings: () => resolved,
      readSelfName: () => selfName,
      readBadgeCount: () => 3,
      isNodeHidden: isNodeHidden,
    );
    addTearDown(dispatcher.dispose);
    return dispatcher;
  }

  group('shouldFire', () {
    test('level none blocks everything, level all passes everything', () {
      final dispatcher = build();
      expect(
        dispatcher.shouldFire(
          const NotificationPref(level: NotificationLevel.none),
          'anything',
        ),
        isFalse,
      );
      expect(
        dispatcher.shouldFire(
          const NotificationPref(level: NotificationLevel.all),
          'anything',
        ),
        isTrue,
      );
      expect(
        dispatcher.shouldFire(
          const NotificationPref(level: NotificationLevel.custom),
          'anything',
        ),
        isTrue,
      );
    });

    test('mentions-only passes only when the message names self', () {
      final dispatcher = build(selfName: 'Bravo');
      const mentions = NotificationPref(level: NotificationLevel.mentions);

      expect(dispatcher.shouldFire(mentions, 'hey @[Bravo] you up?'), isTrue);
      expect(
        dispatcher.shouldFire(mentions, 'talking to someone else'),
        isFalse,
      );
    });

    test('mentions-only with no self name yet cannot match', () {
      final dispatcher = build(selfName: null);
      expect(
        dispatcher.shouldFire(
          const NotificationPref(level: NotificationLevel.mentions),
          'hey @[Bravo]',
        ),
        isFalse,
      );
    });
  });

  group('notifyDirectMessage', () {
    test('emits a notifiable addressed to the sender conversation', () async {
      final dispatcher = build();
      final emitted = dispatcher.notifiableMessages.first;

      dispatcher.notifyDirectMessage(
        senderKeyHex: 'abc123',
        senderName: 'Alice',
        text: 'radio check',
      );

      final message = await emitted;
      expect(message.conversationId, NotifiableMessage.forContact('abc123'));
      expect(message.senderName, 'Alice');
      expect(message.text, 'radio check');
      expect(message.isGroup, isFalse);
    });

    test('a room message is titled and marked as a group', () async {
      final dispatcher = build();
      final emitted = dispatcher.notifiableMessages.first;

      dispatcher.notifyDirectMessage(
        senderKeyHex: 'room99',
        senderName: 'Net Control',
        text: 'weekly net starting',
        isRoom: true,
      );

      final message = await emitted;
      expect(message.conversationTitle, 'Net Control');
      expect(message.isGroup, isTrue);
    });

    test('nothing is emitted when notifications are off globally', () async {
      final dispatcher = build(
        settings: AppSettings(notificationsEnabled: false),
      );
      final seen = <NotifiableMessage>[];
      dispatcher.notifiableMessages.listen(seen.add);

      dispatcher.notifyDirectMessage(
        senderKeyHex: 'abc123',
        senderName: 'Alice',
        text: 'radio check',
      );

      await Future<void>.delayed(Duration.zero);
      expect(seen, isEmpty);
    });

    test('nothing is emitted when only DM notifications are off', () async {
      final dispatcher = build(
        settings: AppSettings(notifyOnNewMessage: false),
      );
      final seen = <NotifiableMessage>[];
      dispatcher.notifiableMessages.listen(seen.add);

      dispatcher.notifyDirectMessage(
        senderKeyHex: 'abc123',
        senderName: 'Alice',
        text: 'radio check',
      );

      await Future<void>.delayed(Duration.zero);
      expect(seen, isEmpty);
    });

    test('mentions-only settings gate the emission too', () async {
      final dispatcher = build(
        settings: AppSettings(
          notificationDefaultLevel: NotificationLevel.mentions,
        ),
        selfName: 'Bravo',
      );
      final seen = <NotifiableMessage>[];
      dispatcher.notifiableMessages.listen(seen.add);

      dispatcher.notifyDirectMessage(
        senderKeyHex: 'abc123',
        senderName: 'Alice',
        text: 'not for you',
      );
      dispatcher.notifyDirectMessage(
        senderKeyHex: 'abc123',
        senderName: 'Alice',
        text: '@[Bravo], you there?',
      );

      await Future<void>.delayed(Duration.zero);
      expect(seen.map((m) => m.text), ['@[Bravo], you there?']);
    });
  });

  group('notifyChannelMessage', () {
    test('emits a group notifiable titled with the channel', () async {
      final dispatcher = build();
      final emitted = dispatcher.notifiableMessages.first;

      dispatcher.notifyChannelMessage(
        channelIndex: 2,
        channelName: 'Gulf Coast',
        senderName: 'Charlie',
        text: 'net in 10',
      );

      final message = await emitted;
      expect(message.conversationId, NotifiableMessage.forChannel(2));
      expect(message.conversationTitle, 'Gulf Coast');
      expect(message.senderName, 'Charlie');
      expect(message.isGroup, isTrue);
    });

    test('nothing is emitted when channel notifications are off', () async {
      final dispatcher = build(
        settings: AppSettings(notifyOnNewChannelMessage: false),
      );
      final seen = <NotifiableMessage>[];
      dispatcher.notifiableMessages.listen(seen.add);

      dispatcher.notifyChannelMessage(
        channelIndex: 2,
        channelName: 'Gulf Coast',
        senderName: 'Charlie',
        text: 'net in 10',
      );

      await Future<void>.delayed(Duration.zero);
      expect(seen, isEmpty);
    });
  });

  test('a disposed dispatcher drops further emissions instead of throwing', () {
    final dispatcher = MessageNotificationDispatcher(
      readSettings: () => AppSettings(),
      readSelfName: () => 'Bravo',
      readBadgeCount: () => 0,
    );
    dispatcher.dispose();

    expect(
      () => dispatcher.notifyChannelMessage(
        channelIndex: 1,
        channelName: 'Gulf Coast',
        senderName: 'Charlie',
        text: 'still here?',
      ),
      returnsNormally,
    );
  });

  group('blocked nodes', () {
    MessageNotificationDispatcher buildWith(
      RecordingNotificationService sink,
      bool Function(String)? isNodeHidden,
    ) {
      final dispatcher = MessageNotificationDispatcher(
        readSettings: () => AppSettings(),
        readSelfName: () => 'Bravo',
        readBadgeCount: () => 3,
        notificationService: sink,
        isNodeHidden: isNodeHidden,
      );
      addTearDown(dispatcher.dispose);
      return dispatcher;
    }

    test('a blocked direct message neither notifies nor emits', () async {
      final sink = RecordingNotificationService();
      final dispatcher = buildWith(sink, (key) => key == 'blocked1');
      final emitted = <NotifiableMessage>[];
      final sub = dispatcher.notifiableMessages.listen(emitted.add);
      addTearDown(sub.cancel);

      dispatcher.notifyDirectMessage(
        senderKeyHex: 'blocked1',
        senderName: 'Muted',
        text: 'hello',
      );
      dispatcher.notifyDirectMessage(
        senderKeyHex: 'blocked1',
        senderName: 'Muted Room',
        text: 'hello',
        isRoom: true,
      );
      await Future<void>.delayed(Duration.zero);
      expect(emitted, isEmpty);
      expect(sink.messages, isEmpty);
    });

    test(
      'other senders and an absent predicate still notify and emit',
      () async {
        for (final hidden in <bool Function(String)?>[
          (key) => key == 'blocked1',
          null,
        ]) {
          final sink = RecordingNotificationService();
          final dispatcher = buildWith(sink, hidden);
          final emitted = dispatcher.notifiableMessages.first;

          dispatcher.notifyDirectMessage(
            senderKeyHex: hidden == null ? 'blocked1' : 'friend2',
            senderName: 'Friend',
            text: 'hello',
          );

          expect((await emitted).senderName, 'Friend');
          expect(sink.messages, hasLength(1));
        }
      },
    );

    test('a blocked advert is not shown; an unblocked one is', () {
      final blockedSink = RecordingNotificationService();
      buildWith(blockedSink, (key) => key == 'blocked1').notifyAdvert(
        contactName: 'Repeater',
        contactType: 'Repeater',
        contactKeyHex: 'blocked1',
      );
      expect(blockedSink.adverts, isEmpty);

      final openSink = RecordingNotificationService();
      final open = buildWith(openSink, (key) => key == 'blocked1');
      open.notifyAdvert(
        contactName: 'Repeater',
        contactType: 'Repeater',
        contactKeyHex: 'other2',
      );
      expect(openSink.adverts, ['other2']);
    });
  });
}

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/models/contact.dart';
import 'package:gulf_coast_mesh_app/models/message.dart';
import 'package:gulf_coast_mesh_app/services/message_retry_service.dart';

void main() {
  Contact contact({int pathLength = -1}) => Contact(
    publicKey: Uint8List.fromList(List<int>.generate(32, (i) => i + 1)),
    name: 'Remote',
    type: 1,
    pathLength: pathLength,
    path: Uint8List(0),
    lastSeen: DateTime.utc(2026, 1, 1),
  );

  for (final earlySent in [true, false]) {
    testWidgets(
      'SENT ${earlySent ? 'before' : 'after'} write completion keeps the delivery timeout',
      (tester) async {
        final service = MessageRetryService();
        final write = Completer<void>();
        final selfKey = Uint8List.fromList(List.filled(32, 9));
        late Message latest;
        service.initialize(
          sendMessageCallback: (_, _, _, _) => write.future,
          addMessageCallback: (_, message) => latest = message,
          updateMessageCallback: (message) => latest = message,
          getSelfPublicKeyCallback: () => selfKey,
        );
        try {
          final sending = service.sendMessageWithRetry(
            contact: contact(),
            text: 'hello',
          );
          final hash = MessageRetryService.computeExpectedAckHash(
            latest.timestamp.millisecondsSinceEpoch ~/ 1000,
            0,
            'hello',
            selfKey,
          );
          if (earlySent) service.updateMessageFromSent(hash, 30000);
          write.complete();
          await sending;
          if (!earlySent) service.updateMessageFromSent(hash, 30000);
          await tester.pump(const Duration(seconds: 9));
          expect(latest.status, MessageStatus.sent);
          expect(latest.retryCount, 0);
          await tester.pump(const Duration(seconds: 21));
          expect(latest.retryCount, 1);
        } finally {
          service.dispose();
        }
      },
    );
  }

  for (final delivered in [true, false]) {
    testWidgets('${delivered ? 'ACK' : 'SENT'} wins over a late write error', (
      tester,
    ) async {
      final service = MessageRetryService();
      final write = Completer<void>();
      final selfKey = Uint8List.fromList(List.filled(32, 9));
      late Message latest;
      service.initialize(
        sendMessageCallback: (_, _, _, _) => write.future,
        addMessageCallback: (_, message) => latest = message,
        updateMessageCallback: (message) => latest = message,
        getSelfPublicKeyCallback: () => selfKey,
      );
      try {
        final sending = service.sendMessageWithRetry(
          contact: contact(),
          text: 'hello',
        );
        final hash = MessageRetryService.computeExpectedAckHash(
          latest.timestamp.millisecondsSinceEpoch ~/ 1000,
          0,
          'hello',
          selfKey,
        );
        service.updateMessageFromSent(hash, 30000);
        if (delivered) service.handleAckReceived(hash, 100);
        write.completeError(StateError('late write failure'));
        await sending;
        await tester.pump(const Duration(seconds: 9));
        expect(
          latest.status,
          delivered ? MessageStatus.delivered : MessageStatus.sent,
        );
        expect(latest.retryCount, 0);
        expect(service.hasPendingMessages, !delivered);
      } finally {
        service.dispose();
      }
    });
  }

  testWidgets(
    'missing SENT still retries and a failed write does not strand it',
    (tester) async {
      final service = MessageRetryService();
      var sends = 0;
      late Message latest;
      service.initialize(
        sendMessageCallback: (_, _, _, _) async {
          if (++sends > 1) throw StateError('offline');
        },
        addMessageCallback: (_, message) => latest = message,
        updateMessageCallback: (message) => latest = message,
      );
      try {
        await service.sendMessageWithRetry(contact: contact(), text: 'hello');
        await tester.pump(const Duration(seconds: 8));
        expect(latest.retryCount, 1);
        await tester.pump(const Duration(seconds: 1));
        expect(sends, 2);
        expect(latest.retryCount, 2);
      } finally {
        service.dispose();
      }
    },
  );

  testWidgets('an older write cannot replace a newer attempt delivery timer', (
    tester,
  ) async {
    final service = MessageRetryService();
    final firstWrite = Completer<void>();
    final selfKey = Uint8List.fromList(List.filled(32, 9));
    var sends = 0;
    late Message latest;
    service.initialize(
      sendMessageCallback: (_, _, _, _) async {
        if (++sends == 1) await firstWrite.future;
      },
      addMessageCallback: (_, message) => latest = message,
      updateMessageCallback: (message) => latest = message,
      getSelfPublicKeyCallback: () => selfKey,
    );
    try {
      final sending = service.sendMessageWithRetry(
        contact: contact(),
        text: 'hello',
      );
      Uint8List hash(int attempt) => MessageRetryService.computeExpectedAckHash(
        latest.timestamp.millisecondsSinceEpoch ~/ 1000,
        attempt,
        'hello',
        selfKey,
      );
      service.updateMessageFromSent(hash(0), 1000);
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(sends, 2);
      service.updateMessageFromSent(hash(1), 30000);
      firstWrite.complete();
      await sending;
      await tester.pump(const Duration(seconds: 9));
      expect(latest.status, MessageStatus.sent);
      expect(latest.retryCount, 1);
    } finally {
      service.dispose();
    }
  });

  testWidgets('disposal during a write does not re-arm its timeout', (
    tester,
  ) async {
    final service = MessageRetryService();
    final write = Completer<void>();
    service.initialize(
      sendMessageCallback: (_, _, _, _) => write.future,
      addMessageCallback: (_, _) {},
      updateMessageCallback: (_) {},
    );
    final sending = service.sendMessageWithRetry(
      contact: contact(),
      text: 'hello',
    );
    service.dispose();
    write.complete();
    await sending;
    // testWidgets also asserts that no timers remain after this test.
    expect(service.hasPendingMessages, isFalse);
  });

  test('flood route is cleared before the message frame is sent', () async {
    final service = MessageRetryService();
    addTearDown(service.dispose);
    final routeReady = Completer<void>();
    final events = <String>[];
    service.initialize(
      clearContactPathCallback: (_) async {
        events.add('clear-start');
        await routeReady.future;
        events.add('clear-end');
      },
      setContactPathCallback: (_, _, _) async {},
      sendMessageCallback: (_, _, _, _) async => events.add('send'),
      addMessageCallback: (_, _) {},
      updateMessageCallback: (_) {},
    );

    final sending = service.sendMessageWithRetry(
      contact: contact(),
      text: 'hello',
    );
    await Future<void>.delayed(Duration.zero);
    expect(events, ['clear-start']);

    routeReady.complete();
    await sending;
    expect(events, ['clear-start', 'clear-end', 'send']);
  });

  test(
    'route setup failure schedules retry instead of stranding message',
    () async {
      final service = MessageRetryService();
      addTearDown(service.dispose);
      final updates = <Message>[];
      var sendCount = 0;
      service.initialize(
        clearContactPathCallback: (_) async => throw StateError('offline'),
        setContactPathCallback: (_, _, _) async {},
        sendMessageCallback: (_, _, _, _) async => sendCount++,
        addMessageCallback: (_, _) {},
        updateMessageCallback: updates.add,
      );

      await service.sendMessageWithRetry(contact: contact(), text: 'hello');

      expect(sendCount, 0);
      expect(service.hasPendingMessages, isTrue);
      expect(updates.single.retryCount, 1);
      expect(updates.single.status, MessageStatus.pending);
    },
  );

  test('calculated timeout uses UTF-8 payload byte length', () async {
    final service = MessageRetryService();
    addTearDown(service.dispose);
    late Message message;
    var messageBytes = -1;
    final selfKey = Uint8List.fromList(List<int>.filled(32, 9));
    service.initialize(
      sendMessageCallback: (_, _, _, _) async {},
      addMessageCallback: (_, value) => message = value,
      updateMessageCallback: (_) {},
      getSelfPublicKeyCallback: () => selfKey,
      calculateTimeoutCallback: (_, bytes) {
        messageBytes = bytes;
        return 1000;
      },
    );

    const text = 'José ✅';
    await service.sendMessageWithRetry(
      contact: contact(pathLength: 0),
      text: text,
    );
    final ackHash = MessageRetryService.computeExpectedAckHash(
      message.timestamp.millisecondsSinceEpoch ~/ 1000,
      0,
      text,
      selfKey,
    );

    expect(service.updateMessageFromSent(ackHash, 0), isTrue);
    expect(messageBytes, utf8.encode(text).length);
  });

  test(
    'sending before initialization fails without adding a message',
    () async {
      final service = MessageRetryService();
      addTearDown(service.dispose);

      await expectLater(
        service.sendMessageWithRetry(contact: contact(), text: 'hello'),
        throwsA(isA<StateError>()),
      );
      expect(service.hasPendingMessages, isFalse);
    },
  );
}

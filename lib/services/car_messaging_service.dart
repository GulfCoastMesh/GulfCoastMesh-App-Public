import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../connector/meshcore_connector.dart';
import '../connector/meshcore_protocol.dart';
import '../models/channel.dart';
import '../models/contact.dart';
import '../models/notifiable_message.dart';

/// Bridges mesh conversations to Android Auto.
///
/// Android Auto supplies the read-aloud and the voice dictation itself; this
/// only has to publish each message as a MessagingStyle notification and route
/// the dictated reply back to the *same* connector the phone UI uses, so a reply
/// from the car is indistinguishable from one typed on the phone.
class CarMessagingService {
  CarMessagingService({
    required MeshCoreConnector connector,
    MethodChannel? methodChannel,
    EventChannel? eventChannel,
    bool? enabled,
  }) : _connector = connector,
       // Android Auto is Android-only; the override exists so the routing can
       // be tested on the host, where Platform.isAndroid is false.
       _enabled = enabled ?? (!kIsWeb && Platform.isAndroid),
       _methods =
           methodChannel ??
           const MethodChannel('org.gulfcoastmesh/car_messaging'),
       _events =
           eventChannel ??
           const EventChannel('org.gulfcoastmesh/car_messaging_events');

  final MeshCoreConnector _connector;
  final MethodChannel _methods;
  final EventChannel _events;
  final bool _enabled;

  StreamSubscription<NotifiableMessage>? _messageSubscription;
  StreamSubscription<dynamic>? _eventSubscription;

  void start() {
    if (!_enabled) return;
    _messageSubscription = _connector.notifiableMessages.listen(_publish);
    _eventSubscription = _events.receiveBroadcastStream().listen(
      _handleCarEvent,
      onError: (Object error) =>
          debugPrint('Car messaging event stream error: $error'),
    );
  }

  Future<void> _publish(NotifiableMessage message) async {
    // A conversation the user already has open on the phone should not also be
    // announced in the car.
    if (_isActiveOnPhone(message.conversationId)) return;

    try {
      await _methods.invokeMethod<void>('showMessage', {
        'conversationId': message.conversationId,
        'conversationTitle': message.conversationTitle,
        'sender': message.senderName,
        'text': message.text,
        'isGroup': message.isGroup,
      });
    } on PlatformException catch (e) {
      debugPrint('Failed to publish car message: ${e.message}');
    } on MissingPluginException {
      // Older install without the native side; nothing to do.
    }
  }

  bool _isActiveOnPhone(String conversationId) {
    if (conversationId.startsWith(NotifiableMessage.contactPrefix)) {
      final key = conversationId.substring(
        NotifiableMessage.contactPrefix.length,
      );
      return _connector.activeContactKey == key;
    }
    if (conversationId.startsWith(NotifiableMessage.channelPrefix)) {
      final index = int.tryParse(
        conversationId.substring(NotifiableMessage.channelPrefix.length),
      );
      return index != null && _connector.activeChannelIndex == index;
    }
    return false;
  }

  Future<void> _handleCarEvent(dynamic event) async {
    if (event is! Map) return;
    final conversationId = event['conversationId'];
    if (conversationId is! String) return;

    switch (event['type']) {
      case 'reply':
        final text = event['text'];
        if (text is String && text.trim().isNotEmpty) {
          await _sendReply(conversationId, text.trim());
        }
        break;
      case 'markAsRead':
        _markRead(conversationId);
        break;
    }
  }

  void _markRead(String conversationId) {
    if (conversationId.startsWith(NotifiableMessage.contactPrefix)) {
      final key = conversationId.substring(
        NotifiableMessage.contactPrefix.length,
      );
      _connector.markContactRead(key);
    } else if (conversationId.startsWith(NotifiableMessage.channelPrefix)) {
      final index = int.tryParse(
        conversationId.substring(NotifiableMessage.channelPrefix.length),
      );
      if (index != null) _connector.markChannelRead(index);
    }
  }

  Future<void> _sendReply(String conversationId, String text) async {
    // Every failure below is reported back into the car thread rather than
    // swallowed — the driver cannot see the phone, so silence would read as
    // "sent".
    if (!_connector.isConnected) {
      await _reportFailure(
        conversationId,
        'Not connected to a MeshCore device. Your reply was not sent.',
      );
      return;
    }

    if (conversationId.startsWith(NotifiableMessage.contactPrefix)) {
      final key = conversationId.substring(
        NotifiableMessage.contactPrefix.length,
      );
      final contact = _contactFor(key);
      if (contact == null) {
        await _reportFailure(
          conversationId,
          'That contact is no longer known.',
        );
        return;
      }
      final trimmed = _fitToLimit(text, maxContactMessageBytes());
      await _trySend(
        conversationId,
        () => _connector.sendMessage(contact, trimmed),
        trimmed,
        truncated: trimmed.length != text.length,
      );
      return;
    }

    if (conversationId.startsWith(NotifiableMessage.channelPrefix)) {
      final index = int.tryParse(
        conversationId.substring(NotifiableMessage.channelPrefix.length),
      );
      final channel = index == null ? null : _channelFor(index);
      if (channel == null) {
        await _reportFailure(
          conversationId,
          'That channel is no longer known.',
        );
        return;
      }
      final trimmed = _fitToLimit(
        text,
        maxChannelMessageBytes(_connector.selfName),
      );
      await _trySend(
        conversationId,
        () => _connector.sendChannelMessage(channel, trimmed),
        trimmed,
        truncated: trimmed.length != text.length,
      );
    }
  }

  Future<void> _trySend(
    String conversationId,
    Future<void> Function() send,
    String sentText, {
    required bool truncated,
  }) async {
    try {
      await send();
      await _appendOutgoing(conversationId, sentText);
      if (truncated) {
        await _reportFailure(
          conversationId,
          'Your reply was shortened to fit the mesh message limit.',
        );
      }
    } catch (e) {
      await _reportFailure(conversationId, 'Reply failed to send: $e');
    }
  }

  @visibleForTesting
  static String fitToLimitForTest(String text, int maxBytes) =>
      _fitToLimit(text, maxBytes);

  /// Truncates on a UTF-8 boundary so a long dictation is shortened rather than
  /// rejected — mesh text is capped at 160 bytes, and voice input overruns it
  /// easily.
  static String _fitToLimit(String text, int maxBytes) {
    if (utf8.encode(text).length <= maxBytes) return text;
    var candidate = text;
    while (candidate.isNotEmpty && utf8.encode(candidate).length > maxBytes) {
      candidate = candidate.substring(0, candidate.length - 1);
    }
    return candidate;
  }

  Contact? _contactFor(String publicKeyHex) {
    for (final contact in _connector.contacts) {
      if (contact.publicKeyHex == publicKeyHex) return contact;
    }
    return null;
  }

  Channel? _channelFor(int index) {
    for (final channel in _connector.channels) {
      if (channel.index == index) return channel;
    }
    return null;
  }

  Future<void> _appendOutgoing(String conversationId, String text) async {
    try {
      await _methods.invokeMethod<void>('appendOutgoing', {
        'conversationId': conversationId,
        'text': text,
      });
    } on PlatformException catch (e) {
      debugPrint('Failed to append outgoing car message: ${e.message}');
    } on MissingPluginException {
      // Native side absent; nothing to do.
    }
  }

  Future<void> _reportFailure(String conversationId, String reason) async {
    try {
      await _methods.invokeMethod<void>('showSendFailure', {
        'conversationId': conversationId,
        'reason': reason,
      });
    } on PlatformException catch (e) {
      debugPrint('Failed to report car send failure: ${e.message}');
    } on MissingPluginException {
      // Native side absent; nothing to do.
    }
  }

  void dispose() {
    unawaited(_messageSubscription?.cancel());
    unawaited(_eventSubscription?.cancel());
  }
}

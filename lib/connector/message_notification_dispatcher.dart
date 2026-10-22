import 'dart:async';

import '../helpers/channel_message_preview.dart';
import '../models/app_settings.dart';
import '../models/notifiable_message.dart';
import '../models/notification_pref.dart';
import '../services/notification_service.dart';
import '../storage/notification_prefs_store.dart';

/// Decides whether an incoming advert, direct message, or channel message is
/// worth interrupting the user for, and dispatches it if so.
///
/// Split out of `MeshCoreConnector`, which held the per-contact and per-channel
/// preference lookups, the mention matching, the platform notification calls,
/// and the `NotifiableMessage` stream that Android Auto reads. The connector
/// supplies the live state this needs through callbacks, so this class knows
/// nothing about transports, contacts, or frame parsing.
class MessageNotificationDispatcher {
  MessageNotificationDispatcher({
    required AppSettings? Function() readSettings,
    required String? Function() readSelfName,
    required int Function() readBadgeCount,
    NotificationService? notificationService,
    NotificationPrefsStore? prefsStore,
    bool Function(String contactKeyHex)? isNodeHidden,
  }) : _isNodeHidden = isNodeHidden ?? ((_) => false),
       _readSettings = readSettings,
       _readSelfName = readSelfName,
       _readBadgeCount = readBadgeCount,
       _notificationService = notificationService ?? NotificationService(),
       _prefsStore = prefsStore ?? NotificationPrefsStore();

  final AppSettings? Function() _readSettings;
  final String? Function() _readSelfName;
  final int Function() _readBadgeCount;
  final NotificationService _notificationService;
  final NotificationPrefsStore _prefsStore;
  final bool Function(String contactKeyHex) _isNodeHidden;

  final StreamController<NotifiableMessage> _notifiableController =
      StreamController<NotifiableMessage>.broadcast();

  /// Messages worth surfacing outside the app — Android Auto reads this.
  Stream<NotifiableMessage> get notifiableMessages =>
      _notifiableController.stream;

  void initialize() => _notificationService.initialize();

  NotificationLevel get _defaultLevel =>
      _readSettings()?.notificationDefaultLevel ?? NotificationLevel.all;

  NotificationPref prefForContact(String contactKeyHex) =>
      _prefsStore.loadContactPref(contactKeyHex, _defaultLevel);

  NotificationPref prefForChannel(int channelIndex) =>
      _prefsStore.loadChannelPref(channelIndex, _defaultLevel);

  /// Whether [pref] lets [messageText] through, honouring "mentions only".
  bool shouldFire(NotificationPref pref, String messageText) {
    switch (pref.level) {
      case NotificationLevel.none:
        return false;
      case NotificationLevel.mentions:
        return messageMentionsSelf(messageText, _readSelfName());
      case NotificationLevel.all:
      case NotificationLevel.custom:
        return true;
    }
  }

  void emit(NotifiableMessage message) {
    if (!_notifiableController.isClosed) {
      _notifiableController.add(message);
    }
  }

  /// A newly discovered contact advertised itself.
  void notifyAdvert({
    required String contactName,
    required String contactType,
    required String contactKeyHex,
  }) {
    if (_isNodeHidden(contactKeyHex)) return;
    final settings = _readSettings();
    if (settings == null ||
        !settings.notificationsEnabled ||
        !settings.notifyOnNewAdvert) {
      return;
    }
    final pref = prefForContact(contactKeyHex);
    // Adverts carry no message text, so "mentions only" behaves like "none".
    if (pref.level == NotificationLevel.none ||
        pref.level == NotificationLevel.mentions) {
      return;
    }
    _notificationService.showAdvertNotification(
      contactName: contactName,
      contactType: contactType,
      contactId: contactKeyHex,
      soundEnabled: pref.soundEnabled,
      vibrationEnabled: pref.vibrationEnabled,
      bannerEnabled: pref.bannerEnabled,
    );
  }

  /// An incoming direct message from a chat contact or a room.
  ///
  /// [text] is what the user should see; the caller strips any room prefix
  /// first. [isRoom] only changes how the conversation is titled.
  void notifyDirectMessage({
    required String senderKeyHex,
    required String senderName,
    required String text,
    bool isRoom = false,
  }) {
    // Muting blocked senders lives only here; remove this line to undo it.
    if (_isNodeHidden(senderKeyHex)) return;
    final settings = _readSettings();
    if (settings == null ||
        !settings.notificationsEnabled ||
        !settings.notifyOnNewMessage) {
      return;
    }
    final pref = prefForContact(senderKeyHex);
    if (!shouldFire(pref, text)) return;

    _notificationService.showMessageNotification(
      contactName: senderName,
      message: text,
      contactId: senderKeyHex,
      badgeCount: _readBadgeCount(),
      soundEnabled: pref.soundEnabled,
      vibrationEnabled: pref.vibrationEnabled,
      bannerEnabled: pref.bannerEnabled,
    );
    emit(
      NotifiableMessage(
        conversationId: NotifiableMessage.forContact(senderKeyHex),
        senderName: senderName,
        conversationTitle: isRoom ? senderName : null,
        text: text,
        isGroup: isRoom,
      ),
    );
  }

  /// An incoming message on a subscribed channel.
  void notifyChannelMessage({
    required int channelIndex,
    required String channelName,
    required String senderName,
    required String text,
  }) {
    final settings = _readSettings();
    if (settings == null ||
        !settings.notificationsEnabled ||
        !settings.notifyOnNewChannelMessage) {
      return;
    }
    if (!ChannelMessagePreview.shouldNotify(text)) return;

    final pref = prefForChannel(channelIndex);
    if (!shouldFire(pref, text)) return;

    _notificationService.showChannelMessageNotification(
      channelName: channelName,
      message: text,
      channelIndex: channelIndex,
      badgeCount: _readBadgeCount(),
      soundEnabled: pref.soundEnabled,
      vibrationEnabled: pref.vibrationEnabled,
      bannerEnabled: pref.bannerEnabled,
    );
    emit(
      NotifiableMessage(
        conversationId: NotifiableMessage.forChannel(channelIndex),
        senderName: senderName,
        conversationTitle: channelName,
        text: text,
        isGroup: true,
      ),
    );
  }

  void dispose() {
    unawaited(_notifiableController.close());
  }
}

/// An incoming message that passed every notification gate.
///
/// Emitted at the same points the in-app notifications fire, so anything
/// downstream (Android Auto, say) inherits the user's mute and mention
/// preferences instead of reimplementing them.
class NotifiableMessage {
  /// Stable conversation key, matching the notification payload scheme:
  /// `message:<pubKeyHex>` for direct/room chats, `channel:<index>` for
  /// channels. This is what routes a reply back to the right destination.
  final String conversationId;

  /// Who the message is from, for read-aloud.
  final String senderName;

  /// Channel or room name when [isGroup]; null for a one-to-one chat.
  final String? conversationTitle;

  final String text;
  final bool isGroup;

  const NotifiableMessage({
    required this.conversationId,
    required this.senderName,
    required this.text,
    this.conversationTitle,
    this.isGroup = false,
  });

  static const String contactPrefix = 'message:';
  static const String channelPrefix = 'channel:';

  static String forContact(String publicKeyHex) =>
      '$contactPrefix$publicKeyHex';

  static String forChannel(int index) => '$channelPrefix$index';
}

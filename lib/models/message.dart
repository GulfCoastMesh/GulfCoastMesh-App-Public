import 'dart:typed_data';
import '../connector/meshcore_protocol.dart';
import '../helpers/reaction_helper.dart';

enum MessageStatus { pending, sent, delivered, failed }

class Message {
  final Uint8List senderKey;
  final String text;
  final DateTime timestamp;
  final bool isOutgoing;
  final bool isCli;
  final MessageStatus status;

  // NEW: Retry logic fields
  final String? messageId;
  final int retryCount;
  final int? estimatedTimeoutMs;
  final Uint8List? expectedAckHash;
  final DateTime? sentAt;
  final DateTime? deliveredAt;
  final int? tripTimeMs;
  final int? pathLength;
  final Uint8List pathBytes;
  final Map<String, int> reactions;

  /// Reactor identities grouped by emoji. This supplements [reactions] with
  /// enough information to avoid losing attribution when messages are
  /// persisted. Older records simply have no entries here.
  final Map<String, List<String>> reactionReactors;

  final Uint8List fourByteRoomContactKey;

  /// Whether this message's text was replaced by an `ed:` edit received
  /// over the mesh. See [EditHelper].
  final bool edited;
  final DateTime? editedAt;

  Message({
    required this.senderKey,
    required this.text,
    required this.timestamp,
    required this.isOutgoing,
    this.isCli = false,
    this.status = MessageStatus.pending,
    this.messageId,
    this.retryCount = 0,
    this.estimatedTimeoutMs,
    this.expectedAckHash,
    this.sentAt,
    this.deliveredAt,
    this.tripTimeMs,
    this.pathLength,
    Uint8List? pathBytes,
    Uint8List? fourByteRoomContactKey,
    Map<String, int>? reactions,
    Map<String, List<String>>? reactionReactors,
    this.edited = false,
    this.editedAt,
  }) : pathBytes = pathBytes ?? Uint8List(0),
       fourByteRoomContactKey = fourByteRoomContactKey ?? Uint8List(0),
       reactions = reactions ?? {},
       reactionReactors = reactionReactors ?? {};

  String get senderKeyHex => pubKeyToHex(senderKey);

  Message copyWith({
    String? text,
    MessageStatus? status,
    int? retryCount,
    int? estimatedTimeoutMs,
    Uint8List? expectedAckHash,
    DateTime? sentAt,
    DateTime? deliveredAt,
    int? tripTimeMs,
    int? pathLength,
    Uint8List? pathBytes,
    bool? isCli,
    Map<String, int>? reactions,
    Map<String, List<String>>? reactionReactors,
    Uint8List? fourByteRoomContactKey,
    bool? edited,
    DateTime? editedAt,
  }) {
    return Message(
      senderKey: senderKey,
      text: text ?? this.text,
      timestamp: timestamp,
      isOutgoing: isOutgoing,
      isCli: isCli ?? this.isCli,
      status: status ?? this.status,
      messageId: messageId,
      retryCount: retryCount ?? this.retryCount,
      estimatedTimeoutMs: estimatedTimeoutMs ?? this.estimatedTimeoutMs,
      expectedAckHash: expectedAckHash ?? this.expectedAckHash,
      sentAt: sentAt ?? this.sentAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      tripTimeMs: tripTimeMs ?? this.tripTimeMs,
      pathLength: pathLength ?? this.pathLength,
      pathBytes: pathBytes ?? this.pathBytes,
      reactions: reactions ?? this.reactions,
      reactionReactors: reactionReactors ?? this.reactionReactors,
      fourByteRoomContactKey:
          fourByteRoomContactKey ?? this.fourByteRoomContactKey,
      edited: edited ?? this.edited,
      editedAt: editedAt ?? this.editedAt,
    );
  }

  static Message? fromFrame(Uint8List data, Uint8List selfPubKey) {
    if (data.length < msgTextOffset + 1) return null;

    final code = data[0];
    if (code != respCodeContactMsgRecv && code != respCodeContactMsgRecvV3) {
      return null;
    }

    final senderKey = Uint8List.fromList(
      data.sublist(msgPubKeyOffset, msgPubKeyOffset + pubKeySize),
    );
    final timestampRaw = readUint32LE(data, msgTimestampOffset);
    final flags = data[msgFlagsOffset];
    if ((flags >> 2) != txtTypePlain) {
      return null;
    }
    final text = readCString(data, msgTextOffset, data.length - msgTextOffset);

    return Message(
      senderKey: senderKey,
      text: text,
      timestamp: DateTime.fromMillisecondsSinceEpoch(timestampRaw * 1000),
      isOutgoing: false,
      isCli: false,
      status: MessageStatus.delivered,
      pathBytes: Uint8List(0),
    );
  }

  static Message outgoing(
    Uint8List recipientKey,
    String text, {
    int? pathLength,
    Uint8List? pathBytes,
  }) {
    return Message(
      senderKey: recipientKey,
      text: text,
      timestamp: DateTime.now(),
      isOutgoing: true,
      isCli: false,
      status: MessageStatus.pending,
      pathLength: pathLength,
      pathBytes: pathBytes,
    );
  }

  static ReactionInfo? parseReaction(String text) {
    return ReactionHelper.parseReaction(text);
  }
}

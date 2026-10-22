import 'dart:typed_data';
import '../connector/meshcore_protocol.dart';
import '../helpers/reaction_helper.dart';
import '../helpers/smaz.dart';

enum ChannelMessageStatus { pending, sent, failed }

class Repeat {
  final Uint8List? repeaterKey;
  final String repeaterName;
  final int tripTimeMs;
  final List<Uint8List>? path;

  Repeat({
    this.repeaterKey,
    required this.repeaterName,
    required this.tripTimeMs,
    this.path,
  });

  String? get repeaterKeyHex =>
      repeaterKey != null ? pubKeyToHex(repeaterKey!) : null;
}

class ChannelMessage {
  final Uint8List? senderKey;
  final String senderName;
  final String text;
  final DateTime timestamp;
  final bool isOutgoing;
  final ChannelMessageStatus status;
  final List<Repeat> repeats;
  final int repeatCount;
  final int? pathLength;
  final Uint8List pathBytes;
  final List<Uint8List> pathVariants;
  final int? channelIndex;
  final String messageId;
  final String? replyToMessageId;
  final String? replyToSenderName;
  final String? replyToText;
  final Map<String, int> reactions;

  /// Reactor identities grouped by emoji; absent for pre-migration records.
  final Map<String, List<String>> reactionReactors;

  /// Whether this message's text was replaced by an `ed:` edit received
  /// over the mesh. See [EditHelper].
  final bool edited;
  final DateTime? editedAt;

  ChannelMessage({
    this.senderKey,
    required this.senderName,
    required this.text,
    required this.timestamp,
    required this.isOutgoing,
    this.status = ChannelMessageStatus.pending,
    this.repeats = const [],
    this.repeatCount = 0,
    this.pathLength,
    Uint8List? pathBytes,
    List<Uint8List>? pathVariants,
    this.channelIndex,
    String? messageId,
    this.replyToMessageId,
    this.replyToSenderName,
    this.replyToText,
    Map<String, int>? reactions,
    Map<String, List<String>>? reactionReactors,
    this.edited = false,
    this.editedAt,
  }) : messageId =
           messageId ??
           '${timestamp.millisecondsSinceEpoch}_${senderName.hashCode}_${text.hashCode}',
       reactions = reactions ?? {},
       reactionReactors = reactionReactors ?? {},
       pathBytes = pathBytes ?? Uint8List(0),
       pathVariants = _mergePathVariants(
         pathBytes ?? Uint8List(0),
         pathVariants,
       );

  String? get senderKeyHex =>
      senderKey != null ? pubKeyToHex(senderKey!) : null;

  ChannelMessage copyWith({
    String? text,
    ChannelMessageStatus? status,
    List<Repeat>? repeats,
    int? repeatCount,
    int? pathLength,
    Uint8List? pathBytes,
    List<Uint8List>? pathVariants,
    String? replyToMessageId,
    String? replyToSenderName,
    String? replyToText,
    Map<String, int>? reactions,
    Map<String, List<String>>? reactionReactors,
    bool? edited,
    DateTime? editedAt,
  }) {
    return ChannelMessage(
      senderKey: senderKey,
      senderName: senderName,
      text: text ?? this.text,
      timestamp: timestamp,
      isOutgoing: isOutgoing,
      status: status ?? this.status,
      repeats: repeats ?? this.repeats,
      repeatCount: repeatCount ?? this.repeatCount,
      pathLength: pathLength ?? this.pathLength,
      pathBytes: pathBytes ?? this.pathBytes,
      pathVariants: pathVariants ?? this.pathVariants,
      channelIndex: channelIndex,
      messageId: messageId,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      replyToSenderName: replyToSenderName ?? this.replyToSenderName,
      replyToText: replyToText ?? this.replyToText,
      reactions: reactions ?? this.reactions,
      reactionReactors: reactionReactors ?? this.reactionReactors,
      edited: edited ?? this.edited,
      editedAt: editedAt ?? this.editedAt,
    );
  }

  static ChannelMessage? fromFrame(
    Uint8List data, {
    int fallbackHashSizeBytes = 1,
  }) {
    // CHANNEL_MSG_RECV format varies by version:
    // V3: [0]=code [1]=SNR [2]=rsv1 [3]=rsv2 [4]=channel_idx [5]=path_len [path... optional] [txt_type] [timestamp x4] [text...]
    // Non-V3: [0]=code [1]=channel_idx [2]=path_len [3]=txt_type [4-7]=timestamp [8+]=text
    if (data.length < 8) return null;

    final code = data[0];
    if (code != respCodeChannelMsgRecv && code != respCodeChannelMsgRecvV3) {
      return null;
    }

    int timestampOffset, textOffset, pathLenOffset, txtTypeOffset;
    Uint8List pathBytes = Uint8List(0);
    int channelIdx;

    if (code == respCodeChannelMsgRecvV3) {
      channelIdx = data[4];
      pathLenOffset = 5;
      final pathLenByte = data[pathLenOffset];
      final parsed = parsePathLengthField(
        pathLenByte,
        fallbackHashSizeBytes: fallbackHashSizeBytes,
      );
      var cursor = 6;
      final pathByteLen = parsed.pathByteLength;
      final hasPathBytesFlag = (data[2] & 0x01) != 0;
      final canFitPath =
          pathByteLen > 0 && data.length >= cursor + pathByteLen + 5;
      final hasValidTxtType =
          cursor < data.length &&
          (data[cursor] == txtTypePlain || data[cursor] == txtTypeCliData);
      if ((hasPathBytesFlag || (canFitPath && !hasValidTxtType)) &&
          canFitPath) {
        pathBytes = Uint8List.fromList(
          data.sublist(cursor, cursor + pathByteLen),
        );
        cursor += pathByteLen;
      }
      txtTypeOffset = cursor;
      cursor += 1; // txt_type
      timestampOffset = cursor;
      textOffset = cursor + 4;
    } else {
      channelIdx = data[1];
      pathLenOffset = 2;
      txtTypeOffset = 3;
      timestampOffset = 4;
      textOffset = 8;
    }

    if (data.length < textOffset + 1) return null;

    final txtType = data[txtTypeOffset];
    if (txtType != txtTypePlain) {
      return null;
    }

    final pathLenByte = data[pathLenOffset];
    final parsedPath = parsePathLengthField(
      pathLenByte,
      fallbackHashSizeBytes: fallbackHashSizeBytes,
    );
    final timestampRaw = readUint32LE(data, timestampOffset);
    final text = readCString(data, textOffset, data.length - textOffset);

    // Extract sender name and actual message from "name: msg" format
    String senderName = 'Unknown';
    String actualText = text;

    final colonIndex = text.indexOf(':');
    if (colonIndex > 0 && colonIndex < text.length - 1 && colonIndex < 50) {
      final potentialSender = text.substring(0, colonIndex);
      if (!RegExp(r'[:\[\]]').hasMatch(potentialSender)) {
        senderName = potentialSender;
        final offset =
            (colonIndex + 1 < text.length && text[colonIndex + 1] == ' ')
            ? colonIndex + 2
            : colonIndex + 1;
        actualText = text.substring(offset);
      }
    }

    final decodedText = Smaz.tryDecodePrefixed(actualText) ?? actualText;

    return ChannelMessage(
      senderKey: null,
      senderName: senderName,
      text: decodedText,
      timestamp: DateTime.fromMillisecondsSinceEpoch(timestampRaw * 1000),
      isOutgoing: false,
      status: ChannelMessageStatus.sent,
      pathLength: pathLenByte == 0xFF ? 0 : parsedPath.hopCount,
      pathBytes: pathBytes,
      channelIndex: channelIdx,
    );
  }

  static ChannelMessage outgoing(
    String text,
    String senderName,
    int channelIndex,
  ) {
    return ChannelMessage(
      senderKey: null,
      senderName: senderName,
      text: text,
      timestamp: DateTime.now(),
      isOutgoing: true,
      status: ChannelMessageStatus.pending,
      pathLength: null,
      pathBytes: Uint8List(0),
      pathVariants: const [],
      channelIndex: channelIndex,
    );
  }

  static List<Uint8List> _mergePathVariants(
    Uint8List pathBytes,
    List<Uint8List>? pathVariants,
  ) {
    final merged = <Uint8List>[];

    void addPath(Uint8List bytes) {
      if (bytes.isEmpty) return;
      for (final existing in merged) {
        if (_pathsEqual(existing, bytes)) return;
      }
      merged.add(bytes);
    }

    if (pathVariants != null) {
      for (final variant in pathVariants) {
        addPath(variant);
      }
    }
    addPath(pathBytes);
    return merged;
  }

  static bool _pathsEqual(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static ReplyInfo? parseReplyMention(String text) {
    final regex = RegExp(r'^@\[([^\]]+)\]\s+(.+)$', dotAll: true);
    final match = regex.firstMatch(text);
    if (match == null) return null;
    return ReplyInfo(
      mentionedNode: match.group(1)!,
      actualMessage: match.group(2)!,
    );
  }

  static ReactionInfo? parseReaction(String text) {
    return ReactionHelper.parseReaction(text);
  }
}

class ReplyInfo {
  final String mentionedNode;
  final String actualMessage;

  ReplyInfo({required this.mentionedNode, required this.actualMessage});
}

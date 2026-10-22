import 'dart:convert';
import 'dart:typed_data';
import '../models/message.dart';
import '../helpers/smaz.dart';
import 'prefs_manager.dart';

class MessageStore {
  static const String _keyPrefix = 'messages_';

  Future<void> saveMessages(
    String contactKeyHex,
    List<Message> messages,
  ) async {
    final prefs = PrefsManager.instance;
    final key = '$_keyPrefix$contactKeyHex';
    final jsonList = messages.map(_messageToJson).toList();
    await prefs.setString(key, jsonEncode(jsonList));
  }

  Future<List<Message>> loadMessages(String contactKeyHex) async {
    final prefs = PrefsManager.instance;
    final key = '$_keyPrefix$contactKeyHex';
    final jsonString = prefs.getString(key);
    if (jsonString == null) return [];

    final List<dynamic> jsonList;
    try {
      jsonList = jsonDecode(jsonString) as List<dynamic>;
    } catch (_) {
      return [];
    }

    final messages = <Message>[];
    for (final entry in jsonList) {
      try {
        messages.add(_messageFromJson(entry as Map<String, dynamic>));
      } catch (e) {
        // Skip the bad record; preserve the rest.
        continue;
      }
    }
    return messages;
  }

  Future<void> clearMessages(String contactKeyHex) async {
    final prefs = PrefsManager.instance;
    final key = '$_keyPrefix$contactKeyHex';
    await prefs.remove(key);
  }

  Map<String, dynamic> _messageToJson(Message msg) {
    return {
      'senderKey': base64Encode(msg.senderKey),
      'text': msg.text,
      'timestamp': msg.timestamp.millisecondsSinceEpoch,
      'isOutgoing': msg.isOutgoing,
      'isCli': msg.isCli,
      'status': msg.status.index,
      'messageId': msg.messageId,
      'retryCount': msg.retryCount,
      'estimatedTimeoutMs': msg.estimatedTimeoutMs,
      'expectedAckHash': msg.expectedAckHash != null
          ? base64Encode(msg.expectedAckHash!)
          : null,
      'sentAt': msg.sentAt?.millisecondsSinceEpoch,
      'deliveredAt': msg.deliveredAt?.millisecondsSinceEpoch,
      'tripTimeMs': msg.tripTimeMs,
      'pathLength': msg.pathLength,
      'pathBytes': msg.pathBytes.isNotEmpty
          ? base64Encode(msg.pathBytes)
          : null,
      'reactions': msg.reactions,
      'reactionReactors': msg.reactionReactors,
      'fourByteRoomContactKey': base64Encode(msg.fourByteRoomContactKey),
      'edited': msg.edited,
      'editedAt': msg.editedAt?.millisecondsSinceEpoch,
    };
  }

  Message _messageFromJson(Map<String, dynamic> json) {
    final rawText = json['text'] as String;
    final isCli = json['isCli'] as bool? ?? false;
    final decodedText = isCli
        ? rawText
        : (Smaz.tryDecodePrefixed(rawText) ?? rawText);
    return Message(
      senderKey: Uint8List.fromList(base64Decode(json['senderKey'] as String)),
      text: decodedText,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      isOutgoing: json['isOutgoing'] as bool,
      isCli: isCli,
      status: MessageStatus.values[json['status'] as int],
      messageId: json['messageId'] as String?,
      retryCount: json['retryCount'] as int? ?? 0,
      estimatedTimeoutMs: json['estimatedTimeoutMs'] as int?,
      expectedAckHash: json['expectedAckHash'] != null
          ? Uint8List.fromList(base64Decode(json['expectedAckHash'] as String))
          : null,
      sentAt: json['sentAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['sentAt'] as int)
          : null,
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['deliveredAt'] as int)
          : null,
      tripTimeMs: json['tripTimeMs'] as int?,
      pathLength: json['pathLength'] as int?,
      pathBytes: json['pathBytes'] != null
          ? Uint8List.fromList(base64Decode(json['pathBytes'] as String))
          : Uint8List(0),
      reactions:
          (json['reactions'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, (value as num).toInt()),
          ) ??
          {},
      reactionReactors: _reactionReactorsFromJson(json['reactionReactors']),
      fourByteRoomContactKey: json['fourByteRoomContactKey'] != null
          ? Uint8List.fromList(
              base64Decode(json['fourByteRoomContactKey'] as String),
            )
          : null,
      edited: json['edited'] as bool? ?? false,
      editedAt: json['editedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['editedAt'] as int)
          : null,
    );
  }

  Map<String, List<String>> _reactionReactorsFromJson(dynamic raw) {
    if (raw is! Map) return {};
    final result = <String, List<String>>{};
    raw.forEach((key, value) {
      if (value is List) {
        result[key.toString()] = value
            .map((entry) => entry.toString())
            .toList();
      }
    });
    return result;
  }
}

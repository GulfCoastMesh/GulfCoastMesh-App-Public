import 'dart:convert';
import 'dart:typed_data';
import '../models/channel_message.dart';
import '../helpers/smaz.dart';
import 'prefs_manager.dart';

class ChannelMessageStore {
  static const String _keyPrefix = 'channel_messages_';

  /// Save messages for a specific channel
  Future<void> saveChannelMessages(
    int channelIndex,
    List<ChannelMessage> messages,
  ) async {
    final prefs = PrefsManager.instance;
    final key = '$_keyPrefix$channelIndex';

    // Convert messages to JSON
    final jsonList = messages.map((msg) => _messageToJson(msg)).toList();
    final jsonString = jsonEncode(jsonList);

    await prefs.setString(key, jsonString);
  }

  /// Load messages for a specific channel
  Future<List<ChannelMessage>> loadChannelMessages(int channelIndex) async {
    final prefs = PrefsManager.instance;
    final key = '$_keyPrefix$channelIndex';

    final jsonString = prefs.getString(key);
    if (jsonString == null) return [];

    final List<dynamic> jsonList;
    try {
      jsonList = jsonDecode(jsonString) as List<dynamic>;
    } catch (_) {
      return [];
    }

    final messages = <ChannelMessage>[];
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

  /// Clear messages for a specific channel
  Future<void> clearChannelMessages(int channelIndex) async {
    final prefs = PrefsManager.instance;
    final key = '$_keyPrefix$channelIndex';
    await prefs.remove(key);
  }

  /// Clear all channel messages
  Future<void> clearAllChannelMessages() async {
    final prefs = PrefsManager.instance;
    final keys = prefs.getKeys().where((k) => k.startsWith(_keyPrefix));
    for (var key in keys) {
      await prefs.remove(key);
    }
  }

  /// Convert ChannelMessage to JSON map
  Map<String, dynamic> _messageToJson(ChannelMessage msg) {
    return {
      'senderKey': msg.senderKey != null ? base64Encode(msg.senderKey!) : null,
      'senderName': msg.senderName,
      'text': msg.text,
      'timestamp': msg.timestamp.millisecondsSinceEpoch,
      'isOutgoing': msg.isOutgoing,
      'status': msg.status.index,
      'channelIndex': msg.channelIndex,
      'repeatCount': msg.repeatCount,
      'pathLength': msg.pathLength,
      'pathBytes': base64Encode(msg.pathBytes),
      'pathVariants': msg.pathVariants.map(base64Encode).toList(),
      'repeats': msg.repeats.map(_repeatToJson).toList(),
      'messageId': msg.messageId,
      'replyToMessageId': msg.replyToMessageId,
      'replyToSenderName': msg.replyToSenderName,
      'replyToText': msg.replyToText,
      'reactions': msg.reactions,
      'reactionReactors': msg.reactionReactors,
      'edited': msg.edited,
      'editedAt': msg.editedAt?.millisecondsSinceEpoch,
    };
  }

  /// Convert JSON map to ChannelMessage
  ChannelMessage _messageFromJson(Map<String, dynamic> json) {
    final rawText = json['text'] as String;
    final decodedText = Smaz.tryDecodePrefixed(rawText) ?? rawText;
    return ChannelMessage(
      senderKey: json['senderKey'] != null
          ? Uint8List.fromList(base64Decode(json['senderKey']))
          : null,
      senderName: json['senderName'] as String,
      text: decodedText,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      isOutgoing: json['isOutgoing'] as bool,
      status: ChannelMessageStatus.values[json['status'] as int],
      repeatCount: (json['repeatCount'] as int?) ?? 0,
      pathLength: json['pathLength'] as int?,
      pathBytes: json['pathBytes'] != null
          ? Uint8List.fromList(base64Decode(json['pathBytes'] as String))
          : Uint8List(0),
      pathVariants: (json['pathVariants'] as List<dynamic>?)
          ?.map((entry) => Uint8List.fromList(base64Decode(entry as String)))
          .toList(),
      repeats:
          (json['repeats'] as List<dynamic>?)
              ?.map((entry) => _repeatFromJson(entry as Map<String, dynamic>))
              .toList() ??
          const [],
      channelIndex: json['channelIndex'] as int?,
      messageId: json['messageId'] as String?,
      replyToMessageId: json['replyToMessageId'] as String?,
      replyToSenderName: json['replyToSenderName'] as String?,
      replyToText: json['replyToText'] as String?,
      reactions:
          (json['reactions'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, (value as num).toInt()),
          ) ??
          {},
      reactionReactors: _reactionReactorsFromJson(json['reactionReactors']),
      edited: json['edited'] as bool? ?? false,
      editedAt: json['editedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['editedAt'] as int)
          : null,
    );
  }

  Map<String, dynamic> _repeatToJson(Repeat repeat) {
    return {
      'repeaterKey': repeat.repeaterKey != null
          ? base64Encode(repeat.repeaterKey!)
          : null,
      'repeaterName': repeat.repeaterName,
      'tripTimeMs': repeat.tripTimeMs,
      'path': repeat.path?.map((bytes) => base64Encode(bytes)).toList() ?? [],
    };
  }

  Repeat _repeatFromJson(Map<String, dynamic> json) {
    return Repeat(
      repeaterKey: json['repeaterKey'] != null
          ? Uint8List.fromList(base64Decode(json['repeaterKey']))
          : null,
      repeaterName: json['repeaterName'] as String? ?? 'Unknown',
      tripTimeMs: json['tripTimeMs'] as int? ?? 0,
      path: (json['path'] as List<dynamic>?)
          ?.map((entry) => Uint8List.fromList(base64Decode(entry as String)))
          .toList(),
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

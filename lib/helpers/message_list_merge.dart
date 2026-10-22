import '../models/channel_message.dart';
import '../models/message.dart';

String _dmMergeKey(Message message) {
  final id = message.messageId;
  if (id != null && id.isNotEmpty) return id;
  // No disk/live prefix: the same logical message must collide across sources.
  return '${message.timestamp.millisecondsSinceEpoch}_'
      '${message.isOutgoing}_${message.text.hashCode}';
}

/// Merge disk-backed DM history with any live in-memory messages.
///
/// Live entries win on matching ids (fresher status). Result is sorted by
/// timestamp ascending.
List<Message> mergeConversationMessages(
  List<Message> disk,
  List<Message> live,
) {
  final byId = <String, Message>{};
  for (final message in disk) {
    byId[_dmMergeKey(message)] = message;
  }
  for (final message in live) {
    byId[_dmMergeKey(message)] = message;
  }
  final merged = byId.values.toList()
    ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  return merged;
}

String _channelMergeKey(ChannelMessage message) {
  if (message.messageId.isNotEmpty) return message.messageId;
  return '${message.timestamp.millisecondsSinceEpoch}_'
      '${message.senderName}_${message.text.hashCode}';
}

/// Merge disk-backed channel history with any live in-memory messages.
List<ChannelMessage> mergeChannelMessages(
  List<ChannelMessage> disk,
  List<ChannelMessage> live,
) {
  final byId = <String, ChannelMessage>{};
  for (final message in disk) {
    byId[_channelMergeKey(message)] = message;
  }
  for (final message in live) {
    byId[_channelMergeKey(message)] = message;
  }
  final merged = byId.values.toList()
    ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  return merged;
}

List<T> windowNewest<T>(List<T> messages, int windowSize) {
  if (messages.length <= windowSize) return messages;
  return messages.sublist(messages.length - windowSize);
}

/// The next page of older history to prepend, given the [all] persisted list
/// and how many of its newest entries are already in memory.
///
/// Returns an empty list when the window already covers everything on disk, so
/// a paginating screen can stop asking. Never returns more than [count], and
/// never reaches past the start of [all].
List<T> olderMessagePage<T>(
  List<T> all,
  int loadedCount, {
  required int count,
}) {
  final currentOffset = all.length - loadedCount;
  if (currentOffset <= 0 || count <= 0) return const [];
  final fetchCount = count.clamp(0, currentOffset);
  return all.sublist(currentOffset - fetchCount, currentOffset);
}

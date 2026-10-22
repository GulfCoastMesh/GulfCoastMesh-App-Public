import '../models/channel.dart';

/// Returns the first unused device channel index, or `null` when full.
int? firstAvailableChannelIndex(List<Channel> channels, int maxChannels) {
  final usedIndices = channels.map((channel) => channel.index).toSet();
  for (var index = 0; index < maxChannels; index++) {
    if (!usedIndices.contains(index)) return index;
  }
  return null;
}

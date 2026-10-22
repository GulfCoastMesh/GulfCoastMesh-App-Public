import '../connector/meshcore_connector.dart';
import '../models/channel.dart';
import 'channel_slot_helper.dart';

const String atakChannelDisplayName = '#atak';

String normalizeHashtagChannelName(String input) {
  var name = input.trim();
  if (name.startsWith('#')) {
    name = name.substring(1);
  }
  name = name.toLowerCase();
  if (name.isEmpty) return '';
  return '#$name';
}

String normalizeHashtagTag(String input) {
  var name = input.trim();
  if (name.startsWith('#')) {
    name = name.substring(1);
  }
  return name.toLowerCase();
}

bool isAtakChannelName(String name) {
  return normalizeHashtagTag(name) == 'atak';
}

bool isAtakEligibleChannel(Channel channel) {
  return !channel.isEmpty && !channel.isPublicChannel;
}

Channel? findHashtagChannel(List<Channel> channels, String hashtag) {
  final normalized = normalizeHashtagChannelName(hashtag);
  if (normalized.isEmpty) return null;

  for (final channel in channels) {
    if (channel.isEmpty) continue;
    if (normalizeHashtagChannelName(channel.name) == normalized) {
      return channel;
    }
  }
  return null;
}

Channel? findAtakChannel(List<Channel> channels) {
  return findHashtagChannel(channels, 'atak');
}

Channel? resolveSelectedChannel(
  List<Channel> channels, {
  int? index,
  required String name,
}) {
  if (index != null) {
    for (final channel in channels) {
      if (channel.index == index && !channel.isEmpty) {
        if (name.isEmpty || channel.name == name) {
          return channel;
        }
      }
    }
  }

  if (name.isNotEmpty) {
    for (final channel in channels) {
      if (!channel.isEmpty && channel.name == name) {
        return channel;
      }
    }
  }

  return null;
}

Channel? resolveAtakChannel(
  List<Channel> channels, {
  int? index,
  required String name,
}) {
  final channel = resolveSelectedChannel(channels, index: index, name: name);
  if (channel == null || !isAtakEligibleChannel(channel)) {
    return null;
  }
  return channel;
}

Future<Channel?> joinHashtagChannel(
  MeshCoreConnector connector,
  String hashtag,
) async {
  if (!connector.isConnected) return null;

  final displayName = normalizeHashtagChannelName(hashtag);
  if (displayName.isEmpty) return null;

  final existing = findHashtagChannel(connector.channels, hashtag);
  if (existing != null && isAtakEligibleChannel(existing)) {
    return existing;
  }

  final tag = normalizeHashtagTag(hashtag);
  final nextIndex = firstAvailableChannelIndex(
    connector.channels,
    connector.maxChannels,
  );
  if (nextIndex == null) return null;
  final psk = Channel.derivePskFromHashtag(tag);
  await connector.setChannel(nextIndex, displayName, psk);

  return findHashtagChannel(connector.channels, hashtag) ??
      resolveSelectedChannel(
        connector.channels,
        index: nextIndex,
        name: displayName,
      );
}

Future<Channel?> joinAtakChannel(MeshCoreConnector connector) async {
  return joinHashtagChannel(connector, 'atak');
}

bool isStoredPublicAtakSelection(String name) {
  return name == 'Public';
}

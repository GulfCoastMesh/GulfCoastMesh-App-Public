import '../models/channel_message.dart';
import 'tactical_map_payload.dart';

class AtakParticipant {
  final String id;
  final String messageId;
  final double lat;
  final double lon;
  final String name;
  final String senderName;
  final String channelLabel;
  final int timestampSeconds;

  const AtakParticipant({
    required this.id,
    required this.messageId,
    required this.lat,
    required this.lon,
    required this.name,
    required this.senderName,
    required this.channelLabel,
    required this.timestampSeconds,
  });
}

class AtakPoi {
  final String id;
  final String messageId;
  final double lat;
  final double lon;
  final String label;
  final String type;
  final String senderName;
  final String channelLabel;
  final int timestampSeconds;

  const AtakPoi({
    required this.id,
    required this.messageId,
    required this.lat,
    required this.lon,
    required this.label,
    required this.type,
    required this.senderName,
    required this.channelLabel,
    required this.timestampSeconds,
  });
}

String buildAtakParticipantId({
  required int channelIndex,
  required String senderName,
}) {
  return 'atak:pos:$channelIndex:$senderName';
}

String buildAtakPoiId({required int channelIndex, required String messageId}) {
  return 'atak:poi:$channelIndex:$messageId';
}

bool _isNewerParticipant(
  AtakParticipant candidate,
  AtakParticipant existing,
  DateTime candidateMessageTime,
  DateTime existingMessageTime,
) {
  if (candidate.timestampSeconds != existing.timestampSeconds) {
    return candidate.timestampSeconds > existing.timestampSeconds;
  }
  if (candidateMessageTime != existingMessageTime) {
    return candidateMessageTime.isAfter(existingMessageTime);
  }
  return candidate.messageId.compareTo(existing.messageId) > 0;
}

List<AtakParticipant> collectAtakParticipants(
  List<ChannelMessage> messages, {
  required String channelLabel,
  required int channelIndex,
}) {
  final latestBySender = <String, AtakParticipant>{};
  final messageTimes = <String, DateTime>{};
  final seenMessageIds = <String>{};

  for (final message in messages) {
    if (seenMessageIds.contains(message.messageId)) continue;

    final tactical = TacticalMapPayload.tryParse(message.text);
    if (tactical is! TacticalPositionUpdate) continue;

    seenMessageIds.add(message.messageId);

    final senderName = message.senderName;
    final candidate = AtakParticipant(
      id: buildAtakParticipantId(
        channelIndex: channelIndex,
        senderName: senderName,
      ),
      messageId: message.messageId,
      lat: tactical.lat,
      lon: tactical.lon,
      name: tactical.name,
      senderName: senderName,
      channelLabel: channelLabel,
      timestampSeconds: tactical.timestampSeconds,
    );

    final existing = latestBySender[senderName];
    if (existing == null ||
        _isNewerParticipant(
          candidate,
          existing,
          message.timestamp,
          messageTimes[senderName]!,
        )) {
      latestBySender[senderName] = candidate;
      messageTimes[senderName] = message.timestamp;
    }
  }

  return latestBySender.values.toList();
}

List<AtakPoi> collectAtakPois(
  List<ChannelMessage> messages, {
  required String channelLabel,
  required int channelIndex,
}) {
  final pois = <AtakPoi>[];
  final seenMessageIds = <String>{};

  for (final message in messages) {
    if (seenMessageIds.contains(message.messageId)) continue;

    final tactical = TacticalMapPayload.tryParse(message.text);
    if (tactical is! TacticalPoiMarker) continue;

    seenMessageIds.add(message.messageId);

    pois.add(
      AtakPoi(
        id: buildAtakPoiId(
          channelIndex: channelIndex,
          messageId: message.messageId,
        ),
        messageId: message.messageId,
        lat: tactical.lat,
        lon: tactical.lon,
        label: tactical.label,
        type: tactical.type,
        senderName: message.senderName,
        channelLabel: channelLabel,
        timestampSeconds: tactical.timestampSeconds,
      ),
    );
  }

  return pois;
}

List<T> filterDismissedAtakMarkers<T>(
  List<T> markers,
  Set<String> hiddenIds,
  Set<String> removedIds, {
  required String Function(T) idFor,
}) {
  return markers
      .where(
        (marker) =>
            !hiddenIds.contains(idFor(marker)) &&
            !removedIds.contains(idFor(marker)),
      )
      .toList();
}

const Duration atakFreshThreshold = Duration(minutes: 15);
const Duration atakModerateStaleThreshold = Duration(minutes: 60);

double atakMarkerOpacity(
  int timestampSeconds, {
  required bool isParticipant,
  DateTime? now,
}) {
  if (!isParticipant) {
    return 1.0;
  }

  final reference = now ?? DateTime.now();
  final age = reference.difference(
    DateTime.fromMillisecondsSinceEpoch(timestampSeconds * 1000),
  );

  if (age <= atakFreshThreshold) {
    return 1.0;
  }
  if (age <= atakModerateStaleThreshold) {
    return 0.65;
  }
  return 0.4;
}

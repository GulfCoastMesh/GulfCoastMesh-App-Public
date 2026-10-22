import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/helpers/atak_map_markers.dart';
import 'package:gulf_coast_mesh_app/helpers/tactical_map_payload.dart';
import 'package:gulf_coast_mesh_app/models/channel_message.dart';

ChannelMessage _message({
  required String text,
  required String senderName,
  required DateTime timestamp,
  String? messageId,
}) {
  return ChannelMessage(
    senderName: senderName,
    text: text,
    timestamp: timestamp,
    isOutgoing: false,
    channelIndex: 2,
    messageId: messageId,
  );
}

void main() {
  group('collectAtakParticipants', () {
    test('parses position updates from channel messages', () {
      final text = TacticalMapPayload.formatPosition(
        lat: 37.7749,
        lon: -122.4194,
        timestampSeconds: 1717603200,
        name: 'Alpha-1',
      );
      final messages = [
        _message(
          text: text,
          senderName: 'Bravo',
          timestamp: DateTime.fromMillisecondsSinceEpoch(1717603200000),
        ),
      ];

      final participants = collectAtakParticipants(
        messages,
        channelLabel: '#atak',
        channelIndex: 2,
      );

      expect(participants, hasLength(1));
      expect(participants.first.name, 'Alpha-1');
      expect(participants.first.senderName, 'Bravo');
      expect(participants.first.channelLabel, '#atak');
      expect(participants.first.timestampSeconds, 1717603200);
      expect(participants.first.id, 'atak:pos:2:Bravo');
    });

    test('keeps newer message when payload timestamps tie', () {
      final first = TacticalMapPayload.formatPosition(
        lat: 1.0,
        lon: 2.0,
        timestampSeconds: 100,
        name: 'First',
      );
      final second = TacticalMapPayload.formatPosition(
        lat: 3.0,
        lon: 4.0,
        timestampSeconds: 100,
        name: 'Second',
      );
      final messages = [
        _message(
          text: first,
          senderName: 'Alpha',
          timestamp: DateTime.fromMillisecondsSinceEpoch(100000),
          messageId: 'msg-a',
        ),
        _message(
          text: second,
          senderName: 'Alpha',
          timestamp: DateTime.fromMillisecondsSinceEpoch(200000),
          messageId: 'msg-b',
        ),
      ];

      final participants = collectAtakParticipants(
        messages,
        channelLabel: '#atak',
        channelIndex: 2,
      );

      expect(participants, hasLength(1));
      expect(participants.first.name, 'Second');
      expect(participants.first.messageId, 'msg-b');
    });

    test('ignores duplicate message ids', () {
      final text = TacticalMapPayload.formatPosition(
        lat: 1.0,
        lon: 2.0,
        timestampSeconds: 100,
        name: 'Alpha',
      );
      final messages = [
        _message(
          text: text,
          senderName: 'Alpha',
          timestamp: DateTime.fromMillisecondsSinceEpoch(100000),
          messageId: 'dup-id',
        ),
        _message(
          text: text,
          senderName: 'Alpha',
          timestamp: DateTime.fromMillisecondsSinceEpoch(200000),
          messageId: 'dup-id',
        ),
      ];

      final participants = collectAtakParticipants(
        messages,
        channelLabel: '#atak',
        channelIndex: 2,
      );

      expect(participants, hasLength(1));
    });

    test('keeps latest position per sender', () {
      final older = TacticalMapPayload.formatPosition(
        lat: 1.0,
        lon: 2.0,
        timestampSeconds: 100,
        name: 'Old',
      );
      final newer = TacticalMapPayload.formatPosition(
        lat: 3.0,
        lon: 4.0,
        timestampSeconds: 200,
        name: 'New',
      );
      final messages = [
        _message(
          text: older,
          senderName: 'Alpha',
          timestamp: DateTime.fromMillisecondsSinceEpoch(100000),
        ),
        _message(
          text: newer,
          senderName: 'Alpha',
          timestamp: DateTime.fromMillisecondsSinceEpoch(200000),
        ),
      ];

      final participants = collectAtakParticipants(
        messages,
        channelLabel: '#atak',
        channelIndex: 2,
      );

      expect(participants, hasLength(1));
      expect(participants.first.name, 'New');
      expect(participants.first.lat, closeTo(3.0, 0.000001));
    });

    test('tracks multiple senders separately', () {
      final alpha = TacticalMapPayload.formatPosition(
        lat: 1.0,
        lon: 2.0,
        timestampSeconds: 100,
        name: 'Alpha',
      );
      final bravo = TacticalMapPayload.formatPosition(
        lat: 3.0,
        lon: 4.0,
        timestampSeconds: 100,
        name: 'Bravo',
      );
      final messages = [
        _message(
          text: alpha,
          senderName: 'SenderA',
          timestamp: DateTime.fromMillisecondsSinceEpoch(100000),
        ),
        _message(
          text: bravo,
          senderName: 'SenderB',
          timestamp: DateTime.fromMillisecondsSinceEpoch(100000),
        ),
      ];

      final participants = collectAtakParticipants(
        messages,
        channelLabel: '#atak',
        channelIndex: 2,
      );

      expect(participants, hasLength(2));
      expect(participants.map((p) => p.name), containsAll(['Alpha', 'Bravo']));
    });

    test('ignores poi messages', () {
      final poi = TacticalMapPayload.formatPoi(
        lat: 1.0,
        lon: 2.0,
        timestampSeconds: 100,
        label: 'LZ',
        type: 'wp',
      );
      final messages = [
        _message(
          text: poi,
          senderName: 'Alpha',
          timestamp: DateTime.fromMillisecondsSinceEpoch(100000),
        ),
      ];

      final participants = collectAtakParticipants(
        messages,
        channelLabel: '#atak',
        channelIndex: 2,
      );

      expect(participants, isEmpty);
    });
  });

  group('collectAtakPois', () {
    test('parses poi messages', () {
      final text = TacticalMapPayload.formatPoi(
        lat: 37.7749,
        lon: -122.4194,
        timestampSeconds: 1717603200,
        label: 'LZ North',
        type: 'wp',
      );
      final messages = [
        _message(
          text: text,
          senderName: 'Bravo',
          timestamp: DateTime.fromMillisecondsSinceEpoch(1717603200000),
        ),
      ];

      final pois = collectAtakPois(
        messages,
        channelLabel: '#atak',
        channelIndex: 2,
      );

      expect(pois, hasLength(1));
      expect(pois.first.label, 'LZ North');
      expect(pois.first.type, 'wp');
      expect(pois.first.senderName, 'Bravo');
      expect(pois.first.id, 'atak:poi:2:${pois.first.messageId}');
    });

    test('deduplicates poi messages by message id', () {
      final text = TacticalMapPayload.formatPoi(
        lat: 1.0,
        lon: 2.0,
        timestampSeconds: 100,
        label: 'LZ',
        type: 'wp',
      );
      final messages = [
        _message(
          text: text,
          senderName: 'Alpha',
          timestamp: DateTime.fromMillisecondsSinceEpoch(100000),
          messageId: 'poi-dup',
        ),
        _message(
          text: text,
          senderName: 'Alpha',
          timestamp: DateTime.fromMillisecondsSinceEpoch(200000),
          messageId: 'poi-dup',
        ),
      ];

      final pois = collectAtakPois(
        messages,
        channelLabel: '#atak',
        channelIndex: 2,
      );

      expect(pois, hasLength(1));
    });

    test('returns one marker per poi message', () {
      final first = TacticalMapPayload.formatPoi(
        lat: 1.0,
        lon: 2.0,
        timestampSeconds: 100,
        label: 'A',
        type: 'poi',
      );
      final second = TacticalMapPayload.formatPoi(
        lat: 3.0,
        lon: 4.0,
        timestampSeconds: 200,
        label: 'B',
        type: 'tgt',
      );
      final messages = [
        _message(
          text: first,
          senderName: 'Alpha',
          timestamp: DateTime.fromMillisecondsSinceEpoch(100000),
        ),
        _message(
          text: second,
          senderName: 'Alpha',
          timestamp: DateTime.fromMillisecondsSinceEpoch(200000),
        ),
      ];

      final pois = collectAtakPois(
        messages,
        channelLabel: '#atak',
        channelIndex: 2,
      );

      expect(pois, hasLength(2));
      expect(pois.map((p) => p.label), containsAll(['A', 'B']));
    });

    test('ignores position updates', () {
      final text = TacticalMapPayload.formatPosition(
        lat: 1.0,
        lon: 2.0,
        timestampSeconds: 100,
        name: 'Alpha',
      );
      final messages = [
        _message(
          text: text,
          senderName: 'Alpha',
          timestamp: DateTime.fromMillisecondsSinceEpoch(100000),
        ),
      ];

      final pois = collectAtakPois(
        messages,
        channelLabel: '#atak',
        channelIndex: 2,
      );

      expect(pois, isEmpty);
    });
  });

  group('filterDismissedAtakMarkers', () {
    test('excludes hidden and removed marker ids', () {
      const visible = AtakParticipant(
        id: 'atak:pos:2:Alpha',
        messageId: 'msg-1',
        lat: 1,
        lon: 2,
        name: 'Alpha',
        senderName: 'Alpha',
        channelLabel: '#atak',
        timestampSeconds: 100,
      );
      const hidden = AtakParticipant(
        id: 'atak:pos:2:Bravo',
        messageId: 'msg-2',
        lat: 3,
        lon: 4,
        name: 'Bravo',
        senderName: 'Bravo',
        channelLabel: '#atak',
        timestampSeconds: 100,
      );
      const removed = AtakParticipant(
        id: 'atak:pos:2:Charlie',
        messageId: 'msg-3',
        lat: 5,
        lon: 6,
        name: 'Charlie',
        senderName: 'Charlie',
        channelLabel: '#atak',
        timestampSeconds: 100,
      );

      final filtered = filterDismissedAtakMarkers(
        [visible, hidden, removed],
        {'atak:pos:2:Bravo'},
        {'atak:pos:2:Charlie'},
        idFor: (participant) => participant.id,
      );

      expect(filtered, [visible]);
    });
  });

  group('atakMarkerOpacity', () {
    test('returns tiered opacity for participant positions', () {
      final now = DateTime(2025, 1, 1, 12, 0);

      expect(
        atakMarkerOpacity(
          now.subtract(const Duration(minutes: 10)).millisecondsSinceEpoch ~/
              1000,
          isParticipant: true,
          now: now,
        ),
        1.0,
      );
      expect(
        atakMarkerOpacity(
          now.subtract(const Duration(minutes: 30)).millisecondsSinceEpoch ~/
              1000,
          isParticipant: true,
          now: now,
        ),
        0.65,
      );
      expect(
        atakMarkerOpacity(
          now.subtract(const Duration(minutes: 90)).millisecondsSinceEpoch ~/
              1000,
          isParticipant: true,
          now: now,
        ),
        0.4,
      );
    });

    test('returns full opacity for poi markers', () {
      final now = DateTime(2025, 1, 1, 12, 0);

      expect(
        atakMarkerOpacity(
          now.subtract(const Duration(hours: 5)).millisecondsSinceEpoch ~/ 1000,
          isParticipant: false,
          now: now,
        ),
        1.0,
      );
    });
  });
}

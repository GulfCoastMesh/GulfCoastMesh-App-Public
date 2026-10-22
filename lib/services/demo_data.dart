import 'dart:typed_data';

import '../connector/meshcore_protocol.dart';
import '../models/channel.dart';
import '../models/channel_message.dart';
import '../models/contact.dart';
import '../models/message.dart';

/// Deterministic, in-memory fixtures used by the interactive demo session.
/// Nothing in this class is written to the user's real MeshCore history.
class DemoData {
  DemoData._();

  static Uint8List key(int seed) => Uint8List.fromList(
    List<int>.generate(32, (index) => (seed * 17 + index * 7) & 0xff),
  );

  static List<Contact> contacts(DateTime now) => [
    Contact(
      publicKey: key(1),
      name: 'CoastalNode',
      type: advTypeChat,
      pathLength: 1,
      path: Uint8List.fromList([0x31]),
      latitude: 30.3674,
      longitude: -89.0928,
      lastSeen: now.subtract(const Duration(minutes: 3)),
      lastMessageAt: now.subtract(const Duration(minutes: 8)),
      isFavorite: true,
      firstSeenAt: now.subtract(const Duration(days: 30)),
    ),
    Contact(
      publicKey: key(2),
      name: 'BayouRelay',
      type: advTypeRepeater,
      pathLength: 0,
      path: Uint8List(0),
      latitude: 30.4433,
      longitude: -90.0362,
      lastSeen: now.subtract(const Duration(minutes: 1)),
      isFavorite: true,
      firstSeenAt: now.subtract(const Duration(days: 80)),
    ),
    Contact(
      publicKey: key(3),
      name: 'Gulfport EOC',
      type: advTypeRoom,
      pathLength: 2,
      path: Uint8List.fromList([0x31, 0x52]),
      latitude: 30.3678,
      longitude: -89.1017,
      lastSeen: now.subtract(const Duration(minutes: 6)),
      firstSeenAt: now.subtract(const Duration(days: 15)),
    ),
    Contact(
      publicKey: key(4),
      name: 'DeltaWX',
      type: advTypeSensor,
      pathLength: 2,
      path: Uint8List.fromList([0x31, 0x8a]),
      latitude: 29.9511,
      longitude: -90.0715,
      lastSeen: now.subtract(const Duration(minutes: 12)),
      firstSeenAt: now.subtract(const Duration(hours: 18)),
    ),
    Contact(
      publicKey: key(5),
      name: 'Morgan City Mobile',
      type: advTypeChat,
      pathLength: -1,
      path: Uint8List(0),
      latitude: 29.6994,
      longitude: -91.2068,
      lastSeen: now.subtract(const Duration(hours: 1)),
      lastMessageAt: now.subtract(const Duration(hours: 2)),
      firstSeenAt: now.subtract(const Duration(days: 2)),
    ),
  ];

  static List<Channel> channels() => [
    Channel.fromHex(0, 'Public', Channel.publicChannelPsk),
    Channel(
      index: 1,
      name: '#weather',
      psk: Channel.derivePskFromHashtag('#weather'),
    ),
    Channel(
      index: 2,
      name: '#emergency',
      psk: Channel.derivePskFromHashtag('#emergency'),
      isFavorite: true,
    ),
    Channel(
      index: 3,
      name: '#gulfcoast',
      psk: Channel.derivePskFromHashtag('#gulfcoast'),
    ),
    Channel(
      index: 4,
      name: '#wx-bot-hidden',
      psk: Channel.derivePskFromHashtag('#wx-bot-hidden'),
    ),
  ];

  static Map<String, List<Message>> conversations(
    List<Contact> contacts,
    DateTime now,
  ) => {
    contacts[0].publicKeyHex: [
      Message(
        senderKey: contacts[0].publicKey,
        text: 'Morning! Radio check from Gulfport.',
        timestamp: now.subtract(const Duration(hours: 3)),
        isOutgoing: false,
        status: MessageStatus.delivered,
        pathLength: 1,
      ),
      Message(
        senderKey: contacts[0].publicKey,
        text: 'Loud and clear. I am testing the mobile app.',
        timestamp: now.subtract(const Duration(hours: 2, minutes: 58)),
        isOutgoing: true,
        status: MessageStatus.delivered,
        pathLength: 1,
      ),
      Message(
        senderKey: contacts[0].publicKey,
        text: 'Copy. The coastal route is looking strong today.',
        timestamp: now.subtract(const Duration(minutes: 8)),
        isOutgoing: false,
        status: MessageStatus.delivered,
        pathLength: 1,
      ),
    ],
    contacts[4].publicKeyHex: [
      Message(
        senderKey: contacts[4].publicKey,
        text: 'Supply run complete; heading back east.',
        timestamp: now.subtract(const Duration(hours: 2)),
        isOutgoing: false,
        status: MessageStatus.delivered,
        pathLength: -1,
      ),
    ],
  };

  static Map<int, List<ChannelMessage>> channelMessages(DateTime now) => {
    0: [
      _channel(
        0,
        'BayouRelay',
        'Good morning Gulf Coast mesh!',
        now.subtract(const Duration(hours: 5)),
        path: [0x31],
      ),
      _channel(
        0,
        'CoastalNode',
        'Anyone available for a route check?',
        now.subtract(const Duration(hours: 2)),
        path: [0x31, 0x52],
      ),
      _channel(
        0,
        'Morgan City Mobile',
        'Received 4 hops into Morgan City.',
        now.subtract(const Duration(minutes: 24)),
        path: [0x31, 0x52, 0x8a, 0x19],
      ),
    ],
    1: [
      _channel(
        1,
        'DeltaWX',
        'Weather bot online. Send a ZIP code for conditions.',
        now.subtract(const Duration(minutes: 15)),
        path: [0x31, 0x8a],
      ),
    ],
    2: [
      _channel(
        2,
        'Gulfport EOC',
        'Weekly emergency net test begins at 19:00.',
        now.subtract(const Duration(hours: 1)),
        path: [0x31, 0x52],
      ),
      _channel(
        2,
        'CoastalNode',
        'Shelter and generator checks complete.',
        now.subtract(const Duration(minutes: 42)),
        path: [0x31],
      ),
      _channel(
        2,
        'CoastalNode',
        'a:v1|pos|30.3674|-89.0928|${now.millisecondsSinceEpoch ~/ 1000}|CoastalNode',
        now.subtract(const Duration(minutes: 7)),
        path: [0x31],
      ),
      _channel(
        2,
        'Gulfport EOC',
        'a:v1|poi|30.3692|-89.1010|${now.millisecondsSinceEpoch ~/ 1000}|Demo supply point|supply',
        now.subtract(const Duration(minutes: 5)),
        path: [0x31, 0x52],
      ),
    ],
    3: [
      _channel(
        3,
        'BayouRelay',
        'Solar battery is at 87%; all systems nominal.',
        now.subtract(const Duration(minutes: 31)),
        path: [0x31],
      ),
    ],
    4: [],
  };

  static ChannelMessage _channel(
    int channel,
    String sender,
    String text,
    DateTime timestamp, {
    required List<int> path,
  }) => ChannelMessage(
    senderName: sender,
    text: text,
    timestamp: timestamp,
    isOutgoing: false,
    status: ChannelMessageStatus.sent,
    channelIndex: channel,
    pathLength: path.length,
    pathBytes: Uint8List.fromList(path),
  );
}

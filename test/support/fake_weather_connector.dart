import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_connector.dart';
import 'package:gulf_coast_mesh_app/models/channel.dart';
import 'package:gulf_coast_mesh_app/models/channel_message.dart';
import 'package:gulf_coast_mesh_app/models/contact.dart';
import 'package:gulf_coast_mesh_app/models/message.dart';

class FakeWeatherConnector extends ChangeNotifier implements MeshCoreConnector {
  final incoming = StreamController<ChannelMessage>.broadcast(sync: true);
  final sent = <String>[];
  final dmSent = <String>[];
  final history = <Message>[];
  final channelList = <Channel>[
    Channel(
      index: 3,
      name: '#wx-bot-hidden',
      psk: Channel.derivePskFromHashtag('#wx-bot-hidden'),
    ),
  ];
  final configuredChannels = <({int index, String name, Uint8List psk})>[];
  void Function(String)? onSend;
  bool connected = true;
  final bot = Contact(
    publicKey: Uint8List.fromList(List.filled(32, 4)),
    name: 'DeltaWX',
    type: 1,
    pathLength: 0,
    path: Uint8List(0),
    lastSeen: DateTime(2026),
  );

  @override
  bool get isConnected => connected;
  @override
  int get maxChannels => 8;
  @override
  List<Contact> get contacts => [bot];
  @override
  List<Channel> get channels => channelList;
  @override
  Stream<ChannelMessage> get receivedChannelMessages => incoming.stream;
  @override
  List<Message> getMessages(Contact contact) => history;
  @override
  Future<void> sendChannelMessage(
    Channel channel,
    String text, {
    bool addToLocalHistory = true,
  }) async {
    sent.add(text);
    onSend?.call(text);
  }

  @override
  Future<void> sendMessage(Contact contact, String text) async {
    dmSent.add(text);
  }

  void emit(String text, {String sender = 'DeltaWX', int? channel}) {
    final channelIndex =
        channel ??
        channelList
            .firstWhere(
              (item) => item.name.toLowerCase().contains('wx-bot-hidden'),
            )
            .index;
    incoming.add(
      ChannelMessage(
        senderName: sender,
        text: text,
        timestamp: DateTime.now(),
        isOutgoing: false,
        channelIndex: channelIndex,
      ),
    );
  }

  @override
  Future<void> setChannel(int index, String name, Uint8List psk) async {
    configuredChannels.add((index: index, name: name, psk: psk));
    channelList.removeWhere((channel) => channel.index == index);
    channelList.add(Channel(index: index, name: name, psk: psk));
    channelList.sort((a, b) => a.index.compareTo(b.index));
  }

  void emitDm(String text) {
    history.add(
      Message(
        senderKey: bot.publicKey,
        text: text,
        timestamp: DateTime.now(),
        isOutgoing: false,
      ),
    );
    notifyListeners();
  }

  @override
  Future<void> disconnect({bool manual = true, bool immediate = false}) async {
    connected = false;
    notifyListeners();
  }

  @override
  void dispose() {
    incoming.close();
    super.dispose();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

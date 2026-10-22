import 'dart:convert';
import 'dart:typed_data';

import '../models/channel.dart';
import 'prefs_manager.dart';
import 'secure_password_store.dart';

class ChannelStore {
  ChannelStore({SecurePasswordStore? secretStore})
    : _secrets = secretStore ?? FlutterSecurePasswordStore();

  final SecurePasswordStore _secrets;

  static const String _key = 'channels';
  static const String _pskSecureKey = 'channel_psks_v1';

  Future<List<Channel>> loadChannels() async {
    final prefs = PrefsManager.instance;
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null) return [];

    final List<dynamic> jsonList;
    try {
      jsonList = jsonDecode(jsonStr) as List<dynamic>;
    } catch (_) {
      return [];
    }

    final pskMap = await _loadPskMap(rawChannels: jsonStr);
    final channels = <Channel>[];
    for (final entry in jsonList) {
      try {
        channels.add(_fromJson(entry as Map<String, dynamic>, pskMap));
      } catch (_) {
        continue;
      }
    }

    if (_channelsContainEmbeddedPsk(jsonList)) {
      await saveChannels(channels);
    }
    return channels;
  }

  Future<void> saveChannels(List<Channel> channels) async {
    final prefs = PrefsManager.instance;
    final jsonList = channels.map(_toJsonMetadata).toList();

    final pskMap = <String, String>{
      for (final channel in channels)
        channel.index.toString(): base64Encode(channel.psk),
    };
    // Write the secure PSK map first: if the process dies between the two
    // writes, reloading still recovers the PSKs (keyed by channel index),
    // whereas the reverse order would yield channels with empty PSKs.
    await _secrets.write(_pskSecureKey, jsonEncode(pskMap));
    await prefs.setString(_key, jsonEncode(jsonList));
  }

  Map<String, dynamic> _toJsonMetadata(Channel channel) {
    return {
      'index': channel.index,
      'name': channel.name,
      'unreadCount': channel.unreadCount,
      'isFavorite': channel.isFavorite,
    };
  }

  Channel _fromJson(Map<String, dynamic> json, Map<String, String> pskMap) {
    final index = json['index'] as int;
    Uint8List psk = Uint8List(16);
    final fromSecure = pskMap[index.toString()];
    if (fromSecure != null) {
      psk = Uint8List.fromList(base64Decode(fromSecure));
    } else if (json['psk'] != null) {
      psk = Uint8List.fromList(base64Decode(json['psk'] as String));
    }

    return Channel(
      index: index,
      name: json['name'] as String? ?? '',
      psk: psk,
      unreadCount: json['unreadCount'] as int? ?? 0,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  bool _channelsContainEmbeddedPsk(List<dynamic> jsonList) {
    for (final entry in jsonList) {
      if (entry is Map<String, dynamic> && entry.containsKey('psk')) {
        return true;
      }
    }
    return false;
  }

  Future<Map<String, String>> _loadPskMap({required String rawChannels}) async {
    final existing = await _secrets.read(_pskSecureKey);
    if (existing != null && existing.isNotEmpty) {
      try {
        final json = jsonDecode(existing) as Map<String, dynamic>;
        return json.map((k, v) => MapEntry(k, v as String));
      } catch (_) {
        // Fall through to migrate from embedded prefs.
      }
    }

    try {
      final jsonList = jsonDecode(rawChannels) as List<dynamic>;
      final migrated = <String, String>{};
      for (final entry in jsonList) {
        if (entry is! Map<String, dynamic>) continue;
        final index = entry['index'];
        final psk = entry['psk'];
        if (index is int && psk is String && psk.isNotEmpty) {
          migrated[index.toString()] = psk;
        }
      }
      if (migrated.isNotEmpty) {
        await _secrets.write(_pskSecureKey, jsonEncode(migrated));
      }
      return migrated;
    } catch (_) {
      return {};
    }
  }
}

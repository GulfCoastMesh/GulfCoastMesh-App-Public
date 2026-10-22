import 'dart:convert';
import 'dart:typed_data';

import '../connector/meshcore_protocol.dart';
import '../helpers/atak_location_access.dart';
import '../models/contact.dart';
import 'prefs_manager.dart';

class ContactStore {
  static const String _key = 'contacts';

  Future<List<Contact>> loadContacts() async {
    final prefs = PrefsManager.instance;
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null) return [];

    final List<dynamic> jsonList;
    try {
      jsonList = jsonDecode(jsonStr) as List<dynamic>;
    } catch (_) {
      return [];
    }

    final contacts = <Contact>[];
    for (final entry in jsonList) {
      try {
        contacts.add(_fromJson(entry as Map<String, dynamic>));
      } catch (_) {
        // Skip the bad record; preserve the rest.
        continue;
      }
    }
    return contacts;
  }

  Future<void> saveContacts(List<Contact> contacts) async {
    final prefs = PrefsManager.instance;
    final jsonList = contacts.map(_toJson).toList();
    await prefs.setString(_key, jsonEncode(jsonList));
  }

  Map<String, dynamic> _toJson(Contact contact) {
    return {
      'publicKey': base64Encode(contact.publicKey),
      'name': contact.name,
      'type': contact.type,
      'pathLength': contact.pathLength,
      'path': base64Encode(contact.path),
      'pathOverride': contact.pathOverride,
      'pathOverrideBytes': contact.pathOverrideBytes != null
          ? base64Encode(contact.pathOverrideBytes!)
          : null,
      'latitude': contact.latitude,
      'longitude': contact.longitude,
      'lastSeen': contact.lastSeen.millisecondsSinceEpoch,
      'lastMessageAt': contact.lastMessageAt.millisecondsSinceEpoch,
      'isFavorite': contact.isFavorite,
      'firstSeenAt': contact.firstSeenAt?.millisecondsSinceEpoch,
      'nickname': contact.nickname,
    };
  }

  Contact _fromJson(Map<String, dynamic> json) {
    final publicKey = Uint8List.fromList(
      base64Decode(json['publicKey'] as String),
    );
    if (publicKey.length != pubKeySize) {
      throw const FormatException('Invalid contact public key length');
    }
    final lastSeenMs = json['lastSeen'] as int? ?? 0;
    final lastMessageMs = json['lastMessageAt'] as int?;
    final firstSeenMs = json['firstSeenAt'] as int?;
    double? latitude = (json['latitude'] as num?)?.toDouble();
    double? longitude = (json['longitude'] as num?)?.toDouble();
    if (latitude != null &&
        longitude != null &&
        !isValidMapCoordinate(latitude, longitude)) {
      latitude = null;
      longitude = null;
    }

    return Contact(
      publicKey: publicKey,
      name: json['name'] as String? ?? 'Unknown',
      type: json['type'] as int? ?? 0,
      pathLength: json['pathLength'] as int? ?? -1,
      path: json['path'] != null
          ? Uint8List.fromList(base64Decode(json['path'] as String))
          : Uint8List(0),
      pathOverride: json['pathOverride'] as int?,
      pathOverrideBytes: json['pathOverrideBytes'] != null
          ? Uint8List.fromList(
              base64Decode(json['pathOverrideBytes'] as String),
            )
          : null,
      latitude: latitude,
      longitude: longitude,
      lastSeen: DateTime.fromMillisecondsSinceEpoch(lastSeenMs),
      lastMessageAt: DateTime.fromMillisecondsSinceEpoch(
        lastMessageMs ?? lastSeenMs,
      ),
      isFavorite: json['isFavorite'] as bool? ?? false,
      firstSeenAt: firstSeenMs != null
          ? DateTime.fromMillisecondsSinceEpoch(firstSeenMs)
          : null,
      nickname: json['nickname'] as String?,
    );
  }
}

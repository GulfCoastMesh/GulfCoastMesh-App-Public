import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/models/contact.dart';
import 'package:gulf_coast_mesh_app/storage/contact_store.dart';
import 'package:gulf_coast_mesh_app/storage/prefs_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ContactStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PrefsManager.reset();
    await PrefsManager.initialize();
    store = ContactStore();
  });

  tearDown(() {
    PrefsManager.reset();
  });

  Map<String, dynamic> goodContact(String name) {
    return {
      'publicKey': base64Encode(List.filled(32, 1)),
      'name': name,
      'type': 1,
      'pathLength': 0,
      'path': base64Encode(<int>[]),
      'pathOverride': null,
      'pathOverrideBytes': null,
      'latitude': null,
      'longitude': null,
      'lastSeen': 1700000000000,
      'lastMessageAt': 1700000000000,
    };
  }

  test('one corrupt record does not drop the others', () async {
    final bad = {'publicKey': 12345, 'name': 'corrupt'};

    await PrefsManager.instance.setString(
      'contacts',
      jsonEncode([goodContact('alice'), bad, goodContact('bob')]),
    );

    final loaded = await store.loadContacts();
    expect(loaded.map((c) => c.name), ['alice', 'bob']);
  });

  test('contact with a short public key is skipped', () async {
    final shortKey = goodContact('short-key')
      ..['publicKey'] = base64Encode(List.filled(4, 1));
    await PrefsManager.instance.setString(
      'contacts',
      jsonEncode([goodContact('alice'), shortKey]),
    );

    final loaded = await store.loadContacts();
    expect(loaded.map((contact) => contact.name), ['alice']);
  });

  test('top-level invalid json returns empty list', () async {
    await PrefsManager.instance.setString('contacts', 'not json');
    final loaded = await store.loadContacts();
    expect(loaded, isEmpty);
  });

  test(
    'legacy json without favorite/firstSeenAt loads with defaults',
    () async {
      await PrefsManager.instance.setString(
        'contacts',
        jsonEncode([goodContact('legacy')]),
      );
      final loaded = await store.loadContacts();
      expect(loaded, hasLength(1));
      expect(loaded.first.isFavorite, isFalse);
      expect(loaded.first.firstSeenAt, isNull);
      expect(loaded.first.isNew, isFalse);
    },
  );

  test('null island coordinates load as no location', () async {
    final json = goodContact('null-island');
    json['latitude'] = 0;
    json['longitude'] = 0;
    await PrefsManager.instance.setString('contacts', jsonEncode([json]));
    final loaded = await store.loadContacts();
    expect(loaded, hasLength(1));
    expect(loaded.first.latitude, isNull);
    expect(loaded.first.longitude, isNull);
    expect(loaded.first.hasLocation, isFalse);
  });

  test('round-trips isFavorite and firstSeenAt', () async {
    final firstSeen = DateTime.utc(2026, 7, 1, 12);
    final contact = Contact(
      publicKey: Uint8List.fromList(List.filled(32, 7)),
      name: 'Fav',
      type: 1,
      pathLength: 1,
      path: Uint8List.fromList([1]),
      lastSeen: DateTime.utc(2026, 7, 20),
      lastMessageAt: DateTime.utc(2026, 7, 20),
      isFavorite: true,
      firstSeenAt: firstSeen,
    );
    await store.saveContacts([contact]);
    final loaded = await store.loadContacts();
    expect(loaded, hasLength(1));
    expect(loaded.first.isFavorite, isTrue);
    expect(
      loaded.first.firstSeenAt!.millisecondsSinceEpoch,
      firstSeen.millisecondsSinceEpoch,
    );
  });
}

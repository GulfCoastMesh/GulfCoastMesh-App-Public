import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_protocol.dart';
import 'package:gulf_coast_mesh_app/models/contact.dart';

void main() {
  Contact makeContact({double? latitude, double? longitude}) {
    return Contact(
      publicKey: Uint8List.fromList(List.filled(32, 1)),
      name: 'Repeater',
      type: advTypeRepeater,
      pathLength: 0,
      path: Uint8List(0),
      latitude: latitude,
      longitude: longitude,
      lastSeen: DateTime.utc(2026, 1, 1),
    );
  }

  group('Contact.displayName', () {
    test('falls back to name when no nickname is set', () {
      expect(makeContact().displayName, 'Repeater');
    });

    test('prefers a non-blank nickname over name', () {
      final withNickname = makeContact().copyWith(nickname: 'Bay Relay');
      expect(withNickname.displayName, 'Bay Relay');
    });

    test('trims a nickname and falls back to name when it is blank', () {
      final blankNickname = makeContact().copyWith(nickname: '   ');
      expect(blankNickname.displayName, 'Repeater');

      final trimmed = makeContact().copyWith(nickname: '  Bay Relay  ');
      expect(trimmed.displayName, 'Bay Relay');
    });

    test('copyWith(clearNickname: true) removes a previously set nickname', () {
      final renamed = makeContact().copyWith(nickname: 'Bay Relay');
      final cleared = renamed.copyWith(clearNickname: true);
      expect(cleared.nickname, isNull);
      expect(cleared.displayName, 'Repeater');
    });
  });

  group('Contact.hasLocation', () {
    test('false for null island coordinates', () {
      expect(makeContact(latitude: 0, longitude: 0).hasLocation, isFalse);
    });

    test('false when latitude or longitude is null', () {
      expect(makeContact(latitude: 30, longitude: null).hasLocation, isFalse);
      expect(makeContact(latitude: null, longitude: -90).hasLocation, isFalse);
    });

    test('true for valid coordinates', () {
      expect(
        makeContact(latitude: 30.2672, longitude: -97.7431).hasLocation,
        isTrue,
      );
    });
  });
}

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/helpers/contact_local_state.dart';
import 'package:gulf_coast_mesh_app/models/contact.dart';

Contact _deviceContact({
  required List<int> keyBytes,
  String name = 'Node',
  bool isFavorite = false,
  int? pathOverride,
  Uint8List? pathOverrideBytes,
  DateTime? firstSeenAt,
  DateTime? lastMessageAt,
}) {
  final now = DateTime.fromMillisecondsSinceEpoch(1_700_000_000_000);
  return Contact(
    publicKey: Uint8List.fromList(keyBytes),
    name: name,
    type: 1,
    pathLength: 2,
    path: Uint8List.fromList([1, 2]),
    isFavorite: isFavorite,
    pathOverride: pathOverride,
    pathOverrideBytes: pathOverrideBytes,
    firstSeenAt: firstSeenAt,
    lastSeen: now,
    lastMessageAt: lastMessageAt ?? now,
  );
}

void main() {
  group('mergeContactLocalFields', () {
    test('restores favorite and path override after sync clear', () {
      final device = _deviceContact(keyBytes: List.filled(32, 1));
      final local = ContactLocalState(
        isFavorite: true,
        pathOverride: -1,
        pathOverrideBytes: null,
        firstSeenAt: DateTime.fromMillisecondsSinceEpoch(1_600_000_000_000),
      );

      final merged = mergeContactLocalFields(device, local: local);

      expect(merged.isFavorite, isTrue);
      expect(merged.pathOverride, -1);
      expect(
        merged.firstSeenAt,
        DateTime.fromMillisecondsSinceEpoch(1_600_000_000_000),
      );
    });

    test('prefers in-memory existing over stored local map', () {
      final device = _deviceContact(keyBytes: List.filled(32, 2));
      final existing = _deviceContact(
        keyBytes: List.filled(32, 2),
        isFavorite: true,
        pathOverride: 1,
        pathOverrideBytes: Uint8List.fromList([0xAB]),
        firstSeenAt: DateTime.fromMillisecondsSinceEpoch(1_650_000_000_000),
      );
      final local = ContactLocalState(
        isFavorite: false,
        pathOverride: -1,
        firstSeenAt: DateTime.fromMillisecondsSinceEpoch(1_600_000_000_000),
      );

      final merged = mergeContactLocalFields(
        device,
        existing: existing,
        local: local,
      );

      expect(merged.isFavorite, isTrue);
      expect(merged.pathOverride, 1);
      expect(merged.pathOverrideBytes, Uint8List.fromList([0xAB]));
      expect(
        merged.firstSeenAt,
        DateTime.fromMillisecondsSinceEpoch(1_650_000_000_000),
      );
    });

    test('cleared path override is not re-applied by local merge', () {
      final device = _deviceContact(keyBytes: List.filled(32, 4));
      final forced = _deviceContact(
        keyBytes: List.filled(32, 4),
        pathOverride: 1,
        pathOverrideBytes: Uint8List.fromList([0xAB]),
      );

      final cleared = forced.copyWith(
        pathLength: -1,
        path: Uint8List(0),
        clearPathOverride: true,
      );
      expect(cleared.pathOverride, isNull);
      expect(cleared.pathOverrideBytes, isNull);

      final local = ContactLocalState.fromContact(cleared);
      expect(local.pathOverride, isNull);
      expect(local.pathOverrideBytes, isNull);

      final merged = mergeContactLocalFields(device, local: local);
      expect(merged.pathOverride, isNull);
      expect(merged.pathOverrideBytes, isNull);
    });

    test('keeps newer lastMessageAt from existing', () {
      final older = DateTime.fromMillisecondsSinceEpoch(1_700_000_000_000);
      final newer = DateTime.fromMillisecondsSinceEpoch(1_700_000_100_000);
      final device = _deviceContact(
        keyBytes: List.filled(32, 3),
        lastMessageAt: older,
      );
      final existing = _deviceContact(
        keyBytes: List.filled(32, 3),
        lastMessageAt: newer,
      );

      final merged = mergeContactLocalFields(device, existing: existing);
      expect(merged.lastMessageAt, newer);
    });
  });
}

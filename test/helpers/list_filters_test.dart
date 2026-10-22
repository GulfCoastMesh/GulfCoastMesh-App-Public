import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/helpers/list_filters.dart';
import 'package:gulf_coast_mesh_app/models/contact.dart';
import 'dart:typed_data';

void main() {
  group('chatFilter round-trip', () {
    test('parses known values', () {
      expect(chatFilterFromString('all'), ChatFilter.all);
      expect(chatFilterFromString('unread'), ChatFilter.unread);
      expect(chatFilterFromString('dms'), ChatFilter.dms);
      expect(chatFilterFromString('channels'), ChatFilter.channels);
      expect(chatFilterFromString('rooms'), ChatFilter.rooms);
      expect(chatFilterFromString('unknown'), ChatFilter.all);
    });

    test('serializes all values', () {
      for (final f in ChatFilter.values) {
        expect(chatFilterFromString(chatFilterToString(f)), f);
      }
    });
  });

  group('chatSortMode round-trip', () {
    test('parses known values', () {
      expect(chatSortModeFromString('recent'), ChatSortMode.recent);
      expect(chatSortModeFromString('alphabetical'), ChatSortMode.alphabetical);
      expect(chatSortModeFromString('unknown'), ChatSortMode.recent);
    });

    test('serializes all values', () {
      for (final m in ChatSortMode.values) {
        expect(chatSortModeFromString(chatSortModeToString(m)), m);
      }
    });
  });

  group('nodeCategoryFilter round-trip', () {
    test('parses known values', () {
      expect(
        nodeCategoryFilterFromString('favorites'),
        NodeCategoryFilter.favorites,
      );
      expect(
        nodeCategoryFilterFromString('contacts'),
        NodeCategoryFilter.contacts,
      );
      expect(
        nodeCategoryFilterFromString('repeaters'),
        NodeCategoryFilter.repeaters,
      );
      expect(nodeCategoryFilterFromString('rooms'), NodeCategoryFilter.rooms);
      expect(
        nodeCategoryFilterFromString('unknown'),
        NodeCategoryFilter.contacts,
      );
    });

    test('serializes all values', () {
      for (final f in NodeCategoryFilter.values) {
        expect(nodeCategoryFilterFromString(nodeCategoryFilterToString(f)), f);
      }
    });
  });

  group('Contact isNew / isFavorite', () {
    Contact makeContact({DateTime? firstSeenAt, bool isFavorite = false}) {
      return Contact(
        publicKey: Uint8List.fromList(List.filled(32, 1)),
        name: 'Test',
        type: 1,
        pathLength: 0,
        path: Uint8List(0),
        lastSeen: DateTime.now(),
        firstSeenAt: firstSeenAt,
        isFavorite: isFavorite,
      );
    }

    test('isNew is false when firstSeenAt is null', () {
      expect(makeContact().isNew, isFalse);
    });

    test('isNew is true within 7 days', () {
      expect(
        makeContact(
          firstSeenAt: DateTime.now().subtract(const Duration(days: 3)),
        ).isNew,
        isTrue,
      );
    });

    test('isNew is false after 7 days', () {
      expect(
        makeContact(
          firstSeenAt: DateTime.now().subtract(const Duration(days: 8)),
        ).isNew,
        isFalse,
      );
    });

    test('isNew is false for a future first-seen timestamp', () {
      final contact = makeContact(
        firstSeenAt: DateTime.now().add(const Duration(days: 1)),
      );
      expect(contact.isNew, isFalse);
    });

    test('copyWith preserves favorite and firstSeenAt', () {
      final original = makeContact(
        firstSeenAt: DateTime.utc(2026, 1, 1),
        isFavorite: true,
      );
      final copied = original.copyWith(name: 'Renamed');
      expect(copied.isFavorite, isTrue);
      expect(copied.firstSeenAt, original.firstSeenAt);
      expect(copied.name, 'Renamed');
    });
  });
}

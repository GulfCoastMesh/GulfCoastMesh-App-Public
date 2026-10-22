import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/models/path_history.dart';
import 'package:gulf_coast_mesh_app/models/path_selection.dart';
import 'package:gulf_coast_mesh_app/services/path_history_service.dart';
import 'package:gulf_coast_mesh_app/services/storage_service.dart';
import 'package:gulf_coast_mesh_app/storage/prefs_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _DelayedPathStorage extends StorageService {
  _DelayedPathStorage() : super();

  final loadResult = Completer<ContactPathHistory?>();
  bool cleared = false;

  @override
  Future<ContactPathHistory?> loadPathHistory(String contactPubKeyHex) =>
      loadResult.future;

  @override
  Future<void> clearPathHistory(String contactPubKeyHex) async {
    cleared = true;
  }
}

void main() {
  late PathHistoryService service;
  late StorageService storage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PrefsManager.reset();
    await PrefsManager.initialize();
    storage = StorageService();
    service = PathHistoryService(storage);
  });

  tearDown(() {
    PrefsManager.reset();
  });

  test(
    'concurrent first-time writes for the same contact preserve both records',
    () async {
      const pubKey = 'aabbccddeeff00112233445566778899';

      // Fire two writes synchronously — both observe an empty cache for the
      // contact and trigger a cold-start load. The previous implementation
      // raced two independent loads and the second one wiped out the first
      // record. With the shared in-flight load, both records must survive.
      service.recordPathAttempt(
        pubKey,
        const PathSelection(
          pathBytes: [0x01, 0x02],
          hopCount: 2,
          useFlood: false,
        ),
      );
      service.recordPathAttempt(
        pubKey,
        const PathSelection(
          pathBytes: [0x03, 0x04],
          hopCount: 2,
          useFlood: false,
        ),
      );

      // Drain microtasks so the .then callbacks run.
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      final paths = service.getRecentPaths(pubKey);
      expect(paths, hasLength(2));
      // Most recent insert comes first.
      expect(paths[0].pathBytes, [0x03, 0x04]);
      expect(paths[1].pathBytes, [0x01, 0x02]);
    },
  );

  test(
    'a single first-time write still lands in the cache and persists to storage',
    () async {
      const pubKey = 'ffeeddccbbaa99887766554433221100';

      service.recordPathAttempt(
        pubKey,
        const PathSelection(
          pathBytes: [0xaa, 0xbb],
          hopCount: 2,
          useFlood: false,
        ),
      );

      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(service.getRecentPaths(pubKey), hasLength(1));

      // A fresh service should be able to read the same record back from
      // storage, proving the write made it through.
      final fresh = PathHistoryService(storage);
      fresh.getRecentPaths(pubKey); // kicks off the load
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      final loaded = fresh.getRecentPaths(pubKey);
      expect(loaded, hasLength(1));
      expect(loaded.first.pathBytes, [0xaa, 0xbb]);
    },
  );

  test('clear waits for an in-flight load and cannot be repopulated', () async {
    const pubKey = '11223344';
    final delayedStorage = _DelayedPathStorage();
    final delayedService = PathHistoryService(delayedStorage);

    delayedService.getRecentPaths(pubKey);
    final clearing = delayedService.clearPathHistory(pubKey);
    delayedStorage.loadResult.complete(
      ContactPathHistory(
        contactPubKeyHex: pubKey,
        recentPaths: [
          PathRecord(
            hopCount: 1,
            tripTimeMs: 100,
            timestamp: DateTime.utc(2026, 1, 1),
            wasFloodDiscovery: false,
            pathBytes: const [1],
            successCount: 1,
            failureCount: 0,
          ),
        ],
      ),
    );

    await clearing;
    expect(delayedStorage.cleared, isTrue);
    expect(delayedService.getRecentPaths(pubKey), isEmpty);
  });
}

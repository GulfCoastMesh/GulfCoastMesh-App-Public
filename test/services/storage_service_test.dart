import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/services/storage_service.dart';
import 'package:gulf_coast_mesh_app/storage/prefs_manager.dart';
import 'package:gulf_coast_mesh_app/storage/secure_password_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late StorageService storage;
  late InMemorySecurePasswordStore secure;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PrefsManager.reset();
    await PrefsManager.initialize();
    secure = InMemorySecurePasswordStore();
    storage = StorageService(passwordStore: secure);
  });

  tearDown(() {
    PrefsManager.reset();
  });

  group('path history recovery', () {
    test('one malformed path record does not discard valid records', () async {
      const contactKey = 'aabbccdd';
      await PrefsManager.instance.setString(
        'path_history_$contactKey',
        jsonEncode({
          'recent_paths': [
            {
              'hop_count': 2.0,
              'trip_time_ms': 1200.0,
              'timestamp': '2026-01-02T03:04:05.000Z',
              'was_flood': false,
              'path_bytes': [1.0, 2.0],
              'success_count': 3.0,
              'failure_count': 1.0,
            },
            {
              'hop_count': 1,
              'trip_time_ms': 100,
              'timestamp': 'not-a-date',
              'was_flood': false,
              'path_bytes': [999],
            },
          ],
        }),
      );

      final history = await storage.loadPathHistory(contactKey);

      expect(history, isNotNull);
      expect(history!.recentPaths, hasLength(1));
      expect(history.recentPaths.single.pathBytes, [1, 2]);
      expect(history.recentPaths.single.successCount, 3);
    });
  });

  group('repeater password serialization', () {
    test(
      'concurrent saves for different repeaters preserve both entries',
      () async {
        final a = storage.saveRepeaterPassword('aaaa', 'pwA');
        final b = storage.saveRepeaterPassword('bbbb', 'pwB');
        final c = storage.saveRepeaterPassword('cccc', 'pwC');

        await Future.wait([a, b, c]);

        final all = await storage.loadRepeaterPasswords();
        expect(all, {'aaaa': 'pwA', 'bbbb': 'pwB', 'cccc': 'pwC'});
      },
    );

    test('concurrent save and remove still leave the map consistent', () async {
      await storage.saveRepeaterPassword('aaaa', 'pwA');

      final save = storage.saveRepeaterPassword('bbbb', 'pwB');
      final remove = storage.removeRepeaterPassword('aaaa');

      await Future.wait([save, remove]);

      final all = await storage.loadRepeaterPasswords();
      expect(all, {'bbbb': 'pwB'});
    });

    test(
      'clearAll after an in-flight save wipes the map (no late re-population)',
      () async {
        await storage.saveRepeaterPassword('aaaa', 'pwA');

        final save = storage.saveRepeaterPassword('bbbb', 'pwB');
        final clear = storage.clearAllRepeaterPasswords();

        await Future.wait([save, clear]);

        final all = await storage.loadRepeaterPasswords();
        expect(all, isEmpty);
      },
    );
  });

  group('secure storage backing', () {
    test('save writes to secure store, not SharedPreferences', () async {
      await storage.saveRepeaterPassword('aaaa', 'pwA');

      expect(await secure.read('repeater_pw_aaaa'), 'pwA');
      // Legacy plaintext key should remain untouched / empty.
      expect(PrefsManager.instance.getString('repeater_passwords'), isNull);
    });

    test(
      'clearAll removes every namespaced entry from the secure store',
      () async {
        await storage.saveRepeaterPassword('aaaa', 'pwA');
        await storage.saveRepeaterPassword('bbbb', 'pwB');

        await storage.clearAllRepeaterPasswords();

        expect(await secure.readAll(), isEmpty);
      },
    );

    test('save does not pollute unrelated secure storage entries', () async {
      await secure.write('unrelated_entry', 'keepme');
      await storage.saveRepeaterPassword('aaaa', 'pwA');
      await storage.clearAllRepeaterPasswords();

      // Unrelated entry must survive clearAll.
      expect(await secure.read('unrelated_entry'), 'keepme');
    });
  });

  group('lazy migration from legacy plaintext prefs', () {
    Future<void> seedLegacy(Map<String, String> legacy) async {
      await PrefsManager.instance.setString(
        'repeater_passwords',
        jsonEncode(legacy),
      );
    }

    test(
      'getRepeaterPassword reads from legacy and migrates the entry',
      () async {
        await seedLegacy({'aaaa': 'pwA', 'bbbb': 'pwB'});

        expect(await storage.getRepeaterPassword('aaaa'), 'pwA');

        // After read, that entry has moved into the secure store...
        expect(await secure.read('repeater_pw_aaaa'), 'pwA');
        // ...and is no longer in the legacy blob.
        final legacyAfter = jsonDecode(
          PrefsManager.instance.getString('repeater_passwords')!,
        );
        expect(legacyAfter, {'bbbb': 'pwB'});
      },
    );

    test(
      'loadRepeaterPasswords migrates everything and wipes the legacy blob',
      () async {
        await seedLegacy({'aaaa': 'pwA', 'bbbb': 'pwB', 'cccc': 'pwC'});

        final all = await storage.loadRepeaterPasswords();

        expect(all, {'aaaa': 'pwA', 'bbbb': 'pwB', 'cccc': 'pwC'});
        expect(await secure.read('repeater_pw_aaaa'), 'pwA');
        expect(await secure.read('repeater_pw_bbbb'), 'pwB');
        expect(await secure.read('repeater_pw_cccc'), 'pwC');
        expect(PrefsManager.instance.getString('repeater_passwords'), isNull);
      },
    );

    test(
      'secure entry takes precedence over legacy for the same key',
      () async {
        await seedLegacy({'aaaa': 'legacyPw'});
        await secure.write('repeater_pw_aaaa', 'securePw');

        // Read picks the secure value and doesn't promote the legacy one.
        expect(await storage.getRepeaterPassword('aaaa'), 'securePw');
        expect(await secure.read('repeater_pw_aaaa'), 'securePw');
      },
    );

    test('removeRepeaterPassword cleans both stores', () async {
      await seedLegacy({'aaaa': 'legacyPw'});
      await secure.write('repeater_pw_aaaa', 'securePw');

      await storage.removeRepeaterPassword('aaaa');

      expect(await secure.read('repeater_pw_aaaa'), isNull);
      // Legacy entry for aaaa should also be gone (the blob is removed
      // entirely once empty).
      expect(PrefsManager.instance.getString('repeater_passwords'), isNull);
    });

    test('saveRepeaterPassword also evicts a stale legacy entry', () async {
      await seedLegacy({'aaaa': 'legacyPw', 'bbbb': 'otherPw'});

      await storage.saveRepeaterPassword('aaaa', 'newPw');

      expect(await secure.read('repeater_pw_aaaa'), 'newPw');
      // aaaa's legacy entry must be gone; bbbb's is untouched.
      final legacyAfter = jsonDecode(
        PrefsManager.instance.getString('repeater_passwords')!,
      );
      expect(legacyAfter, {'bbbb': 'otherPw'});
    });

    test(
      'saveRepeaterPassword wipes the legacy blob when it becomes empty',
      () async {
        await seedLegacy({'aaaa': 'legacyPw'});

        await storage.saveRepeaterPassword('aaaa', 'newPw');

        expect(PrefsManager.instance.getString('repeater_passwords'), isNull);
      },
    );

    test('unparseable legacy blob does not block new saves', () async {
      await PrefsManager.instance.setString(
        'repeater_passwords',
        '{not valid json',
      );

      // Save still succeeds and lands in the secure store.
      await storage.saveRepeaterPassword('aaaa', 'pwA');
      expect(await secure.read('repeater_pw_aaaa'), 'pwA');
    });
  });
}

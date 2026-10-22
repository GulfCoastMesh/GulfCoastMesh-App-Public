import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/storage/prefs_manager.dart';
import 'package:gulf_coast_mesh_app/storage/unread_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PrefsManager.reset();
    await PrefsManager.initialize();
  });

  tearDown(PrefsManager.reset);

  test('save snapshots the supplied map', () async {
    String? written;
    final store = UnreadStore(write: (_, value) async => written = value);
    final counts = {'alice': 1};

    store.saveContactUnreadCount(counts);
    counts['alice'] = 9;
    await store.flush();

    expect(jsonDecode(written!), {'alice': 1});
  });

  test('an update arriving during a write is not discarded', () async {
    final firstStarted = Completer<void>();
    final releaseFirst = Completer<void>();
    final writes = <Map<String, dynamic>>[];
    var writeCount = 0;
    final store = UnreadStore(
      write: (_, value) async {
        writeCount++;
        if (writeCount == 1) {
          firstStarted.complete();
          await releaseFirst.future;
        }
        writes.add(jsonDecode(value) as Map<String, dynamic>);
      },
    );

    store.saveContactUnreadCount({'alice': 1});
    final firstFlush = store.flush();
    await firstStarted.future;
    store.saveContactUnreadCount({'alice': 2, 'bob': 1});
    final secondFlush = store.flush();
    releaseFirst.complete();

    await Future.wait([firstFlush, secondFlush]);
    expect(writes, [
      {'alice': 1},
      {'alice': 2, 'bob': 1},
    ]);
  });

  test('load salvages valid nonnegative integer counts', () async {
    await PrefsManager.instance.setString(
      'contact_unread_count',
      jsonEncode({'alice': 2, 'bob': 3.0, 'bad': 'four', 'negative': -1}),
    );

    expect(await UnreadStore().loadContactUnreadCount(), {
      'alice': 2,
      'bob': 3,
    });
  });
}

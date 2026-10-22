import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/storage/atak_map_state_store.dart';
import 'package:gulf_coast_mesh_app/storage/prefs_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AtakMapStateStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PrefsManager.reset();
    await PrefsManager.initialize();
    store = AtakMapStateStore();
  });

  tearDown(() {
    PrefsManager.reset();
  });

  test('persists hidden marker ids', () async {
    expect(await store.loadHiddenIds(), isEmpty);

    await store.saveHiddenIds({'atak:pos:2:Alpha', 'atak:poi:2:msg-1'});

    expect(await store.loadHiddenIds(), {
      'atak:pos:2:Alpha',
      'atak:poi:2:msg-1',
    });
  });

  test('persists removed marker ids', () async {
    expect(await store.loadRemovedIds(), isEmpty);

    await store.saveRemovedIds({'atak:poi:2:msg-2'});

    expect(await store.loadRemovedIds(), {'atak:poi:2:msg-2'});
  });

  test('hidden and removed sets are independent', () async {
    await store.saveHiddenIds({'atak:pos:2:Alpha'});
    await store.saveRemovedIds({'atak:poi:2:msg-3'});

    expect(await store.loadHiddenIds(), {'atak:pos:2:Alpha'});
    expect(await store.loadRemovedIds(), {'atak:poi:2:msg-3'});
  });
}

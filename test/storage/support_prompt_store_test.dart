import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/storage/prefs_manager.dart';
import 'package:gulf_coast_mesh_app/storage/support_prompt_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SupportPromptStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PrefsManager.reset();
    await PrefsManager.initialize();
    store = SupportPromptStore();
  });

  tearDown(() {
    PrefsManager.reset();
  });

  test(
    'loadOrInitFirstLaunch records now on first call and is stable after',
    () async {
      final first = await store.loadOrInitFirstLaunch();
      final second = await store.loadOrInitFirstLaunch();
      // Round-tripped through millisecond epoch storage, so compare at that
      // precision rather than exact DateTime equality.
      expect(second.millisecondsSinceEpoch, first.millisecondsSinceEpoch);
    },
  );

  test(
    'hasShownPrompt defaults to false and flips after markPromptShown',
    () async {
      expect(store.hasShownPrompt(), isFalse);
      await store.markPromptShown();
      expect(store.hasShownPrompt(), isTrue);
    },
  );
}

import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/models/notification_pref.dart';
import 'package:gulf_coast_mesh_app/storage/notification_prefs_store.dart';
import 'package:gulf_coast_mesh_app/storage/prefs_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late NotificationPrefsStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PrefsManager.reset();
    await PrefsManager.initialize();
    store = NotificationPrefsStore();
  });

  tearDown(() {
    PrefsManager.reset();
  });

  test('loadChannelPref returns the fallback when nothing is stored', () {
    final pref = store.loadChannelPref(3, NotificationLevel.all);
    expect(pref.level, NotificationLevel.all);
    expect(pref.soundEnabled, isTrue);
    expect(pref.vibrationEnabled, isTrue);
    expect(pref.bannerEnabled, isTrue);
  });

  test(
    'saveChannelPref then loadChannelPref round-trips, ignoring the fallback',
    () async {
      await store.saveChannelPref(
        5,
        const NotificationPref(
          level: NotificationLevel.custom,
          soundEnabled: false,
          vibrationEnabled: true,
          bannerEnabled: false,
        ),
      );

      final pref = store.loadChannelPref(5, NotificationLevel.none);
      expect(pref.level, NotificationLevel.custom);
      expect(pref.soundEnabled, isFalse);
      expect(pref.vibrationEnabled, isTrue);
      expect(pref.bannerEnabled, isFalse);
    },
  );

  test('channel and contact prefs are stored independently', () async {
    await store.saveChannelPref(
      1,
      const NotificationPref(level: NotificationLevel.none),
    );
    await store.saveContactPref(
      'deadbeef',
      const NotificationPref(level: NotificationLevel.mentions),
    );

    expect(
      store.loadChannelPref(1, NotificationLevel.all).level,
      NotificationLevel.none,
    );
    expect(
      store.loadContactPref('deadbeef', NotificationLevel.all).level,
      NotificationLevel.mentions,
    );
    // A different channel index / contact key is unaffected.
    expect(
      store.loadChannelPref(2, NotificationLevel.all).level,
      NotificationLevel.all,
    );
  });
}

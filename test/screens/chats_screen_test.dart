import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_connector.dart';
import 'package:gulf_coast_mesh_app/l10n/app_localizations.dart';
import 'package:gulf_coast_mesh_app/models/channel.dart';
import 'package:gulf_coast_mesh_app/models/contact.dart';
import 'package:gulf_coast_mesh_app/screens/chats_screen.dart';
import 'package:gulf_coast_mesh_app/services/app_settings_service.dart';
import 'package:gulf_coast_mesh_app/storage/prefs_manager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PrefsManager.reset();
    await PrefsManager.initialize();
  });

  tearDown(PrefsManager.reset);

  Contact contact(String name, {bool isFavorite = false}) => Contact(
    publicKey: Uint8List.fromList(List.filled(32, name.hashCode & 0xff)),
    name: name,
    type: 1,
    pathLength: 0,
    path: Uint8List(0),
    lastSeen: DateTime.utc(2026, 1, 1),
    isFavorite: isFavorite,
  );

  double dyOf(WidgetTester tester, String text) =>
      tester.getTopLeft(find.text(text)).dy;

  test('weather channel names match exactly with optional hash and case', () {
    for (final name in [
      'wx-bot-hidden',
      '#wx-bot-hidden',
      ' #WX-BOT-HIDDEN ',
    ]) {
      expect(Channel.isWeatherChannelName(name), isTrue);
    }
    for (final name in [
      '#weather',
      '#wx-bot-hidden-other',
      'other-wx-bot-hidden',
    ]) {
      expect(Channel.isWeatherChannelName(name), isFalse);
    }
  });

  testWidgets('weather channel stays hidden in chat filters and search', (
    tester,
  ) async {
    final connector = MeshCoreConnector();
    addTearDown(connector.dispose);
    final settings = AppSettingsService();
    addTearDown(settings.dispose);
    connector.addChannelForTest(
      Channel(
        index: 1,
        name: ' #WX-BOT-HIDDEN ',
        psk: Uint8List(16),
        unreadCount: 5,
        isFavorite: true,
      ),
    );
    connector.addChannelForTest(
      Channel(index: 2, name: '#weather', psk: Uint8List(16), unreadCount: 2),
    );
    await connector.loadUnreadState();
    expect(connector.getUnreadCountForChannelIndex(1), 0);
    expect(connector.getUnreadCountForChannelIndex(2), 2);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<MeshCoreConnector>.value(value: connector),
          ChangeNotifierProvider<AppSettingsService>.value(value: settings),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ChatsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('#weather'), findsOneWidget);
    for (final filter in ['Unread', 'Channels', 'DMs', 'Rooms', 'All']) {
      await tester.tap(find.text(filter));
      await tester.pumpAndSettle();
      expect(find.text(' #WX-BOT-HIDDEN '), findsNothing);
    }
    await tester.enterText(find.byType(TextField), 'wx-bot-hidden');
    await tester.pumpAndSettle(const Duration(milliseconds: 400));
    expect(find.text(' #WX-BOT-HIDDEN '), findsNothing);
    expect(find.text('#weather'), findsNothing);
  });

  testWidgets('favorited contacts and channels sort above the rest', (
    tester,
  ) async {
    final connector = MeshCoreConnector();
    addTearDown(connector.dispose);
    final settingsService = AppSettingsService();

    connector.addContactForTest(contact('Zed Contact'));
    connector.addContactForTest(contact('Alice Favorite', isFavorite: true));
    connector.addChannelForTest(
      Channel(index: 0, name: '#zzz-channel', psk: Uint8List(16)),
    );
    connector.addChannelForTest(
      Channel(
        index: 1,
        name: '#aaa-favorite',
        psk: Uint8List(16),
        isFavorite: true,
      ),
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<MeshCoreConnector>.value(value: connector),
          ChangeNotifierProvider<AppSettingsService>.value(
            value: settingsService,
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ChatsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final favoriteContactY = dyOf(tester, 'Alice Favorite');
    final favoriteChannelY = dyOf(tester, '#aaa-favorite');
    final plainContactY = dyOf(tester, 'Zed Contact');
    final plainChannelY = dyOf(tester, '#zzz-channel');

    expect(favoriteContactY, lessThan(plainContactY));
    expect(favoriteContactY, lessThan(plainChannelY));
    expect(favoriteChannelY, lessThan(plainContactY));
    expect(favoriteChannelY, lessThan(plainChannelY));
  });
}

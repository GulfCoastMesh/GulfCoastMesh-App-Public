import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_connector.dart';
import 'package:gulf_coast_mesh_app/l10n/app_localizations.dart';
import 'package:gulf_coast_mesh_app/models/channel.dart';
import 'package:gulf_coast_mesh_app/models/contact.dart';
import 'package:gulf_coast_mesh_app/screens/channel_chat_screen.dart';
import 'package:gulf_coast_mesh_app/screens/chat_screen.dart';
import 'package:gulf_coast_mesh_app/screens/contacts_screen.dart';
import 'package:gulf_coast_mesh_app/services/app_settings_service.dart';
import 'package:gulf_coast_mesh_app/services/notification_navigator.dart';
import 'package:gulf_coast_mesh_app/services/path_history_service.dart';
import 'package:gulf_coast_mesh_app/services/storage_service.dart';
import 'package:gulf_coast_mesh_app/storage/prefs_manager.dart';
import 'package:gulf_coast_mesh_app/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/node_blocking_fixtures.dart';

/// A live device session. While connected the main page cannot be left,
/// which is the condition the stuck node list depended on.
class _SessionConnector extends MeshCoreConnector {
  bool connected = true;

  @override
  bool get isConnected => connected;

  @override
  bool get shouldKeepHub => connected;

  void setConnected(bool value) {
    connected = value;
    notifyListeners();
  }
}

/// Stands in for HomeScreen, which refuses to pop while connected.
class _MainPage extends StatelessWidget {
  const _MainPage({this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Column(
          children: [
            const Text('Main page'),
            if (child != null) Expanded(child: child!),
          ],
        ),
      ),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _SessionConnector connector;
  late AppSettingsService settings;
  late PathHistoryService pathHistory;
  late GlobalKey<NavigatorState> navigatorKey;
  late NotificationNavigator notifications;
  late Contact alice;
  late Contact bob;
  late Channel ops;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PrefsManager.reset();
    await PrefsManager.initialize();
    connector = _SessionConnector();
    settings = AppSettingsService();
    pathHistory = PathHistoryService(StorageService());
    connector.attachAppSettingsServiceForTest(settings);
    alice = blockingTestContact('Alice', seed: 1);
    bob = blockingTestContact('Bob', seed: 2);
    ops = Channel(index: 3, name: 'Ops', psk: Uint8List(16));
    connector.addContactForTest(alice);
    connector.addContactForTest(bob);
    connector.addChannelForTest(ops);
    navigatorKey = GlobalKey<NavigatorState>();
    notifications = NotificationNavigator(
      navigatorKey: navigatorKey,
      connector: connector,
    );
  });

  tearDown(() {
    connector.dispose();
    settings.dispose();
    pathHistory.dispose();
    PrefsManager.reset();
  });

  Future<void> pumpApp(
    WidgetTester tester, {
    Widget home = const _MainPage(),
  }) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<MeshCoreConnector>.value(value: connector),
          ChangeNotifierProvider<AppSettingsService>.value(value: settings),
          ChangeNotifierProvider<PathHistoryService>.value(value: pathHistory),
        ],
        child: MaterialApp(
          navigatorKey: navigatorKey,
          theme: AppTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: home,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapNotification(WidgetTester tester, String payload) async {
    expect(notifications.open(payload), isTrue, reason: payload);
    await tester.pumpAndSettle();
  }

  Future<void> pressBackButton(WidgetTester tester) async {
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
  }

  Future<void> useSystemBack(WidgetTester tester) async {
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
  }

  void expectOnMainPage() {
    expect(find.text('Main page'), findsOneWidget);
    expect(navigatorKey.currentState!.canPop(), isFalse);
  }

  Finder anywhere(Type type) => find.byType(type, skipOffstage: false);

  group('advert notification', () {
    testWidgets('opens a node list the back button leaves while connected', (
      tester,
    ) async {
      await pumpApp(tester);
      await tapNotification(tester, 'advert:${alice.publicKeyHex}');
      expect(find.byType(ContactsScreen), findsOneWidget);

      await pressBackButton(tester);
      expect(find.byType(ContactsScreen), findsNothing);
      expectOnMainPage();
    });

    testWidgets('opens a node list system back leaves while connected', (
      tester,
    ) async {
      await pumpApp(tester);
      await tapNotification(tester, 'advert:${alice.publicKeyHex}');
      expect(find.byType(ContactsScreen), findsOneWidget);

      await useSystemBack(tester);
      expect(find.byType(ContactsScreen), findsNothing);
      expectOnMainPage();
    });

    testWidgets('another advert tap does not stack a second node list', (
      tester,
    ) async {
      await pumpApp(tester);
      await tapNotification(tester, 'advert:${alice.publicKeyHex}');
      await tapNotification(tester, 'advert:${bob.publicKeyHex}');
      expect(anywhere(ContactsScreen), findsOneWidget);

      await pressBackButton(tester);
      expectOnMainPage();
    });

    testWidgets('the node list tab on the main page does not count as open', (
      tester,
    ) async {
      // HomeScreen keeps every tab mounted in an IndexedStack, so its node
      // list exists even while the chats tab is showing. If that copy counted
      // as in front, advert taps would silently do nothing.
      await pumpApp(
        tester,
        home: const _MainPage(
          child: IndexedStack(
            children: [
              Center(child: Text('Chats tab')),
              ContactsScreen(hideBackButton: true),
            ],
          ),
        ),
      );
      expect(anywhere(ContactsScreen), findsOneWidget);

      await tapNotification(tester, 'advert:${alice.publicKeyHex}');
      expect(anywhere(ContactsScreen), findsNWidgets(2));
      expect(navigatorKey.currentState!.canPop(), isTrue);

      await pressBackButton(tester);
      expect(find.text('Chats tab'), findsOneWidget);
      expectOnMainPage();
    });
  });

  group('message notification', () {
    testWidgets('opens the chat, and back returns to the main page', (
      tester,
    ) async {
      await pumpApp(tester);
      await tapNotification(tester, 'message:${alice.publicKeyHex}');
      expect(find.byType(ChatScreen), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);

      await pressBackButton(tester);
      expect(anywhere(ChatScreen), findsNothing);
      expectOnMainPage();
    });

    testWidgets('system back from the chat returns to the main page', (
      tester,
    ) async {
      await pumpApp(tester);
      await tapNotification(tester, 'message:${alice.publicKeyHex}');

      await useSystemBack(tester);
      expect(anywhere(ChatScreen), findsNothing);
      expectOnMainPage();
    });

    testWidgets('a repeat tap while the chat is in front opens no copy', (
      tester,
    ) async {
      await pumpApp(tester);
      await tapNotification(tester, 'message:${alice.publicKeyHex}');
      await tapNotification(tester, 'message:${alice.publicKeyHex}');
      await tapNotification(tester, 'message:${alice.publicKeyHex}');
      expect(anywhere(ChatScreen), findsOneWidget);

      // One press is enough. With stacked copies it took one per tap, and
      // each press looked like it did nothing.
      await pressBackButton(tester);
      expectOnMainPage();
    });

    testWidgets('a tap for the chat already opened from a list opens no copy', (
      tester,
    ) async {
      await pumpApp(
        tester,
        home: _MainPage(
          child: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ChatScreen(contact: alice),
                ),
              ),
              child: const Text('Open Alice'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open Alice'));
      await tester.pumpAndSettle();
      expect(anywhere(ChatScreen), findsOneWidget);

      await tapNotification(tester, 'message:${alice.publicKeyHex}');
      expect(anywhere(ChatScreen), findsOneWidget);

      await pressBackButton(tester);
      expectOnMainPage();
    });

    testWidgets('a chat shown on the main page itself counts as in front', (
      tester,
    ) async {
      // The wide layout embeds the selected chat in the main page.
      await pumpApp(
        tester,
        home: _MainPage(child: ChatScreen(contact: alice, embedded: true)),
      );
      await tapNotification(tester, 'message:${alice.publicKeyHex}');
      expect(anywhere(ChatScreen), findsOneWidget);
      expectOnMainPage();
    });

    testWidgets('a different chat opens on top, and back walks through both', (
      tester,
    ) async {
      await pumpApp(tester);
      await tapNotification(tester, 'message:${alice.publicKeyHex}');
      await tapNotification(tester, 'message:${bob.publicKeyHex}');
      expect(anywhere(ChatScreen), findsNWidgets(2));
      expect(find.text('Bob'), findsOneWidget);

      await pressBackButton(tester);
      expect(find.text('Alice'), findsOneWidget);

      await pressBackButton(tester);
      expectOnMainPage();
    });

    testWidgets('a chat covered by another page is brought to the front', (
      tester,
    ) async {
      await pumpApp(tester);
      await tapNotification(tester, 'message:${alice.publicKeyHex}');
      navigatorKey.currentState!.push(
        MaterialPageRoute<void>(
          builder: (_) =>
              Scaffold(appBar: AppBar(), body: const Text('Other page')),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ChatScreen), findsNothing);

      await tapNotification(tester, 'message:${alice.publicKeyHex}');
      expect(find.byType(ChatScreen), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('does nothing for a contact the app does not know', (
      tester,
    ) async {
      await pumpApp(tester);
      expect(notifications.open('message:${'ab' * 32}'), isFalse);
      await tester.pumpAndSettle();
      expect(anywhere(ChatScreen), findsNothing);
      expectOnMainPage();
    });
  });

  group('channel notification', () {
    testWidgets('opens the channel, and back returns to the main page', (
      tester,
    ) async {
      await pumpApp(tester);
      await tapNotification(tester, 'channel:${ops.index}');
      expect(find.byType(ChannelChatScreen), findsOneWidget);

      await pressBackButton(tester);
      expect(anywhere(ChannelChatScreen), findsNothing);
      expectOnMainPage();
    });

    testWidgets('a repeat tap while the channel is in front opens no copy', (
      tester,
    ) async {
      await pumpApp(tester);
      await tapNotification(tester, 'channel:${ops.index}');
      await tapNotification(tester, 'channel:${ops.index}');
      expect(anywhere(ChannelChatScreen), findsOneWidget);

      await useSystemBack(tester);
      expectOnMainPage();
    });

    testWidgets('does nothing for an unknown or malformed channel', (
      tester,
    ) async {
      await pumpApp(tester);
      for (final payload in ['channel:7', 'channel:ops', 'channel:']) {
        expect(notifications.open(payload), isFalse, reason: payload);
      }
      await tester.pumpAndSettle();
      expect(anywhere(ChannelChatScreen), findsNothing);
      expectOnMainPage();
    });
  });

  testWidgets('payloads with no page leave the user where they are', (
    tester,
  ) async {
    await pumpApp(tester);
    for (final payload in ['telemetry', 'batch', '', 'message', 'bogus:1']) {
      expect(notifications.open(payload), isFalse, reason: payload);
    }
    await tester.pumpAndSettle();
    expectOnMainPage();
  });

  test('does nothing before the app has a navigator', () {
    final early = NotificationNavigator(
      navigatorKey: GlobalKey<NavigatorState>(),
      connector: connector,
    );
    expect(early.open('message:${alice.publicKeyHex}'), isFalse);
  });

  group('notification that launched the app', () {
    testWidgets('waits for the device to reconnect, then opens on top', (
      tester,
    ) async {
      connector.connected = false;
      await pumpApp(tester);
      notifications.openOnceConnected('message:${alice.publicKeyHex}');

      await tester.pump(const Duration(seconds: 5));
      expect(anywhere(ChatScreen), findsNothing);

      connector.setConnected(true);
      await tester.pump(const Duration(milliseconds: 299));
      expect(anywhere(ChatScreen), findsNothing);
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pumpAndSettle();
      expect(find.byType(ChatScreen), findsOneWidget);

      await pressBackButton(tester);
      expectOnMainPage();
    });

    testWidgets('opens after the settle delay when already connected', (
      tester,
    ) async {
      await pumpApp(tester);
      notifications.openOnceConnected('channel:${ops.index}');

      await tester.pump(const Duration(milliseconds: 299));
      expect(anywhere(ChannelChatScreen), findsNothing);
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pumpAndSettle();
      expect(find.byType(ChannelChatScreen), findsOneWidget);
    });

    testWidgets('gives up if the device does not reconnect in time', (
      tester,
    ) async {
      connector.connected = false;
      await pumpApp(tester);
      notifications.openOnceConnected('message:${alice.publicKeyHex}');

      await tester.pump(const Duration(seconds: 30));
      connector.setConnected(true);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(anywhere(ChatScreen), findsNothing);
      expectOnMainPage();
    });
  });
}

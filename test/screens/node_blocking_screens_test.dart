import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_connector.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_protocol.dart';
import 'package:gulf_coast_mesh_app/l10n/app_localizations.dart';
import 'package:gulf_coast_mesh_app/screens/app_settings_screen.dart';
import 'package:gulf_coast_mesh_app/screens/blocked_nodes_screen.dart';
import 'package:gulf_coast_mesh_app/screens/chats_screen.dart';
import 'package:gulf_coast_mesh_app/services/wardriving_service.dart';
import 'package:gulf_coast_mesh_app/screens/contacts_screen.dart';
import 'package:gulf_coast_mesh_app/services/app_settings_service.dart';
import 'package:gulf_coast_mesh_app/services/blocked_nodes_service.dart';
import 'package:gulf_coast_mesh_app/storage/prefs_manager.dart';
import 'package:gulf_coast_mesh_app/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/node_blocking_fixtures.dart';

class _SessionConnector extends MeshCoreConnector {
  @override
  bool get shouldKeepHub => true;

  @override
  bool get isConnected => true;
}

class _FakeWardriving extends ChangeNotifier implements WardrivingService {
  @override
  bool get canChangeOfflineMode => true;

  @override
  bool get isOfflineMode => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _SessionConnector connector;
  late AppSettingsService settings;
  late BlockedNodesService blocked;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PrefsManager.reset();
    await PrefsManager.initialize();
    connector = _SessionConnector();
    settings = AppSettingsService();
    blocked = BlockedNodesService();
    connector.attachAppSettingsServiceForTest(settings);
    connector.attachBlockedNodesService(blocked);
  });

  tearDown(() {
    connector.dispose();
    settings.dispose();
    blocked.dispose();
    PrefsManager.reset();
  });

  Future<void> pump(
    WidgetTester tester,
    Widget home, {
    List<SingleChildWidget> extraProviders = const [],
  }) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<MeshCoreConnector>.value(value: connector),
          ChangeNotifierProvider<AppSettingsService>.value(value: settings),
          ChangeNotifierProvider<BlockedNodesService>.value(value: blocked),
          ...extraProviders,
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: home,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  // updateSettings awaits a prefs write that never resolves under fake async;
  // the flag itself changes synchronously, which is all the widgets read.
  void setFlag(bool value) =>
      unawaited(settings.setExperimentalNodeBlockingEnabled(value));

  Future<void> blockNode(String name, int seed, int type) => blocked.block(
    publicKeyHex: blockingTestContact(name, seed: seed).publicKeyHex,
    name: name,
    type: type,
  );

  Future<void> pumpSettings(WidgetTester tester) async {
    final wardriving = _FakeWardriving();
    addTearDown(wardriving.dispose);
    await pump(
      tester,
      const AppSettingsScreen(),
      extraProviders: [
        ChangeNotifierProvider<WardrivingService>.value(value: wardriving),
      ],
    );
  }

  group('App Settings > Experimental', () {
    testWidgets('shows the switch; the manager tile only when ON', (
      tester,
    ) async {
      await pumpSettings(tester);
      final switchFinder = find.widgetWithText(SwitchListTile, 'Block nodes');
      await tester.scrollUntilVisible(
        switchFinder,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(switchFinder, findsOneWidget);
      await tester.ensureVisible(switchFinder);
      await tester.pumpAndSettle();
      expect(find.text('Blocked nodes'), findsNothing);

      await tester.tap(switchFinder);
      await tester.pumpAndSettle();
      expect(settings.settings.experimentalNodeBlockingEnabled, isTrue);
      expect(find.text('Blocked nodes'), findsOneWidget);
      expect(find.text('None blocked yet'), findsOneWidget);

      await blockNode('Bayou', 5, advTypeRepeater);
      await tester.pumpAndSettle();
      expect(find.text('1 node blocked'), findsOneWidget);
    });

    testWidgets('weather switch is unchanged and still first', (tester) async {
      await pumpSettings(tester);
      final weather = find.widgetWithText(SwitchListTile, 'Weather display');
      final blockSwitch = find.widgetWithText(SwitchListTile, 'Block nodes');
      await tester.scrollUntilVisible(
        blockSwitch,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(weather, findsOneWidget);
      expect(
        tester.getTopLeft(weather).dy < tester.getTopLeft(blockSwitch).dy,
        isTrue,
      );
    });
  });

  group('BlockedNodesScreen', () {
    testWidgets('empty state and disabled Unblock all', (tester) async {
      await pump(tester, const BlockedNodesScreen());
      expect(find.text('How blocking works'), findsOneWidget);
      expect(find.text('No blocked nodes'), findsOneWidget);
      expect(
        find.text(
          'Long-press a node in Contacts or on the Map and choose Block node.',
        ),
        findsOneWidget,
      );
      final unblockAll = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Unblock all'),
      );
      expect(unblockAll.onPressed, isNull);
    });

    testWidgets('renders entries newest first; Unblock removes one', (
      tester,
    ) async {
      await blockNode('Bayou', 5, advTypeRepeater);
      await tester.pump(const Duration(milliseconds: 5));
      await blockNode('', 6, advTypeSensor);
      await pump(tester, const BlockedNodesScreen());

      expect(find.text('Unknown node'), findsOneWidget);
      expect(find.text('Bayou'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Unknown node')).dy <
            tester.getTopLeft(find.text('Bayou')).dy,
        isTrue,
      );
      expect(find.textContaining('Repeater · 05050505 · Blocked'), findsOne);

      await tester.tap(find.widgetWithText(TextButton, 'Unblock').first);
      await tester.pumpAndSettle();
      expect(blocked.count, 1);
      expect(find.text('Unknown node unblocked'), findsOneWidget);
    });

    testWidgets('Unblock all asks for confirmation then clears', (
      tester,
    ) async {
      await blockNode('A', 5, advTypeRepeater);
      await blockNode('B', 6, advTypeChat);
      await pump(tester, const BlockedNodesScreen());

      await tester.tap(find.widgetWithText(TextButton, 'Unblock all'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Unblock all 2 nodes?'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(blocked.count, 2);

      await tester.tap(find.widgetWithText(TextButton, 'Unblock all'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.widgetWithText(TextButton, 'Unblock all'),
        ),
      );
      await tester.pumpAndSettle();
      expect(blocked.count, 0);
      expect(find.text('No blocked nodes'), findsOneWidget);
    });
  });

  group('ContactsScreen', () {
    final alice = blockingTestContact('Alice', seed: 1);
    final bayou = blockingTestContact('Bayou', seed: 2);

    setUp(() {
      connector.addContactForTest(alice);
      connector.addContactForTest(bayou);
    });

    testWidgets('long-press sheet shows Block node only when ON', (
      tester,
    ) async {
      await pump(tester, const ContactsScreen());
      await tester.longPress(find.text('Alice'));
      await tester.pumpAndSettle();
      expect(find.text('Block node'), findsNothing);
      expect(find.text('Delete Contact'), findsOneWidget);

      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      setFlag(true);
      await tester.pumpAndSettle();
      await tester.longPress(find.text('Alice'));
      await tester.pumpAndSettle();
      expect(find.text('Block node'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Block node')).dy <
            tester.getTopLeft(find.text('Delete Contact')).dy,
        isTrue,
      );
    });

    testWidgets('blocking via the sheet hides the node, Undo restores it', (
      tester,
    ) async {
      setFlag(true);
      await pump(tester, const ContactsScreen());
      await tester.longPress(find.text('Bayou'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Block node'));
      await tester.pumpAndSettle();
      expect(find.text('Block Bayou?'), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Block'));
      await tester.pumpAndSettle();

      expect(find.text('Bayou'), findsNothing);
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bayou blocked'), findsOneWidget);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(find.text('Bayou'), findsOneWidget);
      expect(blocked.count, 0);
    });

    testWidgets('blocked contact is hidden when ON, shown when OFF', (
      tester,
    ) async {
      await blocked.block(
        publicKeyHex: alice.publicKeyHex,
        name: 'Alice',
        type: advTypeChat,
      );
      await pump(tester, const ContactsScreen());
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bayou'), findsOneWidget);

      setFlag(true);
      await tester.pumpAndSettle();
      expect(find.text('Alice'), findsNothing);
      expect(find.text('Bayou'), findsOneWidget);

      await blocked.unblock(alice.publicKeyHex);
      await tester.pumpAndSettle();
      expect(find.text('Alice'), findsOneWidget);

      await blocked.block(
        publicKeyHex: alice.publicKeyHex,
        name: 'Alice',
        type: advTypeChat,
      );
      setFlag(false);
      await tester.pumpAndSettle();
      expect(find.text('Alice'), findsOneWidget);
    });
  });

  group('ChatsScreen', () {
    testWidgets('hides the direct conversation of a blocked node', (
      tester,
    ) async {
      final alice = blockingTestContact('Alice', seed: 1);
      final carol = blockingTestContact('Carol', seed: 3);
      connector.addContactForTest(alice);
      connector.addContactForTest(carol);
      setFlag(true);
      await pump(tester, const ChatsScreen());
      expect(find.text('Alice'), findsOneWidget);

      await blocked.block(
        publicKeyHex: alice.publicKeyHex,
        name: 'Alice',
        type: advTypeChat,
      );
      await tester.pumpAndSettle();
      expect(find.text('Alice'), findsNothing);
      expect(find.text('Carol'), findsOneWidget);

      setFlag(false);
      await tester.pumpAndSettle();
      expect(find.text('Alice'), findsOneWidget);
    });
  });
}

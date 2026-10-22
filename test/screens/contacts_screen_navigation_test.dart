import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_connector.dart';
import 'package:gulf_coast_mesh_app/l10n/app_localizations.dart';
import 'package:gulf_coast_mesh_app/screens/contacts_screen.dart';
import 'package:gulf_coast_mesh_app/services/app_settings_service.dart';
import 'package:gulf_coast_mesh_app/storage/prefs_manager.dart';
import 'package:gulf_coast_mesh_app/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _SessionConnector extends MeshCoreConnector {
  _SessionConnector({this.reconnecting = false});

  final bool reconnecting;

  @override
  bool get shouldKeepHub => true;

  @override
  bool get isConnected => !reconnecting;

  @override
  bool get isReconnecting => reconnecting;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PrefsManager.reset();
    await PrefsManager.initialize();
  });
  tearDown(PrefsManager.reset);

  Future<void> openContacts(
    WidgetTester tester, {
    bool hideBackButton = false,
    bool reconnecting = false,
  }) async {
    final connector = _SessionConnector(reconnecting: reconnecting);
    final settings = AppSettingsService();
    addTearDown(connector.dispose);
    addTearDown(settings.dispose);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<MeshCoreConnector>.value(value: connector),
          ChangeNotifierProvider<AppSettingsService>.value(value: settings),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        ContactsScreen(hideBackButton: hideBackButton),
                  ),
                ),
                child: const Text('Open Contacts notification'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open Contacts notification'));
    await tester.pumpAndSettle();
    expect(find.byType(ContactsScreen), findsOneWidget);
  }

  testWidgets(
    'pushed Contacts notification has a working app-bar back button',
    (tester) async {
      await openContacts(tester);
      expect(find.byType(BackButton), findsOneWidget);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('Open Contacts notification'), findsOneWidget);
      expect(find.byType(ContactsScreen), findsNothing);
    },
  );

  for (final reconnecting in [false, true]) {
    testWidgets(
      'pushed Contacts notification allows system back (reconnecting=$reconnecting)',
      (tester) async {
        await openContacts(tester, reconnecting: reconnecting);
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.text('Open Contacts notification'), findsOneWidget);
        expect(find.byType(ContactsScreen), findsNothing);
      },
    );
  }

  testWidgets('hub Contacts view does not expose route back navigation', (
    tester,
  ) async {
    await openContacts(tester, hideBackButton: true);
    expect(find.byType(BackButton), findsNothing);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(ContactsScreen), findsOneWidget);
    expect(find.text('Open Contacts notification'), findsNothing);
  });
}

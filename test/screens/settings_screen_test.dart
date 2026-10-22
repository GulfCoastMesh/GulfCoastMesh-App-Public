import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_connector.dart';
import 'package:gulf_coast_mesh_app/l10n/app_localizations.dart';
import 'package:gulf_coast_mesh_app/screens/settings_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('node-name update reports success after dialog closes', (
    tester,
  ) async {
    PackageInfo.setMockInitialValues(
      appName: 'MeshCore',
      packageName: 'meshcore.test',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
    final connector = _SettingsConnector();
    addTearDown(connector.dispose);

    await tester.pumpWidget(
      ChangeNotifierProvider<MeshCoreConnector>.value(
        value: connector,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final nodeNameTile = find.widgetWithText(ListTile, 'Node Name');
    await tester.ensureVisible(nodeNameTile);
    await tester.tap(nodeNameTile);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Updated node');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(connector.updatedName, 'Updated node');
    expect(find.text('Name updated'), findsOneWidget);
  });

  testWidgets('about dialog credits the developers', (tester) async {
    PackageInfo.setMockInitialValues(
      appName: 'MeshCore',
      packageName: 'meshcore.test',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
    final connector = _SettingsConnector();
    addTearDown(connector.dispose);

    await tester.pumpWidget(
      ChangeNotifierProvider<MeshCoreConnector>.value(
        value: connector,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final aboutTitle = find.text('About');
    await tester.scrollUntilVisible(aboutTitle, 200);
    await tester.pumpAndSettle();
    await tester.tap(aboutTitle);
    await tester.pumpAndSettle();

    expect(find.text('Developed by '), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'ScarlettOSA'), findsOneWidget);
    expect(find.text(' and J'), findsOneWidget);
  });
}

class _SettingsConnector extends MeshCoreConnector {
  String? updatedName;

  @override
  String? get selfName => updatedName ?? 'Original node';

  @override
  Future<void> setNodeName(String name) async {
    updatedName = name;
  }

  @override
  Future<void> refreshDeviceInfo() async {}
}

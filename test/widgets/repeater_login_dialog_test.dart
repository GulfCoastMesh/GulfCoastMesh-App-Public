import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_connector.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_protocol.dart';
import 'package:gulf_coast_mesh_app/l10n/app_localizations.dart';
import 'package:gulf_coast_mesh_app/models/contact.dart';
import 'package:gulf_coast_mesh_app/services/storage_service.dart';
import 'package:gulf_coast_mesh_app/storage/prefs_manager.dart';
import 'package:gulf_coast_mesh_app/storage/secure_password_store.dart';
import 'package:gulf_coast_mesh_app/widgets/repeater_login_dialog.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _DelayedPasswordStore implements SecurePasswordStore {
  _DelayedPasswordStore(this._password);

  final String _password;
  final Completer<String?> readCompleter = Completer<String?>();

  @override
  Future<void> delete(String key) async {}

  @override
  Future<String?> read(String key) => readCompleter.future;

  @override
  Future<Map<String, String>> readAll() async => {};

  @override
  Future<void> write(String key, String value) async {}

  void complete() => readCompleter.complete(_password);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final repeater = Contact(
    publicKey: Uint8List.fromList(List<int>.filled(32, 1)),
    name: 'Test repeater',
    type: advTypeRepeater,
    pathLength: 0,
    path: Uint8List(0),
    lastSeen: DateTime(2026),
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PrefsManager.reset();
    await PrefsManager.initialize();
  });

  tearDown(PrefsManager.reset);

  Widget buildApp(Widget home) {
    return ChangeNotifierProvider<MeshCoreConnector>.value(
      value: MeshCoreConnector(),
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: home,
      ),
    );
  }

  Widget buildDialog({String? initialPassword}) {
    return buildApp(
      Scaffold(
        body: RepeaterLoginDialog(
          repeater: repeater,
          initialPassword: initialPassword,
          onLogin: (_) {},
        ),
      ),
    );
  }

  testWidgets('keeps first typed character and focus', (tester) async {
    await tester.pumpWidget(buildDialog());

    final field = find.byKey(const ValueKey('repeater_login_password'));
    await tester.tap(field);
    await tester.enterText(field, 'p');
    await tester.pump();

    final textField = tester.widget<TextField>(field);
    expect(textField.controller!.text, 'p');
    expect(textField.focusNode!.hasFocus, isTrue);
    expect(textField.autofillHints, isNull);
  });

  testWidgets('prefills a saved password before the user interacts', (
    tester,
  ) async {
    await tester.pumpWidget(buildDialog(initialPassword: 'saved-password'));

    final field = find.byKey(const ValueKey('repeater_login_password'));
    expect(tester.widget<TextField>(field).controller!.text, 'saved-password');
  });

  testWidgets('does not mount an editable password field until preload ends', (
    tester,
  ) async {
    final store = _DelayedPasswordStore('saved-password');
    final storage = StorageService(passwordStore: store);
    await tester.pumpWidget(buildApp(const Scaffold(body: SizedBox())));

    unawaited(
      RepeaterLoginDialog.show(
        tester.element(find.byType(Scaffold)),
        repeater: repeater,
        storage: storage,
        onLogin: (_) {},
      ),
    );
    await tester.pump();

    final field = find.byKey(const ValueKey('repeater_login_password'));
    expect(field, findsNothing);

    store.complete();
    await tester.pump();
    await tester.pump();

    expect(tester.widget<TextField>(field).controller!.text, 'saved-password');
  });
}

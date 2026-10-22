import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_connector.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_protocol.dart';
import 'package:gulf_coast_mesh_app/l10n/app_localizations.dart';
import 'package:gulf_coast_mesh_app/models/contact.dart';
import 'package:gulf_coast_mesh_app/widgets/contact_detail_panel.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('labels the repeater action as manage repeater', (tester) async {
    final repeater = Contact(
      publicKey: Uint8List.fromList(List<int>.filled(32, 1)),
      name: 'Test repeater',
      type: advTypeRepeater,
      pathLength: 0,
      path: Uint8List(0),
      lastSeen: DateTime(2026),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<MeshCoreConnector>.value(
        value: MeshCoreConnector(),
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ContactDetailPanel(contact: repeater),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Manage Repeater'), findsOneWidget);
    expect(find.text('Send Message'), findsNothing);
  });
}

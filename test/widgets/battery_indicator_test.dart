import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_connector.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_protocol.dart';
import 'package:gulf_coast_mesh_app/theme/app_theme.dart';
import 'package:gulf_coast_mesh_app/widgets/battery_indicator.dart';

Uint8List _batteryFrame(int millivolts) => Uint8List.fromList([
  respCodeBattAndStorage,
  millivolts & 0xff,
  millivolts >> 8,
]);

void main() {
  testWidgets('hides the app bar battery indicator for a zero voltage', (
    tester,
  ) async {
    final connector = MeshCoreConnector();
    addTearDown(connector.dispose);
    connector.handleFrameForTest(_batteryFrame(0));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: BatteryIndicator(connector: connector)),
      ),
    );

    expect(find.byType(InkWell), findsNothing);
  });

  testWidgets('shows the app bar battery indicator for a reported voltage', (
    tester,
  ) async {
    final connector = MeshCoreConnector();
    addTearDown(connector.dispose);
    connector.handleFrameForTest(_batteryFrame(4100));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: BatteryIndicator(connector: connector)),
      ),
    );

    expect(find.byType(InkWell), findsOneWidget);
    expect(find.text('${connector.batteryPercent}%'), findsOneWidget);
    await tester.tap(find.byType(InkWell));
    await tester.pump();
    expect(find.text('4.10V'), findsOneWidget);
    await tester.tap(find.byType(InkWell));
    await tester.pump();
    expect(find.text('${connector.batteryPercent}%'), findsOneWidget);
  });
}

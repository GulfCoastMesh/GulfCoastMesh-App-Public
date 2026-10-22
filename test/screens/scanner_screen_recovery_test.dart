import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// The plugin platform interface lets these tests run without Bluetooth hardware.
// ignore: depend_on_referenced_packages
import 'package:flutter_blue_plus_platform_interface/flutter_blue_plus_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_connector.dart';
import 'package:gulf_coast_mesh_app/l10n/app_localizations.dart';
import 'package:gulf_coast_mesh_app/screens/scanner_screen.dart';
import 'package:gulf_coast_mesh_app/services/connection_profile_service.dart';
import 'package:gulf_coast_mesh_app/storage/prefs_manager.dart';
import 'package:gulf_coast_mesh_app/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    FlutterBluePlusPlatform.instance = _BluetoothPlatform();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({'support_prompt_shown': true});
    PrefsManager.reset();
    await PrefsManager.initialize();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
          (call) async => call.method == 'readAll' ? <String, String>{} : null,
        );
  });

  Future<_ScannerConnector> showScanner(WidgetTester tester) async {
    final connector = _ScannerConnector();
    final profiles = ConnectionProfileService();
    addTearDown(connector.dispose);
    addTearDown(profiles.dispose);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<MeshCoreConnector>.value(value: connector),
          ChangeNotifierProvider<ConnectionProfileService>.value(
            value: profiles,
          ),
        ],
        child: MaterialApp(
          theme: ThemeData(extensions: [AppColors.light]),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ScannerScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return connector;
  }

  testWidgets('failed discovery is shown and Scan can be retried', (
    tester,
  ) async {
    final connector = await showScanner(tester);
    connector.startError = Exception('Bluetooth adapter unavailable');

    await tester.tap(find.text('Scan'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      find.text('Connection failed: Exception: Bluetooth adapter unavailable'),
      findsOneWidget,
    );
    expect(find.text('Scan'), findsOneWidget);

    connector.startError = null;
    await tester.tap(find.text('Scan'));
    await tester.pump();

    expect(connector.starts, [
      MeshCoreTransportKind.ble,
      MeshCoreTransportKind.ble,
    ]);
    expect(find.text('Stop'), findsOneWidget);
    expect(
      tester
          .widget<FloatingActionButton>(find.byType(FloatingActionButton))
          .onPressed,
      isNotNull,
    );

    await tester.tap(find.text('Stop'));
    await tester.pumpAndSettle();
    expect(find.text('Scan'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('USB stop completes before Bluetooth can start scanning', (
    tester,
  ) async {
    final connector = await showScanner(tester);
    await tester.tap(find.text('USB'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Refresh'));
    await tester.pump();
    connector.stopGate = Completer<void>();

    await tester.tap(find.text('Bluetooth'));
    await tester.pump();

    expect(
      tester
          .widget<SegmentedButton<MeshCoreTransportKind>>(
            find.byType(SegmentedButton<MeshCoreTransportKind>),
          )
          .selected,
      {MeshCoreTransportKind.usb},
    );
    expect(
      tester
          .widget<FloatingActionButton>(find.byType(FloatingActionButton))
          .onPressed,
      isNull,
    );
    expect(connector.starts, [MeshCoreTransportKind.usb]);

    connector.stopGate!.complete();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Scan'));
    await tester.pump();

    expect(connector.events, [
      'stop ble',
      'stopped ble',
      'start usb',
      'stop usb',
      'stopped usb',
      'finished usb',
      'start ble',
    ]);
    await tester.tap(find.text('Stop'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('failed transport stop keeps the selection recoverable', (
    tester,
  ) async {
    final connector = await showScanner(tester);
    await tester.tap(find.text('USB'));
    await tester.pumpAndSettle();
    connector.stopError = Exception('USB stop failed');

    await tester.tap(find.text('Bluetooth'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      find.text('Connection failed: Exception: USB stop failed'),
      findsOneWidget,
    );
    expect(find.text('Refresh'), findsOneWidget);

    connector.stopError = null;
    await tester.tap(find.text('Bluetooth'));
    await tester.pumpAndSettle();
    expect(find.text('Scan'), findsOneWidget);
  });

  testWidgets('late canceled discovery does not block a new transport', (
    tester,
  ) async {
    final connector = await showScanner(tester);
    await tester.tap(find.text('USB'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Refresh'));
    await tester.pump();
    final oldScan = connector._scan!;
    connector.completeScanOnStop = false;

    await tester.tap(find.text('Bluetooth'));
    await tester.pumpAndSettle();
    expect(find.text('Scan'), findsOneWidget);

    await tester.tap(find.text('Scan'));
    await tester.pump();
    oldScan.completeError(Exception('Canceled USB discovery failed'));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(SnackBar), findsNothing);
    expect(find.text('Stop'), findsOneWidget);

    connector.completeScanOnStop = true;
    await tester.tap(find.text('Stop'));
    await tester.pumpAndSettle();
  });
}

final class _BluetoothPlatform extends FlutterBluePlusPlatform {
  @override
  Future<BmBluetoothAdapterState> getAdapterState(
    BmBluetoothAdapterStateRequest request,
  ) async => BmBluetoothAdapterState(adapterState: BmAdapterStateEnum.on);
}

class _ScannerConnector extends MeshCoreConnector {
  final starts = <MeshCoreTransportKind>[];
  final events = <String>[];
  Object? startError;
  Object? stopError;
  Completer<void>? stopGate;
  bool completeScanOnStop = true;
  Completer<void>? _scan;
  MeshCoreConnectionState _scannerState = MeshCoreConnectionState.disconnected;

  @override
  MeshCoreConnectionState get state => _scannerState;

  @override
  Future<void> startDiscovery(
    MeshCoreTransportKind kind, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    starts.add(kind);
    events.add('start ${kind.name}');
    if (startError case final error?) throw error;
    _scan = Completer<void>();
    _scannerState = MeshCoreConnectionState.scanning;
    notifyListeners();
    await _scan!.future;
    events.add('finished ${kind.name}');
    _scannerState = MeshCoreConnectionState.disconnected;
    notifyListeners();
  }

  @override
  Future<void> stopDiscovery(MeshCoreTransportKind kind) async {
    events.add('stop ${kind.name}');
    await stopGate?.future;
    if (stopError case final error?) throw error;
    events.add('stopped ${kind.name}');
    _scannerState = MeshCoreConnectionState.disconnected;
    notifyListeners();
    if (_scan case final scan? when completeScanOnStop && !scan.isCompleted) {
      scan.complete();
    }
  }
}

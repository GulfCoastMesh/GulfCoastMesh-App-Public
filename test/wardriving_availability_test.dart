import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/models/wardriving.dart';
import 'package:gulf_coast_mesh_app/services/wardriving_service.dart';

void main() {
  Map<WardrivingMode, WardrivingModeAvailability> evaluate({
    bool connected = true,
    bool apiConfigured = true,
    bool gpsAvailable = true,
    bool offline = false,
    bool hasSession = true,
    bool txAllowed = true,
    bool floodDisabled = false,
    bool hybridEnforced = false,
    String target = 'AABB',
    bool targetExists = true,
    bool zoneRestricted = false,
  }) => WardrivingService.evaluateModeAvailability(
    connected: connected,
    apiConfigured: apiConfigured,
    gpsAvailable: gpsAvailable,
    offline: offline,
    hasSession: hasSession,
    txAllowed: txAllowed,
    floodDisabled: floodDisabled,
    hybridEnforced: hybridEnforced,
    targetRepeaterId: target,
    targetExists: targetExists,
    zoneRestricted: zoneRestricted,
  );

  test('maps connection, API, GPS, zone, and session gates', () {
    expect(
      evaluate(connected: false)[WardrivingMode.passive]!.reason,
      contains('Connect'),
    );
    expect(
      evaluate(apiConfigured: false)[WardrivingMode.passive]!.reason,
      contains('API'),
    );
    expect(
      evaluate(gpsAvailable: false)[WardrivingMode.passive]!.reason,
      contains('GPS'),
    );
    expect(
      evaluate(zoneRestricted: true)[WardrivingMode.passive]!.reason,
      contains('coverage'),
    );
    expect(
      evaluate(txAllowed: false)[WardrivingMode.active]!.reason,
      contains('TX'),
    );
    expect(
      evaluate(floodDisabled: true)[WardrivingMode.hybrid]!.reason,
      contains('Flood'),
    );
    expect(
      evaluate(floodDisabled: true)[WardrivingMode.targeted]!.enabled,
      isTrue,
      reason: 'A targeted trace does not flood the channel',
    );
    expect(
      evaluate(txAllowed: false)[WardrivingMode.targeted]!.reason,
      contains('TX'),
    );
    expect(
      evaluate(hybridEnforced: true)[WardrivingMode.active]!.reason,
      contains('Hybrid'),
    );
  });

  test('requires a target and allows offline operation without API', () {
    expect(
      evaluate(
        target: '',
        targetExists: false,
      )[WardrivingMode.targeted]!.reason,
      contains('target'),
    );
    expect(
      evaluate(
        target: 'AABB',
        targetExists: false,
      )[WardrivingMode.targeted]!.reason,
      contains('unavailable'),
    );
    final offline = evaluate(
      offline: true,
      apiConfigured: false,
      hasSession: false,
      txAllowed: false,
    );
    expect(offline[WardrivingMode.active]!.enabled, isTrue);
    expect(offline[WardrivingMode.hybrid]!.enabled, isTrue);
  });
}

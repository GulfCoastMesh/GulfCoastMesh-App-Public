import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gulf_coast_mesh_app/connector/meshcore_device.dart';
import 'package:gulf_coast_mesh_app/models/connection_profile.dart';
import 'package:gulf_coast_mesh_app/storage/connection_profile_store.dart';
import 'package:gulf_coast_mesh_app/storage/prefs_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ConnectionProfileStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PrefsManager.reset();
    await PrefsManager.initialize();
    store = ConnectionProfileStore();
  });

  tearDown(() {
    PrefsManager.reset();
  });

  test('round-trips every transport kind and field', () async {
    final saved = DateTime.utc(2026, 3, 4, 5, 6, 7);
    final profiles = [
      ConnectionProfile(
        id: 'a',
        name: 'Base station',
        transportKind: MeshCoreTransportKind.ble,
        address: 'AA:BB:CC:DD:EE:FF',
        autoConnect: true,
        lastConnectedAt: saved,
      ),
      const ConnectionProfile(
        id: 'b',
        name: 'Bench radio',
        transportKind: MeshCoreTransportKind.usb,
        address: '/dev/ttyUSB0',
      ),
      const ConnectionProfile(
        id: 'c',
        name: 'Roof node',
        transportKind: MeshCoreTransportKind.tcp,
        address: '192.168.1.50:5000',
        autoConnect: true,
      ),
    ];

    await store.saveProfiles(profiles);
    final loaded = await store.loadProfiles();

    expect(loaded, profiles);
    expect(loaded[0].lastConnectedAt, saved);
    expect(loaded[1].autoConnect, isFalse);
    expect(loaded[2].transportKind, MeshCoreTransportKind.tcp);
  });

  test('returns empty when nothing was ever saved', () async {
    expect(await store.loadProfiles(), isEmpty);
  });

  test('skips malformed records instead of dropping the whole list', () async {
    PrefsManager.instance.setString(
      'connection_profiles_v1',
      jsonEncode([
        {'id': 'ok', 'name': 'Good', 'transport': 'usb', 'address': '/dev/x'},
        {'id': '', 'transport': 'usb', 'address': '/dev/y'}, // empty id
        {'id': 'no-address', 'transport': 'usb'}, // missing address
        {'id': 'bad-kind', 'transport': 'zigbee', 'address': '/dev/z'},
        'not even an object',
      ]),
    );

    final loaded = await store.loadProfiles();

    expect(loaded, hasLength(1));
    expect(loaded.single.id, 'ok');
  });

  test('falls back to empty on corrupt JSON rather than throwing', () async {
    PrefsManager.instance.setString('connection_profiles_v1', '{not json');
    expect(await store.loadProfiles(), isEmpty);
  });

  test('name defaults to the address when absent', () async {
    PrefsManager.instance.setString(
      'connection_profiles_v1',
      jsonEncode([
        {'id': 'x', 'transport': 'tcp', 'address': 'roof.local:5000'},
      ]),
    );

    final loaded = await store.loadProfiles();
    expect(loaded.single.name, 'roof.local:5000');
  });

  test(
    'copyWith can clear lastConnectedAt but leaves it alone by default',
    () async {
      final profile = ConnectionProfile(
        id: 'a',
        name: 'Node',
        transportKind: MeshCoreTransportKind.tcp,
        address: 'host',
        lastConnectedAt: DateTime.utc(2026, 1, 1),
      );

      expect(profile.copyWith(name: 'Renamed').lastConnectedAt, isNotNull);
      expect(profile.copyWith(lastConnectedAt: null).lastConnectedAt, isNull);
    },
  );

  test('toDevice carries the address and kind the transport needs', () {
    const profile = ConnectionProfile(
      id: 'a',
      name: 'Roof node',
      transportKind: MeshCoreTransportKind.tcp,
      address: '192.168.1.50:5000',
    );

    final device = profile.toDevice();
    expect(device.id, '192.168.1.50:5000');
    expect(device.displayName, 'Roof node');
    expect(device.transportKind, MeshCoreTransportKind.tcp);
    expect(device.rssi, isNull);
  });
}

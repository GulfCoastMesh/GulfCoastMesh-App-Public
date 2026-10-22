import 'dart:async';

import 'package:flutter/foundation.dart';

import '../connector/meshcore_connector.dart';
import '../models/connection_profile.dart';
import '../storage/connection_profile_store.dart';

/// Owns saved connection profiles and the opt-in auto-connect policy.
///
/// Deliberately separate from [MeshCoreConnector], which is already the app's
/// largest class; this only decides *which* device to hand it.
class ConnectionProfileService extends ChangeNotifier {
  ConnectionProfileService({ConnectionProfileStore? store})
    : _store = store ?? ConnectionProfileStore();

  final ConnectionProfileStore _store;
  final List<ConnectionProfile> _profiles = [];

  bool _autoConnectInFlight = false;
  bool _launchAutoConnectDone = false;
  String? _lastAutoConnectError;

  List<ConnectionProfile> get profiles => List.unmodifiable(_profiles);

  /// Profiles the user explicitly opted into auto-connect for, most recently
  /// used first — nothing else is ever dialled unattended.
  List<ConnectionProfile> get autoConnectProfiles {
    final enabled = _profiles.where((p) => p.autoConnect).toList();
    enabled.sort((a, b) {
      final aTime = a.lastConnectedAt;
      final bTime = b.lastConnectedAt;
      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;
      return bTime.compareTo(aTime);
    });
    return enabled;
  }

  bool get isAutoConnecting => _autoConnectInFlight;

  /// Why the last auto-connect sweep gave up, for display. Null when the last
  /// sweep succeeded or never ran.
  String? get lastAutoConnectError => _lastAutoConnectError;

  ConnectionProfile? profileForDevice(MeshCoreDevice device) {
    for (final profile in _profiles) {
      if (profile.address == device.id &&
          profile.transportKind == device.transportKind) {
        return profile;
      }
    }
    return null;
  }

  Future<void> load() async {
    _profiles
      ..clear()
      ..addAll(await _store.loadProfiles());
    notifyListeners();
  }

  Future<ConnectionProfile> saveProfile(ConnectionProfile profile) async {
    final index = _profiles.indexWhere((p) => p.id == profile.id);
    if (index >= 0) {
      _profiles[index] = profile;
    } else {
      _profiles.add(profile);
    }
    await _persist();
    return profile;
  }

  /// Saves a discovered device as a named profile, or updates the existing
  /// profile for that address rather than creating a duplicate.
  Future<ConnectionProfile> saveDevice(
    MeshCoreDevice device, {
    String? name,
    bool autoConnect = false,
  }) async {
    final existing = profileForDevice(device);
    final profile =
        existing?.copyWith(
          name: name ?? existing.name,
          autoConnect: autoConnect,
        ) ??
        ConnectionProfile(
          id: '${device.transportKind.name}:${device.id}',
          name: name?.trim().isNotEmpty == true
              ? name!.trim()
              : device.displayName,
          transportKind: device.transportKind,
          address: device.id,
          autoConnect: autoConnect,
        );
    return saveProfile(profile);
  }

  Future<void> removeProfile(String id) async {
    _profiles.removeWhere((profile) => profile.id == id);
    await _persist();
  }

  Future<void> setAutoConnect(String id, bool enabled) async {
    final index = _profiles.indexWhere((profile) => profile.id == id);
    if (index < 0) return;
    if (_profiles[index].autoConnect == enabled) return;
    _profiles[index] = _profiles[index].copyWith(autoConnect: enabled);
    await _persist();
  }

  /// Stamps the profile matching [device], if any, after a successful connect
  /// so auto-connect can prefer the most recently working endpoint.
  Future<void> recordConnection(MeshCoreDevice device) async {
    final existing = profileForDevice(device);
    if (existing == null) return;
    await saveProfile(existing.copyWith(lastConnectedAt: DateTime.now()));
  }

  Future<void> _persist() async {
    await _store.saveProfiles(_profiles);
    notifyListeners();
  }

  /// One auto-connect sweep per app launch.
  ///
  /// Deliberately not repeated when the scanner is shown again: after a manual
  /// disconnect the user is on the scanner *because* they wanted off the mesh,
  /// and redialling underneath them would fight that.
  Future<bool> tryLaunchAutoConnect(MeshCoreConnector connector) async {
    if (_launchAutoConnectDone) return false;
    _launchAutoConnectDone = true;
    return tryAutoConnect(connector);
  }

  /// Tries each opt-in profile until one connects.
  ///
  /// For BLE and USB the device must actually show up in a discovery pass
  /// first — dialling an absent BLE remote id burns the full connect timeout
  /// for nothing. TCP has no discovery, so its endpoints are dialled directly
  /// and fail fast on their own connect timeout.
  ///
  /// Returns true when a session was established.
  Future<bool> tryAutoConnect(MeshCoreConnector connector) async {
    if (_autoConnectInFlight) return false;
    if (connector.isDemoMode) return false;
    if (connector.state != MeshCoreConnectionState.disconnected) return false;

    final candidates = autoConnectProfiles;
    if (candidates.isEmpty) return false;

    _autoConnectInFlight = true;
    _lastAutoConnectError = null;
    notifyListeners();

    try {
      final availability = <MeshCoreTransportKind, Set<String>>{};
      for (final profile in candidates) {
        if (connector.state != MeshCoreConnectionState.disconnected) break;

        final kind = profile.transportKind;
        if (kind != MeshCoreTransportKind.tcp) {
          final seen = availability[kind] ??= await _discoverAddresses(
            connector,
            kind,
          );
          if (!seen.contains(profile.address)) continue;
        }

        try {
          await connector.connect(
            profile.toDevice(),
            displayName: profile.name,
          );
          await recordConnection(profile.toDevice());
          return true;
        } catch (e) {
          _lastAutoConnectError = '${profile.name}: $e';
          debugPrint('Auto-connect to ${profile.name} failed: $e');
        }
      }

      _lastAutoConnectError ??= candidates.length == 1
          ? '${candidates.single.name} is not available'
          : 'No saved auto-connect device is available';
      return false;
    } finally {
      _autoConnectInFlight = false;
      notifyListeners();
    }
  }

  Future<Set<String>> _discoverAddresses(
    MeshCoreConnector connector,
    MeshCoreTransportKind kind,
  ) async {
    try {
      await connector.startDiscovery(kind, timeout: const Duration(seconds: 6));
    } catch (e) {
      debugPrint('Auto-connect discovery for ${kind.name} failed: $e');
      return const {};
    }
    return connector.discoveredDevicesFor(kind).map((d) => d.id).toSet();
  }
}

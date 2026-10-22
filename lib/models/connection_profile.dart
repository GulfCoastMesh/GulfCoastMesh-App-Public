import '../connector/meshcore_device.dart';

/// A saved way to reach a companion radio.
///
/// [address] is whatever the transport needs to dial: a BLE remote id, a serial
/// port path or Android USB device id, or a `host:port` endpoint. Only profiles
/// with [autoConnect] set are ever dialled without the user asking.
class ConnectionProfile {
  final String id;
  final String name;
  final MeshCoreTransportKind transportKind;
  final String address;
  final bool autoConnect;
  final DateTime? lastConnectedAt;

  const ConnectionProfile({
    required this.id,
    required this.name,
    required this.transportKind,
    required this.address,
    this.autoConnect = false,
    this.lastConnectedAt,
  });

  /// Sentinel so [copyWith] can distinguish "leave alone" from "set to null".
  static const Object _unset = Object();

  ConnectionProfile copyWith({
    String? name,
    MeshCoreTransportKind? transportKind,
    String? address,
    bool? autoConnect,
    Object? lastConnectedAt = _unset,
  }) {
    return ConnectionProfile(
      id: id,
      name: name ?? this.name,
      transportKind: transportKind ?? this.transportKind,
      address: address ?? this.address,
      autoConnect: autoConnect ?? this.autoConnect,
      lastConnectedAt: identical(lastConnectedAt, _unset)
          ? this.lastConnectedAt
          : lastConnectedAt as DateTime?,
    );
  }

  /// The device this profile dials. BLE remote ids are reassigned by the OS and
  /// serial paths get renumbered, so a connect attempt can still fail — that is
  /// reported as a connection error rather than prevented here.
  MeshCoreDevice toDevice() => MeshCoreDevice(
    id: address,
    displayName: name,
    transportKind: transportKind,
    subtitle: address,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'transport': transportKind.name,
    'address': address,
    'auto_connect': autoConnect,
    if (lastConnectedAt != null)
      'last_connected_at': lastConnectedAt!.toIso8601String(),
  };

  /// Returns null for a record that cannot be trusted, so one bad entry is
  /// skipped instead of failing the whole list.
  static ConnectionProfile? fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final address = json['address'];
    if (id is! String || id.isEmpty) return null;
    if (address is! String || address.isEmpty) return null;

    final transportName = json['transport'];
    final transportKind = MeshCoreTransportKind.values
        .where((kind) => kind.name == transportName)
        .firstOrNull;
    if (transportKind == null) return null;

    final name = json['name'];
    final lastConnectedRaw = json['last_connected_at'];

    return ConnectionProfile(
      id: id,
      name: name is String && name.isNotEmpty ? name : address,
      transportKind: transportKind,
      address: address,
      autoConnect: json['auto_connect'] == true,
      lastConnectedAt: lastConnectedRaw is String
          ? DateTime.tryParse(lastConnectedRaw)
          : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ConnectionProfile &&
      other.id == id &&
      other.name == name &&
      other.transportKind == transportKind &&
      other.address == address &&
      other.autoConnect == autoConnect &&
      other.lastConnectedAt == lastConnectedAt;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    transportKind,
    address,
    autoConnect,
    lastConnectedAt,
  );
}

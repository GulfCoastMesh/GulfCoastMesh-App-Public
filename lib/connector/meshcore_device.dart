enum MeshCoreTransportKind { ble, usb, tcp }

class MeshCoreDevice {
  final String id;
  final String displayName;
  final MeshCoreTransportKind transportKind;
  final int? rssi;
  final String? subtitle;

  const MeshCoreDevice({
    required this.id,
    required this.displayName,
    required this.transportKind,
    this.rssi,
    this.subtitle,
  });

  @override
  bool operator ==(Object other) {
    return other is MeshCoreDevice &&
        other.id == id &&
        other.transportKind == transportKind;
  }

  @override
  int get hashCode => Object.hash(id, transportKind);
}

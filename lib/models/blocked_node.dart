class BlockedNode {
  final String publicKeyHex;
  final String name;
  final int type;
  final DateTime blockedAt;

  BlockedNode({
    required String publicKeyHex,
    required this.name,
    required this.type,
    required this.blockedAt,
  }) : publicKeyHex = publicKeyHex.toLowerCase();

  Map<String, dynamic> toJson() => {
    'key': publicKeyHex,
    'name': name,
    'type': type,
    'blocked_at': blockedAt.millisecondsSinceEpoch,
  };

  factory BlockedNode.fromJson(Map<String, dynamic> json) {
    final key = json['key'];
    if (key is! String || key.trim().isEmpty) {
      throw const FormatException('Blocked node has no key');
    }
    final blockedAt = json['blocked_at'];
    return BlockedNode(
      publicKeyHex: key.trim(),
      name: json['name'] is String ? json['name'] as String : '',
      type: json['type'] is num ? (json['type'] as num).toInt() : 0,
      blockedAt: DateTime.fromMillisecondsSinceEpoch(
        blockedAt is num ? blockedAt.toInt() : 0,
      ),
    );
  }
}

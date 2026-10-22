class ContactGroup {
  final String name;
  final List<String> memberKeys;

  const ContactGroup({required this.name, required this.memberKeys});

  ContactGroup copyWith({String? name, List<String>? memberKeys}) {
    return ContactGroup(
      name: name ?? this.name,
      memberKeys: memberKeys ?? List<String>.from(this.memberKeys),
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'members': memberKeys};
  }

  factory ContactGroup.fromJson(Map<String, dynamic> json) {
    final rawMembers = json['members'];
    final members = rawMembers is List
        ? rawMembers.map((value) => value.toString()).toList()
        : <String>[];
    return ContactGroup(
      name: json['name'] is String ? json['name'] as String : '',
      memberKeys: members,
    );
  }
}

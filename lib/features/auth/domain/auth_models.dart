class AppUser {
  const AppUser({
    required this.name,
    required this.identifier,
    required this.identifierType,
    required this.passwordHash,
    required this.createdAt,
  });

  final String name;
  final String identifier;
  final String identifierType;
  final String passwordHash;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'identifier': identifier,
      'identifierType': identifierType,
      // Backward compatibility for any older reads that still look for email.
      'email': identifier,
      'passwordHash': passwordHash,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    final identifier =
        map['identifier'] as String? ?? map['email'] as String? ?? '';
    return AppUser(
      name: map['name'] as String? ?? '',
      identifier: identifier,
      identifierType: map['identifierType'] as String? ?? 'email',
      passwordHash: map['passwordHash'] as String? ?? '',
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

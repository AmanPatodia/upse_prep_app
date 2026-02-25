class AppUser {
  const AppUser({
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.createdAt,
  });

  final String name;
  final String email;
  final String passwordHash;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'passwordHash': passwordHash,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      passwordHash: map['passwordHash'] as String? ?? '',
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

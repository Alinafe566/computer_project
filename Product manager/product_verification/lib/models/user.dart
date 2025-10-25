class User {
  final int id;
  final String fullName;
  final String email;
  final String role;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fullName: json['name'],
      email: json['email'] ?? '',
      role: json['role'] ?? 'consumer',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': fullName,
      'email': email,
      'role': role,
    };
  }
}
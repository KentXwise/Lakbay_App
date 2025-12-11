class Member {
  final String id;
  final String fullName;
  final String email;
  final String role;

  Member({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'email': email,
    'role': role,
  };

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'Member',
    );
  }
}
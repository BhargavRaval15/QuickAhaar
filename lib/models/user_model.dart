class UserModel {
  final String uid;
  final String email;
  final String? name;
  final String? phoneNumber;
  final String? address;
  final DateTime createdAt;
  final List<String> roles;

  UserModel({
    required this.uid,
    required this.email,
    this.name,
    this.phoneNumber,
    this.address,
    required this.createdAt,
    this.roles = const ['user'],
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'address': address,
      'createdAt': createdAt.toIso8601String(),
      'roles': roles,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      email: map['email'] as String,
      name: map['name'] as String?,
      phoneNumber: map['phoneNumber'] as String?,
      address: map['address'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      roles: List<String>.from(map['roles'] ?? ['user']),
    );
  }
} 
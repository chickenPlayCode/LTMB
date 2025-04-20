class User {
  final String id;
  final String username;
  final String password;
  final String email;
  final String? avatar;
  final DateTime createdAt;
  final DateTime lastActive;
  final DateTime? birthDate;
  final String? phoneNumber;
  final String? fullname; // Thêm trường fullname

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.email,
    this.avatar,
    required this.createdAt,
    required this.lastActive,
    this.birthDate,
    this.phoneNumber,
    this.fullname,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'email': email,
      'avatar': avatar,
      'createdAt': createdAt.toIso8601String(),
      'lastActive': lastActive.toIso8601String(),
      'birthDate': birthDate?.toIso8601String(),
      'phoneNumber': phoneNumber,
      'fullname': fullname, // Thêm trường fullname vào map
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      username: map['username'] as String,
      password: map['password'] as String,
      email: map['email'] as String,
      avatar: map['avatar'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastActive: DateTime.parse(map['lastActive'] as String),
      birthDate: map['birthDate'] != null ? DateTime.parse(map['birthDate'] as String) : null,
      phoneNumber: map['phoneNumber'] as String?,
      fullname: map['fullname'] as String?, // Lấy giá trị fullname từ map
    );
  }
}
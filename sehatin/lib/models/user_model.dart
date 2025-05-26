class UserModel {
  final int id;
  final String username;
  final String email;
  final String? telno;
  final String role;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.telno,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
        id: j['id'] as int,
        username: j['username'] as String,
        email: j['email'] as String,
        telno: j['telno'] as String?,
        role: j['role'] as String,
      );
}

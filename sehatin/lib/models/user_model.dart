class UserModel {
  final int id;
  final String username;
  final String email;
  final String? telno;
  final String role;
  final int? consultationCount;
  final DateTime paymentDate;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.telno,
    required this.role,
    this.consultationCount,
    required this.paymentDate
  });

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
        id: j['id'] as int,
        username: j['username'] as String,
        email: j['email'] as String,
        telno: j['telno'] as String?,
        role: j['role'] as String,
        consultationCount: (j['consultation_count']??0) as int,
        paymentDate: j['payment_date'] != null 
      ? DateTime.parse(j['payment_date'] as String)
      : DateTime.now(),
      );
}

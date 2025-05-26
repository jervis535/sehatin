class DoctorModel {
  final int userId;
  final String specialization;
  final int poiId;
  final bool verified;

  DoctorModel({required this.userId, required this.specialization, required this.poiId, required this.verified});

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      userId: json['user_id'],
      specialization: json['specialization'],
      poiId: json['poi_id'],
      verified: json['verified']
    );
  }
  

  @override
  String toString() {
    return 'DoctorModel(userId: $userId, specialization: $specialization, poiId: $poiId)';
  }
}


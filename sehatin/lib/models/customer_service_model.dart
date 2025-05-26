class CustomerServiceModel{
  final int userId;
  final int poiId;
  final bool verified;

  CustomerServiceModel({required this.userId, required this.poiId, required this.verified});

  factory CustomerServiceModel.fromJson(Map<String, dynamic> json) {
    return CustomerServiceModel(
      userId: json['user_id'],
      poiId: json['poi_id'],
      verified: json['verified']
    );
  }

  @override
  String toString() {
    return 'DoctorModel(userId: $userId, poiId: $poiId, verified: $verified)';
  }
}


class MedicalRecord {
  final int id;
  final int userId;
  final String medications;
  final String medicalConditions;
  final String notes;

  MedicalRecord({
    required this.id,
    required this.userId,
    required this.medications,
    required this.medicalConditions,
    required this.notes,
  });

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    return MedicalRecord(
      id: json['id'],
      userId: json['user_id'],
      medications: json['medications'],
      medicalConditions: json['medical_conditions'],
      notes: json['notes'],
    );
  }
}

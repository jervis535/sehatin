class MedicalRecord {
  final int id;
  final int userId;
  final int doctorId;
  final String medications;
  final String medicalConditions;
  final String notes;
  final String createdtAt;

  MedicalRecord({
    required this.id,
    required this.userId,
    required this.doctorId,
    required this.medications,
    required this.medicalConditions,
    required this.notes,
    required this.createdtAt
  });

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    return MedicalRecord(
      id: json['id'],
      userId: json['user_id'],
      doctorId: json['doctor_id'],
      medications: json['medications'],
      medicalConditions: json['medical_conditions'],
      notes: json['notes'],
      createdtAt: json['date']
    );
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/medical_record_model.dart';

class MedicalRecordService {
  static final String baseUrl = dotenv.env['API_URL']!;

  static Future<void> createRecord({
    required int userId,
    required String medications,
    required String medicalConditions,
    required String notes,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/medicalrecord'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'medications': medications,
        'medical_conditions': medicalConditions,
        'notes': notes,
      }),
    );

    if (res.statusCode != 201) {
      throw Exception('Failed to create record: ${res.body}');
    }
  }

  static Future<List<MedicalRecord>> getByUserId(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/medicalrecord?user_id=$userId'));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => MedicalRecord.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load medical history');
    }
  }
}

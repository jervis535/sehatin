import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/doctor_model.dart';

class DoctorService {
  static final _baseUrl = dotenv.env['API_URL']!;

  static Future<List<DoctorModel>> getAllDoctors() async {
    final res = await http.get(Uri.parse('$_baseUrl/doctors'));
    final List data = jsonDecode(res.body);
    return data.map((e) => DoctorModel.fromJson(e)).toList();
  }

  static Future<List<DoctorModel>> getBySpecialization(String spec) async {
    final res = await http.get(
      Uri.parse('$_baseUrl/doctors?specialization=$spec'),
    );

    final List data = jsonDecode(res.body);
    return data.map((doctorJson) => DoctorModel.fromJson(doctorJson)).toList();
  }

  static Future<DoctorModel?> getByUserId(int userId) async {
    final res = await http.get(
      Uri.parse('$_baseUrl/doctors?user_id=$userId'),
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to load doctor');
    }
    final List data = jsonDecode(res.body);
    if (data.isEmpty) return null;
    return DoctorModel.fromJson(data.first);
  }

static Future<DoctorModel?> updateDoctor({
  required int userId,
  required String specialization,
  required int poiId,
  required String token,
}) async {
  final uri = Uri.parse('$_baseUrl/doctors/$userId');
  final res = await http.put(
    uri,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'specialization': specialization,
      'poi_id': poiId,
    }),
  );
  if (res.statusCode == 200) {
    return DoctorModel.fromJson(jsonDecode(res.body));
  }
  throw Exception('Doctor update failed: ${res.statusCode}');
}


}

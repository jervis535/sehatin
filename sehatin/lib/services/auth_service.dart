import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'session_service.dart';
import '../models/user_model.dart';

class AuthService {
  final String _baseUrl = dotenv.env['API_URL']!;

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/users/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final user = UserModel.fromJson(data['user']);
      final token = data['token'];

      await SessionService.saveSession(token, user.id);
      return {
        'user': user,
        'token': token,
      };
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    required String role,
    String? specialization,
    String? poiId,
  }) async {
    final url = Uri.parse('${dotenv.env['API_URL']}/users');
    final Map<String, dynamic> body = {
      'email': email,
      'password': password,
      'username': name,
      'role': role,
    };
    

    if (role == 'doctor' && specialization != null && poiId != null) {
      body['specialization'] = specialization;
      body['poi_id'] = int.tryParse(poiId);
    } else if (role == 'customer service' && poiId != null) {
      body['poi_id'] = int.tryParse(poiId);
    }
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      final data = jsonDecode(res.body);
      final user = UserModel.fromJson(data['user']);
      final token = data['token'];

      await SessionService.saveSession(token, user.id);
      return {
        'user': user,
        'token': token,
      };
    } else {
      throw Exception('Registration failed: ${res.body}');
    }
  }

  static Future<Map<String, dynamic>> fetchUserWithToken(int userId, String token) async {
    final uri = Uri.parse('${dotenv.env['API_URL']}/users/$userId');
    final res = await http.get(uri, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to fetch user: ${res.statusCode}');
  }

}

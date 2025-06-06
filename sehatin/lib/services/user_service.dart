import 'dart:convert';
import '../models/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserService {
  static String get _baseUrl {
    final u = dotenv.env['API_URL'];
    if (u == null || u.isEmpty) throw Exception('API_BASE_URL missing');
    return u;
  }

  static Future<Map<String, dynamic>> fetchUser(int userId, String token) async {
    final res = await http.get(
      Uri.parse('$_baseUrl/users/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to load user (${res.statusCode})');
  }

  static Future<Map<String, dynamic>> updateUser({
    required int userId,
    required String username,
    required String email,
    required String telno,
    required String currentPassword,
    required String token,
  }) async {
    final body = {
      'username': username,
      'email': email,
      'telno': telno,
      'password': currentPassword,
    };
    final res = await http.put(
      Uri.parse('$_baseUrl/users/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Update failed (${res.statusCode}): ${res.body}');
  }

  static Future<void> changePassword({
    required int userId,
    required String oldPassword,
    required String newPassword,
    required String token,
  }) async {
    final res = await http.put(
      Uri.parse('$_baseUrl/users/changepass/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'oldpass': oldPassword, 'newpass': newPassword}),
    );
    if (res.statusCode != 200) {
      throw Exception('Password change failed (${res.statusCode})');
    }
  }

  static Future<List<UserModel>> fetchUsers({String? query}) async {
    final res = await http.get(Uri.parse('$_baseUrl/users'));
    if (res.statusCode != 200) {
      throw Exception('Failed to load users: ${res.statusCode}');
    }
    final data = jsonDecode(res.body) as List;
    var users = data
      .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
      .where((u) => u.role.toLowerCase() == 'user')
      .toList();
    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      users = users.where((u) {
        return u.username.toLowerCase().contains(q) ||
               u.email.toLowerCase().contains(q);
      }).toList();
    }
    return users;
  }

  static Future<UserModel?> fetchUserById(userId) async {
    final url = Uri.parse('$_baseUrl/users/$userId');
    print('Requesting: $url');

    try {
      final res = await http.get(url);
      print('Status: ${res.statusCode}');
      print('Body: ${res.body}');

      if (res.statusCode != 200) {
        throw Exception('Failed to load user: ${res.statusCode}');
      }

      final data = jsonDecode(res.body);

      // data is expected to be a Map<String, dynamic>, representing a single user
      if (data == null || data.isEmpty) return null;

      return UserModel.fromJson(data); // ✔️ Correct usage
    } catch (e) {
      print('Fetch user error: $e');
      rethrow;
    }
  }

}

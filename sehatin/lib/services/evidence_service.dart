import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EvidenceService {
  static final _baseUrl = dotenv.env['API_URL'];

  static Future<void> uploadEvidence({
    required int userId,
    required String base64Image,
  }) async {
    final url = Uri.parse('$_baseUrl/evidences/$userId');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'image': base64Image}),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to upload evidence: ${response.body}');
    }
  }
}

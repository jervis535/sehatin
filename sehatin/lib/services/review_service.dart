import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/review_model.dart';

class ReviewService {
  static String get _baseUrl {
    final u = dotenv.env['API_URL'];
    if (u == null || u.isEmpty) throw Exception('API_URL missing from .env');
    return u;
  }

  static Future<List<ReviewModel>> fetchPendingReviews({
    required int reviewerId,
    required String token,
  }) async {
    final uri = Uri.parse('$_baseUrl/reviews?reviewer_id=$reviewerId');
    final res = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to load reviews (${res.statusCode})');
    }

    final List<dynamic> data = jsonDecode(res.body) as List<dynamic>;

    final pending = data
        .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
        .where((r) => r.score == null)
        .toList();

    return pending;
  }

  static Future<ReviewModel> submitReview({
    required int reviewId,
    required int score,
    required String notes,
    required String token,
  }) async {
    final uri = Uri.parse('$_baseUrl/reviews/$reviewId');
    final body = jsonEncode({
      'score': score,
      'notes': notes,
    });

    final res = await http.put(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (res.statusCode != 200) {
      throw Exception(
          'Failed to update review ($reviewId): ${res.statusCode}');
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    return ReviewModel.fromJson(json);
  }
}

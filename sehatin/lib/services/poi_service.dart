import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/poi_model.dart';

class PoiService {
  static String get _baseUrl {
    final url = dotenv.env['API_URL'];
    if (url == null || url.isEmpty) {
      throw Exception('API_BASE_URL not set in .env');
    }
    return url;
  }

  static Future<PoiModel> createPoi({
    required String name,
    required String category,
    required String address,
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse('$_baseUrl/pois');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'category': category,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
      }),
    );
    if (res.statusCode == 201) {
      return PoiModel.fromJson(jsonDecode(res.body));
    }
    throw Exception('Failed to create POI: ${res.statusCode}');
  }

  static Future<List<PoiModel>> fetchPois({
    String? name,
    String? category,
    double? latitude,
    double? longitude,
  }) async {
    final queryParams = <String, String>{};
    if (name != null && name.isNotEmpty) {
      queryParams['name'] = name;
    }
    if (category != null && category.isNotEmpty) {
      queryParams['category'] = category;
    }
    if (latitude != null) {
      queryParams['latitude'] = latitude.toString();
    }
    if (longitude != null) {
      queryParams['longitude'] = longitude.toString();
    }

    final uri = Uri.parse('$_baseUrl/pois').replace(queryParameters: queryParams);
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body) as List;
      return data
          .map((e) => PoiModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (res.statusCode == 404) {
      return [];
    }
    throw Exception('Failed to load POIs: ${res.statusCode}');
  }

  static Future<List<PoiModel>> calculateNearby({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse('$_baseUrl/calculate');
    final res = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'latitude': latitude, 'longitude': longitude}),
    );
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body) as List;
      return data.map((e) => PoiModel.fromJson(e)).toList();
    }
    throw Exception('Failed to load nearby POIs: ${res.statusCode}');
  }
}

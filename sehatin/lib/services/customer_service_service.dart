import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/customer_service_model.dart';

class CustomerServiceService {
static String get _baseUrl {
final url = dotenv.env['API_URL'];
if (url == null || url.isEmpty) {
throw Exception('API_BASE_URL not set in .env');
}
return url;
}

static Future<List> getByUserId(int userId) async {
final uri = Uri.parse('$_baseUrl/customerservices?user_id=$userId');
final res = await http.get(uri);
if (res.statusCode == 200) {
final List data = jsonDecode(res.body) as List;
return data
.map((e) => CustomerServiceModel.fromJson(e as Map<String, dynamic>))
.toList();
}
throw Exception('Failed to load customer service entries: ${res.statusCode}');
}

static Future<CustomerServiceModel?> getOneByUserId(int userId) async {
final list = await getByUserId(userId);
if (list.isEmpty) return null;
return list.first;
}

  static Future<List<CustomerServiceModel>> getByPoiId(int poiId) async {
    final uri = Uri.parse('$_baseUrl/customerservices?poi_id=$poiId');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body) as List;
      return data
          .map((e) => CustomerServiceModel.fromJson(e))
          .toList();
    }
    if (res.statusCode == 404) {
      return [];
    }
    throw Exception('Failed to load customer service: ${res.statusCode}');
  }

static Future<CustomerServiceModel?> updateCustomerService({
  required int entryId,
  required int poiId,
  required String token,
}) async {
  final uri = Uri.parse('$_baseUrl/customerservices/$entryId');
  final res = await http.put(
    uri,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({'poi_id': poiId}),
  );
  if (res.statusCode == 200) {
    return CustomerServiceModel.fromJson(jsonDecode(res.body));
  }
  throw Exception('Customer service update failed: ${res.statusCode}');
}

}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/channel_model.dart';

class ChannelService {
  static String get _baseUrl {
    final url = dotenv.env['API_URL'];
    if (url == null || url.isEmpty) {
      throw Exception('API_BASE_URL not set in .env');
    }
    return url;
  }

  static Future<int?> createConsultationChannel(int user0, int user1) async {
    final uri = Uri.parse('$_baseUrl/channels');
    print(uri);
    final body = {
      'user_id0': user0,
      'user_id1': user1,
      'type': 'consultation',
    };
    print(body);


    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (res.statusCode == 201) {
      return (jsonDecode(res.body) as Map<String, dynamic>)['id'] as int;
    }
    return null;
  }

  static Future<int?> createChannel(int user0, int user1, {String? type}) async {
    final uri = Uri.parse('$_baseUrl/channels');
    final body = {
      'user_id0': user0,
      'user_id1': user1,
      if (type != null) 'type': type,
    };

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (res.statusCode == 201) {
      return (jsonDecode(res.body) as Map<String, dynamic>)['id'] as int;
    }
    return null;
  }

static Future<List<ChannelModel>> getUserChannels(int userId, {String? type}) async {
  var uri = Uri.parse('$_baseUrl/channels?user_id=$userId');
  if (type != null) {
    uri = Uri.parse('$_baseUrl/channels?user_id=$userId&type=$type');
  }

  final res = await http.get(uri);

  if (res.statusCode == 200) {
    final List data = jsonDecode(res.body) as List;
    return data
        .map((e) => ChannelModel.fromJson(e as Map<String, dynamic>))
        .toList();
  } else if (res.statusCode == 404) {
    return <ChannelModel>[];
  }

  throw Exception('Failed to load channels: ${res.statusCode}');
}

  static Future<List<ChannelModel>> getDoctorConsultations(int doctorId) async {
  final uri = Uri.parse('$_baseUrl/channels?type=consultation&user_id=$doctorId');
  final res = await http.get(uri);

  if (res.statusCode == 200) {
    final data = jsonDecode(res.body) as List;
    return data.map((e) => ChannelModel.fromJson(e)).toList();
  }
  if (res.statusCode == 404) {
    return [];
  }
  throw Exception('Failed to load doctor consultations: ${res.statusCode}');
}

  static Future<int?> createServiceChannel(int user0, int user1) async {
    final uri = Uri.parse('$_baseUrl/channels');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id0': user0,
        'user_id1': user1,
        'type': 'service',
      }),
    );
    print(uri);
    print(res.body);
    if (res.statusCode == 201) {
      return (jsonDecode(res.body) as Map<String, dynamic>)['id'] as int;
    }
    return null;
  }

static Future<List<ChannelModel>> getUserServiceChannels(int userId) async {
  return getUserChannels(userId, type: 'service');
}

static Future<List<ChannelModel>> getAgentServiceChannels(int agentUserId) async {
  final all = await getUserChannels(agentUserId, type: 'service');
  return all.where((c) =>
      (c.userId0 == agentUserId || c.userId1 == agentUserId)
  ).toList();
}

  static Future<bool> deleteChannel(int channelId) async {
    final uri = Uri.parse('$_baseUrl/channels/$channelId');
    final res = await http.delete(uri);
    return res.statusCode == 200;
  }



}

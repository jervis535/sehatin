import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/message_model.dart';

class MessageService {
  final String baseUrl;

  MessageService() : baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:3000';

  Future<List<MessageModel>> getMessages({int? channelId, int? userId, bool? read}) async {
    final queryParameters = <String, String>{};

    if (channelId != null) queryParameters['channel_id'] = channelId.toString();
    if (userId != null) queryParameters['user_id'] = userId.toString();
    if (read != null) queryParameters['read'] = read.toString();

    final uri = Uri.parse('$baseUrl/messages').replace(queryParameters: queryParameters);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      return data.map((json) => MessageModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load messages');
    }
  }

  Future<MessageModel> sendMessage(MessageModel message) async {
    final url = Uri.parse('$baseUrl/messages');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(message.toJson()),
    );

    if (response.statusCode == 201) {
      return MessageModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to send message');
    }
  }

  Future<MessageModel> markAsRead(int messageId) async {
    final url = Uri.parse('$baseUrl/messages/$messageId/read');

    final response = await http.patch(url);

    if (response.statusCode == 200) {
      return MessageModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to mark message as read');
    }
  }

  Future<void> deleteMessage(int messageId) async {
    final url = Uri.parse('$baseUrl/messages/$messageId');

    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete message');
    }
  }
  

  Future<void> markMessageAsRead(int messageId) async {
  final url = Uri.parse('$baseUrl/messages/$messageId/read');
  final response = await http.put(url);
  print(response);

  if (response.statusCode != 200) {
    print('Error response body: ${response.body}');
    throw Exception('Failed to mark message as read');
  }
}
}



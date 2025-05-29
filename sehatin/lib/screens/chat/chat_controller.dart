import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../models/message_model.dart';
import '../../models/user_model.dart';
import '../../services/message_service.dart';
import '../medical_record/medical_record_screen.dart';

class ChatController {
  final int channelId;
  final UserModel user;
  final Function(void Function()) update;

  final MessageService _messageService = MessageService();
  final ImagePicker _picker = ImagePicker();
  late final WebSocketChannel _channel;

  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  List<MessageModel> messages = [];
  bool isSending = false;

  ChatController(this.channelId, this.user, this.update);

  void init() {
    _loadMessages();
    _initWebSocket();
  }

  void dispose() {
    _channel.sink.close();
    textController.dispose();
    scrollController.dispose();
  }

  void _initWebSocket() {
    final apiBase = _messageService.baseUrl.replaceAll('http', 'ws');
    final userId = user.id;

    _channel = WebSocketChannel.connect(
      Uri.parse('$apiBase/ws?user_id=$userId'),
    );

    _channel.stream.listen((data) async {
      final msgData = json.decode(data);
      switch (msgData['type']) {
        case 'new_message':
          final message = MessageModel.fromJson(msgData['data']);
          if (message.channelId == channelId) {
            update(() => messages.add(message));
            if (message.userId != user.id && !message.read) {
              await _messageService.markMessageAsRead(message.id);
            }
            _scrollToBottom();
          }
          break;

        case 'message_read':
          final id = msgData['data']['message_id'] as int;
          final index = messages.indexWhere((m) => m.id == id);
          if (index != -1) {
            update(() {
              messages[index] = messages[index].copyWith(read: true);
            });
          }
          break;

        case 'channel_deleted':
          final deletedId = msgData['data']['channel_id'];
          if (deletedId == channelId) {
            _showSnackBar('This channel was deleted');
            Navigator.of(_context).pop();
          }
          break;
      }
    }, onError: (e) {
      debugPrint('WebSocket error: $e');
    });
  }

  Future<void> _loadMessages() async {
    try {
      final loaded = await _messageService.getMessages(channelId: channelId);
      update(() => messages = loaded);
      _scrollToBottom();
    } catch (e) {
      debugPrint('Error loading messages: $e');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> sendTextMessage() async {
    final text = textController.text.trim();
    if (text.isEmpty) return;
    update(() => isSending = true);

    final message = MessageModel(
      id: 0,
      channelId: channelId,
      userId: user.id,
      content: text,
      type: 'text',
      read: false,
      sentAt: DateTime.now(),
      image: null,
    );

    try {
      await _messageService.sendMessage(message);
      textController.clear();
      _scrollToBottom();
    } catch (e) {
      debugPrint('Send text error: $e');
    } finally {
      update(() => isSending = false);
    }
  }

  Future<void> sendImageMessage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    final base64Image = base64Encode(bytes);

    final message = MessageModel(
      id: 0,
      channelId: channelId,
      userId: user.id,
      content: '',
      type: 'image',
      read: false,
      sentAt: DateTime.now(),
      image: base64Image,
    );

    try {
      await _messageService.sendMessage(message);
      _scrollToBottom();
    } catch (e) {
      debugPrint('Send image error: $e');
    }
  }

  Future<void> deleteChannel() async {
    final confirmed = await showDialog<bool>(
      context: _context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Channel'),
        content: const Text('Are you sure? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return;

    final url = Uri.parse('${dotenv.env['API_URL']}/channels/$channelId');
    try {
      final resp = await http.delete(url);
      if (resp.statusCode == 200) {
        _showSnackBar('Channel deleted');
        Navigator.of(_context).pop();
      } else {
        _showSnackBar(resp.body.isNotEmpty ? resp.body : 'Failed to delete');
      }
    } catch (e) {
      _showSnackBar('Delete error: $e');
    }
  }

  Future<void> viewMedicalRecords() async {
    try {
      final chRes = await http.get(Uri.parse('${dotenv.env['API_URL']}/channels/$channelId'));
      final chJson = json.decode(chRes.body);
      final otherId = chJson['user_id0'] == user.id ? chJson['user_id1'] : chJson['user_id0'];

      final uRes = await http.get(Uri.parse('${dotenv.env['API_URL']}/users/$otherId'));
      final otherUser = UserModel.fromJson(json.decode(uRes.body));

      Navigator.of(_context).push(
        MaterialPageRoute(builder: (_) => MedicalRecordScreen(user: otherUser)),
      );
    } catch (e) {
      debugPrint('Medical record error: $e');
      _showSnackBar('Could not load records');
    }
  }

  void markMessageAsRead(int messageId) {
    _messageService.markMessageAsRead(messageId);
    _channel.sink.add(jsonEncode({
      'type': 'message_read',
      'data': {'message_id': messageId, 'channel_id': channelId},
    }));
  }

  late BuildContext _context;
  void attachContext(BuildContext context) => _context = context;

  void _showSnackBar(String msg) {
    if (_context.mounted) {
      ScaffoldMessenger.of(_context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }
}

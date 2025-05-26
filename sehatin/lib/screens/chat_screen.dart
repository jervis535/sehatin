import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:image_picker/image_picker.dart';

import '../models/message_model.dart';
import '../models/user_model.dart';
import '../services/message_service.dart';
import '../screens/image_view_screen.dart';
import '../screens/medical_record_screen.dart';

class ChatScreen extends StatefulWidget {
  final int channelId;
  final UserModel user;

  const ChatScreen({
    Key? key,
    required this.channelId,
    required this.user,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final MessageService _messageService = MessageService();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  late WebSocketChannel _channel;
  List<MessageModel> _messages = [];
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _initWebSocket();
  }

  @override
  void dispose() {
    _channel.sink.close();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initWebSocket() {
    final apiBase = _messageService.baseUrl.replaceAll('http', 'ws');
    final userId = widget.user.id;

    _channel = WebSocketChannel.connect(
      Uri.parse('$apiBase/ws?user_id=$userId'),
    );

    _channel.stream.listen((data) async {
      final msgData = json.decode(data) as Map<String, dynamic>;
      switch (msgData['type']) {
        case 'new_message':
          final message = MessageModel.fromJson(msgData['data']);
          if (message.channelId == widget.channelId) {
            setState(() => _messages.add(message));
            if (message.userId != widget.user.id && !message.read) {
              await _messageService.markMessageAsRead(message.id);
            }
            _scrollToBottom();
          }
          break;

        case 'message_read':
          final messageId = msgData['data']['message_id'] as int;
          final idx = _messages.indexWhere((m) => m.id == messageId);
          if (idx != -1) {
            setState(() {
              _messages[idx] = _messages[idx].copyWith(read: true);
            });
          }
          break;

        case 'channel_deleted':
          final deletedChannelId = msgData['data']['channel_id'] as int;
          if (deletedChannelId == widget.channelId && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('This channel was deleted')),
            );
            Navigator.of(context).pop();
          }
          break;
      }
    }, onError: (e) {
      debugPrint('WebSocket error: $e');
    }, onDone: () {
      debugPrint('WebSocket closed');
    });
  }

  Future<void> _loadMessages() async {
    try {
      final messages = await _messageService.getMessages(channelId: widget.channelId);
      setState(() => _messages = messages);
      _scrollToBottom();
    } catch (e) {
      debugPrint('Error loading messages: $e');
    }
  }

  Future<void> _sendTextMessage() async {
    if (_textController.text.trim().isEmpty) return;
    setState(() => _isSending = true);

    final message = MessageModel(
      id: 0,
      channelId: widget.channelId,
      userId: widget.user.id,
      content: _textController.text.trim(),
      type: 'text',
      read: false,
      sentAt: DateTime.now(),
      image: null,
    );

    try {
      await _messageService.sendMessage(message);
      _textController.clear();
      _scrollToBottom();
    } catch (e) {
      debugPrint('Error sending message: $e');
    } finally {
      setState(() => _isSending = false);
    }
  }

  Future<void> _sendImageMessage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    final base64Image = base64Encode(bytes);

    final message = MessageModel(
      id: 0,
      channelId: widget.channelId,
      userId: widget.user.id,
      content: '',
      type: 'image',
      read: false,
      sentAt: DateTime.now(),
      image: base64Image,
    );

    try {
      await _messageService.sendMessage(message);
      _scrollToBottom();
    } catch (e, st) {
      debugPrint('Error sending image: $e\n$st');
    }
  }

  Future<void> _deleteChannel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Channel'),
        content: const Text(
          'Are you sure you want to delete this channel? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final url = Uri.parse('${dotenv.env['API_URL']}/channels/${widget.channelId}');
    try {
      final resp = await http.delete(url);
      debugPrint('HTTP DELETE /channels/${widget.channelId} → '
                 'status=${resp.statusCode}, body=${resp.body}');

      if (resp.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Channel deleted')),
          );
          Navigator.of(context).pop();
        }
      } else {
        final err = resp.body.isNotEmpty ? resp.body : 'Failed to delete channel';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting channel: $e')),
      );
    }
  }

  Future<void> _viewMedicalRecords() async {
    try {
      final chRes = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/channels/${widget.channelId}'),
      );
      print('${dotenv.env['API_URL']}/channels/${widget.channelId}');
      if (chRes.statusCode != 200) throw Exception('Failed to fetch channel');
      final chJson = json.decode(chRes.body) as Map<String, dynamic>;

      final int uid0 = chJson['user_id0'];
      final int uid1 = chJson['user_id1'];
      final otherId = (uid0 == widget.user.id) ? uid1 : uid0;

      final uRes = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/users/$otherId'),
      );
      if (uRes.statusCode != 200) throw Exception('Failed to fetch user');
      final otherUser = UserModel.fromJson(
        json.decode(uRes.body) as Map<String, dynamic>,
      );

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MedicalRecordScreen(user: otherUser),
          ),
        );
      }
    } catch (e, stackTrace) {

  debugPrint('Error loading medical records: $e');
  debugPrint('$stackTrace');

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Could not load records: $e')),
  );
}
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildMessageItem(MessageModel message) {
    final isMe = message.userId == widget.user.id;

    if (!message.read && !isMe) {
      _messageService.markMessageAsRead(message.id);
      _channel.sink.add(json.encode({
        'type': 'message_read',
        'data': {
          'message_id': message.id,
          'channel_id': widget.channelId,
        },
      }));
    }

    Widget content;
    if (message.type == 'image' && message.image != null) {
      final bytes = base64Decode(message.image!);
      content = GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ImageViewScreen(imageBytes: bytes)),
        ),
        child: Image.memory(
          bytes,
          width: 200,
          height: 200,
          fit: BoxFit.cover,
        ),
      );
    } else {
      content = Text(
        message.content,
        style: TextStyle(color: isMe ? Colors.white : Colors.black87),
      );
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        decoration: BoxDecoration(
          color: isMe ? Colors.blueAccent : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            content,
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${message.sentAt.hour.toString().padLeft(2, '0')}:'
                  '${message.sentAt.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe ? Colors.white70 : Colors.black54,
                  ),
                ),
                if (isMe)
                  Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: Icon(
                      message.read ? Icons.done_all : Icons.done,
                      size: 14,
                      color: message.read
                          ? Colors.lightBlueAccent
                          : Colors.white70,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canDelete = widget.user.role == 'doctor' ||
        widget.user.role == 'customer service';
    final canViewRecords = canDelete;
    debugPrint('▶️ user.role="${widget.user.role}", canViewRecords=${canViewRecords}');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          if (canViewRecords)
            IconButton(
              icon: const Icon(Icons.medical_information),
              tooltip: 'View Medical Records',
              onPressed: _viewMedicalRecords,
            ),
          if (canDelete)
            IconButton(
              icon: const Icon(Icons.delete_forever),
              tooltip: 'Delete Channel',
              onPressed: _deleteChannel,
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (_, i) => _buildMessageItem(_messages[i]),
            ),
          ),
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.image),
                    onPressed: _sendImageMessage,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        hintText: 'Type a message',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _sendTextMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _isSending
                      ? const CircularProgressIndicator()
                      : IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: _sendTextMessage,
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

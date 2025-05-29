import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import 'chat_controller.dart';
import 'chat_input.dart';
import 'chat_message_item.dart';

class ChatScreen extends StatefulWidget {
  final int channelId;
  final UserModel user;

  const ChatScreen({super.key, required this.channelId, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ChatController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ChatController(widget.channelId, widget.user, setState);
    _controller.init();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _controller.attachContext(context); 

    final canDelete = widget.user.role == 'doctor' || widget.user.role == 'customer service';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          if (canDelete)
            IconButton(
              icon: const Icon(Icons.medical_information),
              tooltip: 'View Medical Records',
              onPressed: _controller.viewMedicalRecords,
            ),
          if (canDelete)
            IconButton(
              icon: const Icon(Icons.delete_forever),
              tooltip: 'Delete Channel',
              onPressed: _controller.deleteChannel,
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _controller.scrollController,
              itemCount: _controller.messages.length,
              itemBuilder: (_, i) => ChatMessageItem(
                message: _controller.messages[i],
                user: widget.user,
                onRead: _controller.markMessageAsRead,
              ),
            ),
          ),
          ChatInput(
            controller: _controller.textController,
            isSending: _controller.isSending,
            onSendText: _controller.sendTextMessage,
            onSendImage: _controller.sendImageMessage,
          ),
        ],
      ),
    );
  }
}

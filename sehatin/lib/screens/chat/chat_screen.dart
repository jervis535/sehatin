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

    final canDelete =
        widget.user.role == 'doctor' || widget.user.role == 'customer service';

    return Scaffold(
      backgroundColor: const Color(0xFFF7EAEA),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 52, 43, 182),
        elevation: 0,
        title: const Text(
          'Konsultasi Online',
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color.fromARGB(255, 255, 255, 255),
        ),
        actions: [
          if (canDelete)
            IconButton(
              icon: const Icon(Icons.medical_information),
              tooltip: 'View Medical Records',
              onPressed: _controller.viewMedicalRecords,
              color: Colors.black,
            ),
          if (canDelete)
            IconButton(
              icon: const Icon(Icons.delete_forever),
              tooltip: 'Delete Channel',
              onPressed: _controller.deleteChannel,
              color: Colors.black,
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _controller.scrollController,
              itemCount: _controller.messages.length,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemBuilder: (_, i) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ChatMessageItem(
                    message: _controller.messages[i],
                    user: widget.user,
                    onRead: _controller.markMessageAsRead,
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: ChatInput(
              controller: _controller.textController,
              isSending: _controller.isSending,
              onSendText: _controller.sendTextMessage,
              onSendImage: _controller.sendImageMessage,
            ),
          ),
        ],
      ),
    );
  }
}

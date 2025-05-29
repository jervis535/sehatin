import 'dart:convert';
import 'package:flutter/material.dart';

import '../../models/message_model.dart';
import '../../models/user_model.dart';
import 'image_view_screen.dart';

class ChatMessageItem extends StatelessWidget {
  final MessageModel message;
  final UserModel user;
  final void Function(int messageId) onRead;

  const ChatMessageItem({
    super.key,
    required this.message,
    required this.user,
    required this.onRead,
  });

  @override
  Widget build(BuildContext context) {
    final isMe = message.userId == user.id;

    if (!message.read && !isMe) {
      onRead(message.id);
    }

    Widget content;
    if (message.type == 'image' && message.image != null) {
      final bytes = base64Decode(message.image!);
      content = GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ImageViewScreen(imageBytes: bytes)),
        ),
        child: Image.memory(bytes, width: 200, height: 200, fit: BoxFit.cover),
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
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        decoration: BoxDecoration(
          color: isMe ? Colors.blueAccent : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            content,
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${message.sentAt.hour.toString().padLeft(2, '0')}:${message.sentAt.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(fontSize: 10, color: isMe ? Colors.white70 : Colors.black54),
                ),
                if (isMe)
                  Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: Icon(
                      message.read ? Icons.done_all : Icons.done,
                      size: 14,
                      color: message.read ? Colors.lightBlueAccent : Colors.white70,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

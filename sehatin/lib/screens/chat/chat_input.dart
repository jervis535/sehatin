import 'package:flutter/material.dart';

class ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSendText;
  final VoidCallback onSendImage;

  const ChatInput({
    super.key,
    required this.controller,
    required this.isSending,
    required this.onSendText,
    required this.onSendImage,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
        child: Row(
          children: [
            IconButton(icon: const Icon(Icons.image), onPressed: onSendImage),
            Expanded(
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Type a message',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => onSendText(),
              ),
            ),
            const SizedBox(width: 8),
            isSending
                ? const CircularProgressIndicator()
                : IconButton(icon: const Icon(Icons.send), onPressed: onSendText),
          ],
        ),
      ),
    );
  }
}

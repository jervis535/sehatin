import 'package:flutter/material.dart';

class ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSendText;
  final VoidCallback onSendImage;
  final bool isEnabled;

  const ChatInput({
    super.key,
    required this.controller,
    required this.isSending,
    required this.onSendText,
    required this.onSendImage,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.image),
              onPressed: isEnabled ? onSendImage : null,
            ),
            Expanded(
              child: TextField(
                controller: controller,
                enabled: isEnabled,
                decoration: const InputDecoration(
                  hintText: 'Type a message',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) {
                  if (isEnabled) onSendText();
                },
              ),
            ),
            const SizedBox(width: 8),
            isSending
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: isEnabled ? onSendText : null,
                  ),
          ],
        ),
      ),
    );
  }
}
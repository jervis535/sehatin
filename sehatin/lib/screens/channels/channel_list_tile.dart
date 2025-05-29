import 'package:flutter/material.dart';
import '../../models/channel_model.dart';
import '../../models/user_model.dart';
import '../chat/chat_screen.dart';

class ChannelListTile extends StatelessWidget {
  final ChannelModel channel;
  final UserModel currentUser;

  const ChannelListTile({
    super.key,
    required this.channel,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    final otherUserId = channel.userId0 == currentUser.id
        ? channel.userId1
        : channel.userId0;

    return ListTile(
      title: Text('Chat with User #$otherUserId'),
      subtitle: Text('Channel ID: ${channel.id}'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              channelId: channel.id,
              user: currentUser,
            ),
          ),
        );
      },
    );
  }
}

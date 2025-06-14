import 'package:flutter/material.dart';
import '../../models/channel_model.dart';
import '../../models/user_model.dart';
import '../chat/chat_screen.dart';
import '../../services/user_service.dart';

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

  return FutureBuilder<UserModel?>(
    future: UserService.fetchUserById(otherUserId),
    
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return ListTile(title: Text('Loading...'));
      } else if (snapshot.hasError) {
        return ListTile(title: Text('Error loading user'));
      } else if (!snapshot.hasData || snapshot.data == null) {
        return ListTile(title: Text('User not found'));
      }


      final otherUser = snapshot.data!;
      return ListTile(
      title: Text('Chat with ${otherUser.username}'),
      subtitle: Text('Type: ${channel.type}'),
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
    },
  );
}
}


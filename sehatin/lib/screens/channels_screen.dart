import 'package:flutter/material.dart';
import '../models/channel_model.dart';
import '../models/user_model.dart';
import '../services/channel_service.dart';
import 'chat_screen.dart';

class ChannelsScreen extends StatefulWidget {
  final UserModel user;
  const ChannelsScreen({super.key, required this.user});

  @override
  State<ChannelsScreen> createState() => _ChannelsScreenState();
}

class _ChannelsScreenState extends State<ChannelsScreen> {
  late Future<List<ChannelModel>> _channelsFuture;

  @override
  void initState() {
    super.initState();
    _channelsFuture = ChannelService.getUserChannels(widget.user.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Channels')),
      body: FutureBuilder<List<ChannelModel>>(
        future: _channelsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          final channels = snapshot.data!;
          if (channels.isEmpty) {
            return const Center(child: Text('No channels found.'));
          }
          return ListView.builder(
            itemCount: channels.length,
            itemBuilder: (context, i) {
              final channel = channels[i];
              // Determine the "other" user in the channel
              final otherUserId = channel.userId0 == widget.user.id
                  ? channel.userId1
                  : channel.userId0;
              return ListTile(
                title: Text('Chat with User #$otherUserId'),
                subtitle: Text('Channel ID: ${channel.id}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(channelId: channel.id, user: widget.user),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

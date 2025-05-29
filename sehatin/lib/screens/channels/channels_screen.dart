import 'package:flutter/material.dart';
import '../../models/channel_model.dart';
import '../../models/user_model.dart';
import '../../services/channel_service.dart';
import 'channel_list_tile.dart';

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
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final channels = snapshot.data!;
          if (channels.isEmpty) {
            return const Center(child: Text('No channels found.'));
          }

          return ListView.builder(
            itemCount: channels.length,
            itemBuilder: (context, i) {
              return ChannelListTile(
                channel: channels[i],
                currentUser: widget.user,
              );
            },
          );
        },
      ),
    );
  }
}

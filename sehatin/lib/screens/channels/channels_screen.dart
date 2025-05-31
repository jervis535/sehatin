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
      backgroundColor: const Color(0xFFF7EAEA),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 52, 43, 182),
        elevation: 0,
        leading: BackButton(color: const Color.fromARGB(255, 255, 255, 255)),
        title: const Text(
          'Channel Saya',
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<ChannelModel>>(
        future: _channelsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Terjadi kesalahan: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final channels = snapshot.data!;
          if (channels.isEmpty) {
            return const Center(
              child: Text('Belum ada channel.', style: TextStyle(fontSize: 16)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: channels.length,
            itemBuilder: (context, i) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: ChannelListTile(
                  channel: channels[i],
                  currentUser: widget.user,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

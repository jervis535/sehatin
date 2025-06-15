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

class _ChannelsScreenState extends State<ChannelsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<ChannelModel>> _channelsFuture;

  bool get _canViewArchived => widget.user.role == 'user';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _canViewArchived ? 2 : 1,
      vsync: this,
    );
    _tabController.addListener(_onTabChanged);
    _channelsFuture = ChannelService.getUserChannels(widget.user.id);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;

    setState(() {
      if (_tabController.index == 0 || !_canViewArchived) {
        _channelsFuture = ChannelService.getUserChannels(widget.user.id);
      } else {
        _channelsFuture = ChannelService.getArchivedUserChannels(
          widget.user.id,
        );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7EAEA),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 52, 43, 182),
        elevation: 0,
        leading: BackButton(color: Colors.white),
        title: const Text(
          'Channel Saya',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            const Tab(text: 'Active channels'),
            if (_canViewArchived) const Tab(text: 'Archived channels'),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
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
              child: Text('No channels.', style: TextStyle(fontSize: 16)),
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

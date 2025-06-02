import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../models/poi_model.dart';
import '../../services/customer_service_service.dart';
import '../../services/channel_service.dart';
import '../chat/chat_screen.dart';
import '../nearby_poi/nearby_poi_screen.dart';
import 'coordinate_input_fields.dart';
import 'error_message.dart';

class ServiceScreen extends StatefulWidget {
  final UserModel user;
  const ServiceScreen({super.key, required this.user});

  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkUserLock();
  }

  Future<void> _checkUserLock() async {
    final existing = await ChannelService.getUserServiceChannels(
      widget.user.id,
    );
    if (existing.isNotEmpty) {
      setState(() {
        _error = 'You already have an active service request.';
      });
    }
  }

  Future<void> _pickPoiAndConnect() async {
    final lat = double.tryParse(_latCtrl.text.trim());
    final lng = double.tryParse(_lngCtrl.text.trim());

    if (lat == null || lng == null) {
      setState(() => _error = 'Enter valid latitude & longitude');
      return;
    }

    final poi = await Navigator.push<PoiModel?>(
      context,
      MaterialPageRoute(
        builder: (_) => NearbyPoiScreen(latitude: lat, longitude: lng),
      ),
    );
    if (poi == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final agents = await CustomerServiceService.getByPoiId(poi.id);
      if (agents.isEmpty) {
        _setError('No service agents at "${poi.name}"');
        return;
      }

      final chosenAgentId = await _chooseAvailableAgent(agents);
      if (chosenAgentId == null) {
        _setError('All agents at "${poi.name}" are busy. Try later.');
        return;
      }

      final channelId = await ChannelService.createServiceChannel(
        widget.user.id,
        chosenAgentId,
      );
      if (channelId != null) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (_) => ChatScreen(channelId: channelId, user: widget.user),
            ),
          );
        }
      } else {
        _setError('Failed to create service channel');
      }
    } catch (e) {
      _setError('Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<int?> _chooseAvailableAgent(List<dynamic> agents) async {
    for (final agent in agents) {
      final channels = await ChannelService.getAgentServiceChannels(
        agent.userId,
      );
      if (channels.length < 3) return agent.userId;
    }
    return null;
  }

  void _setError(String message) {
    setState(() {
      _error = message;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _latCtrl.dispose();
    _lngCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7EAEA),
      appBar: AppBar(
        title: const Text('Service'),
        backgroundColor: const Color.fromARGB(255, 52, 43, 182),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CoordinateInputFields(latCtrl: _latCtrl, lngCtrl: _lngCtrl),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _pickPoiAndConnect,
              child:
                  _loading
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Text('Find Service Agent'),
            ),
            const SizedBox(height: 16),
            if (_error != null) ErrorMessage(message: _error!),
          ],
        ),
      ),
    );
  }
}

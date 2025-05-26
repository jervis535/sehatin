import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/poi_model.dart';
import '../services/customer_service_service.dart';
import '../services/channel_service.dart';
import 'nearby_poi_screen.dart';
import 'chat_screen.dart';

class ServiceScreen extends StatefulWidget {
  final UserModel user;
  const ServiceScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _pickPoiAndConnect() async {
    if (_error != null) return;

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
        setState(() {
          _error = 'No service agents at "${poi.name}"';
          _loading = false;
        });
        return;
      }

      int? chosenAgentId;
      for (final cs in agents) {
        final csChannels = await ChannelService.getAgentServiceChannels(cs.userId);
        if (csChannels.length < 3) {
          chosenAgentId = cs.userId;
          break;
        }
      }

      if (chosenAgentId == null) {
        setState(() {
          _error = 'All agents at "${poi.name}" are busy. Try later.';
          _loading = false;
        });
        return;
      }

      final channelId = await ChannelService.createServiceChannel(
        widget.user.id,
        chosenAgentId,
      );
      if (channelId != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              channelId: channelId,
              user: widget.user,
            ),
          ),
        );
      } else {
        setState(() => _error = 'Failed to create service channel');
      }
    } catch (e) {
      setState(() => _error = 'Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }
  @override
  void initState() {
    super.initState();
    _checkUserLock();
  }

  Future<void> _checkUserLock() async {
    final existing = await ChannelService.getUserServiceChannels(widget.user.id);
    if (existing.isNotEmpty) {
      setState(() {
        _error = 'You already have an active service request.';
        _loading = false;
      });
    }
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
      appBar: AppBar(title: const Text('Service')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _latCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Your Latitude'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _lngCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Your Longitude'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _pickPoiAndConnect,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Find Service Agent'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }
}

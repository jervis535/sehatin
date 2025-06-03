import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/user_model.dart';
import '../../models/poi_model.dart';
import '../../services/customer_service_service.dart';
import '../../services/channel_service.dart';
import '../chat/chat_screen.dart';
import '../nearby_poi/nearby_poi_screen.dart';
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

  Future<List<double>> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // Check location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // Get the current position
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // Return latitude and longitude as a list of doubles
    return [position.latitude, position.longitude];
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
    try {
    List <double> pos = await _getCurrentLocation();
    print(pos[0]);
    print(pos[1]);
    final poi = await Navigator.push<PoiModel?>(
      context,
      MaterialPageRoute(
        builder: (_) => NearbyPoiScreen(latitude: pos[0], longitude: pos[1]),
      ),
    );
    
    if (poi == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });

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

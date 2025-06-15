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

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

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
      List<double> pos = await _getCurrentLocation();
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
        _setError('Tidak ada agen di "${poi.name}"');
        return;
      }

      final chosenAgentId = await _chooseAvailableAgent(agents);
      if (chosenAgentId == null) {
        _setError('Semua agen di "${poi.name}" sedang sibuk. Coba lagi nanti.');
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
        _setError('Gagal membuat channel layanan');
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
        title: const Text('Customer Service'),
        backgroundColor: const Color.fromARGB(255, 52, 43, 182),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.headset_mic,
                    size: 60,
                    color: Color.fromARGB(255, 52, 43, 182),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Butuh Bantuan?',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hubungi customer service untuk bantuan',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cara kerja:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 15),
                  const Text('1. Tekan tombol "Cari Agen"'),
                  const SizedBox(height: 8),
                  const Text('2. Pilih lokasi terdekat'),
                  const SizedBox(height: 8),
                  const Text('3. Mulai chat dengan agen'),
                ],
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: (_loading || _error == 'You already have an active service request.')
                ? null
                : _pickPoiAndConnect,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 52, 43, 182),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    _loading
                        ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Mencari agen...',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        )
                        : const Text(
                          'Cari Agen Customer Service',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              ),
            ),
            const SizedBox(height: 20),
            if (_error != null) ErrorMessage(message: _error!),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info, color: Colors.blue, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Pastikan GPS dan internet aktif',
                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

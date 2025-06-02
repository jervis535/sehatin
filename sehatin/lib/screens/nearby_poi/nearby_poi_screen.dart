import 'package:flutter/material.dart';
import '../../models/poi_model.dart';
import '../../services/poi_service.dart';
import 'nearby_poi_list.dart';

class NearbyPoiScreen extends StatefulWidget {
  final double latitude;
  final double longitude;

  const NearbyPoiScreen({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<NearbyPoiScreen> createState() => _NearbyPoiScreenState();
}

class _NearbyPoiScreenState extends State<NearbyPoiScreen> {
  late Future<List<PoiModel>> _futurePois;

  @override
  void initState() {
    super.initState();
    _futurePois = PoiService.calculateNearby(
      latitude: widget.latitude,
      longitude: widget.longitude,
    );
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
          'Pick a Nearby POI',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder<List<PoiModel>>(
        future: _futurePois,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final pois = snap.data ?? [];
          return NearbyPoiList(pois: pois);
        },
      ),
    );
  }
}

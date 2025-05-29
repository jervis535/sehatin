import 'package:flutter/material.dart';
import '../../models/poi_model.dart';
import '../../services/poi_service.dart';
import 'nearby_poi_list.dart';

class NearbyPoiScreen extends StatefulWidget {
  final double latitude;
  final double longitude;

  const NearbyPoiScreen({
    Key? key,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

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
      appBar: AppBar(title: const Text('Pick a Nearby POI')),
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

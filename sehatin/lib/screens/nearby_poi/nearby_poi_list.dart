import 'package:flutter/material.dart';
import '../../models/poi_model.dart';
import 'poi_list_tile.dart';

class NearbyPoiList extends StatelessWidget {
  final List<PoiModel> pois;

  const NearbyPoiList({super.key, required this.pois});

  @override
  Widget build(BuildContext context) {
    if (pois.isEmpty) {
      return const Center(child: Text('No nearby POIs found.'));
    }
    return ListView.separated(
      itemCount: pois.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (ctx, i) => PoiListTile(poi: pois[i]),
    );
  }
}

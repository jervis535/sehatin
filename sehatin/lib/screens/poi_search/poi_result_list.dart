import 'package:flutter/material.dart';
import '../../models/poi_model.dart';

class PoiResultList extends StatelessWidget {
  final List<PoiModel> pois;

  const PoiResultList({super.key, required this.pois});

  @override
  Widget build(BuildContext context) {
    if (pois.isEmpty) {
      return const Center(child: Text('No POIs found.'));
    }

    return ListView.separated(
      itemCount: pois.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final poi = pois[index];
        return ListTile(
          title: Text(poi.name),
          subtitle: Text('${poi.category} • ${poi.address}'),
          trailing: poi.verified == true
              ? const Icon(Icons.check_circle, color: Colors.green)
              : const Icon(Icons.hourglass_bottom),
          onTap: () => Navigator.pop(context, poi),
        );
      },
    );
  }
}

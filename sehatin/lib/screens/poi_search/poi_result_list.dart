import 'package:flutter/material.dart';
import '../../models/poi_model.dart';

class PoiResultList extends StatelessWidget {
  final List<PoiModel> pois;

  const PoiResultList({super.key, required this.pois});

  @override
  Widget build(BuildContext context) {
    if (pois.isEmpty) {
      return const Center(
        child: Text(
          'No POIs found.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.separated(
      itemCount: pois.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final poi = pois[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: const Color.fromARGB(
              255,
              52,
              43,
              182,
            ).withOpacity(0.7),
            child: Text(
              poi.name[0],
              style: const TextStyle(color: Colors.white),
            ),
          ),
          title: Text(poi.name),
          subtitle: Text('${poi.category} • ${poi.address}'),
          trailing:
              poi.verified == true
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : const Icon(Icons.hourglass_bottom, color: Colors.orange),
          onTap: () => Navigator.pop(context, poi),
        );
      },
    );
  }
}

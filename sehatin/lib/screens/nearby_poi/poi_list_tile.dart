import 'package:flutter/material.dart';
import '../../models/poi_model.dart';

class PoiListTile extends StatelessWidget {
  final PoiModel poi;

  const PoiListTile({Key? key, required this.poi}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final distanceText = poi.distance != null
        ? '${poi.distance!.toStringAsFixed(2)} km away'
        : 'Distance N/A';

    return ListTile(
      title: Text(poi.name),
      subtitle: Text('${poi.category} • ${poi.address}\n$distanceText'),
      isThreeLine: true,
      onTap: () => Navigator.pop(context, poi),
    );
  }
}

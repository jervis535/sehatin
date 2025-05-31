import 'package:flutter/material.dart';
import '../../models/poi_model.dart';

class PoiListTile extends StatelessWidget {
  final PoiModel poi;

  const PoiListTile({Key? key, required this.poi}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final distanceText =
        poi.distance != null
            ? '${poi.distance!.toStringAsFixed(2)} km away'
            : 'Distance N/A';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF7EAEA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        leading: const Icon(
          Icons.location_on,
          color: Colors.blueAccent,
          size: 32,
        ),
        title: Text(
          poi.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                poi.category,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(poi.address, style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.directions_walk,
                    size: 14,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    distanceText,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        isThreeLine: true,
        onTap: () => Navigator.pop(context, poi),
      ),
    );
  }
}

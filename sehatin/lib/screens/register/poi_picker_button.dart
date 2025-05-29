import 'package:flutter/material.dart';
import '../../models/poi_model.dart';

class PoiPickerButton extends StatelessWidget {
  final PoiModel? selectedPoi;
  final VoidCallback onPick;
  const PoiPickerButton({Key? key, this.selectedPoi, required this.onPick}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPick,
      icon: const Icon(Icons.search),
      label: Text(selectedPoi != null ? 'POI: ${selectedPoi!.name}' : 'Select POI'),
    );
  }
}

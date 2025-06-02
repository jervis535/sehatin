import 'package:flutter/material.dart';
import '../../models/poi_model.dart';
import '../../widgets/custom_text_field.dart';

class RolePoiSection extends StatelessWidget {
  final String role;
  final TextEditingController specCtrl;
  final PoiModel? selectedPoi;
  final VoidCallback onPickPoi;
  final bool isDoctor;

  const RolePoiSection({
    super.key,
    required this.role,
    required this.specCtrl,
    required this.selectedPoi,
    required this.onPickPoi,
    required this.isDoctor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isDoctor) ...[
          CustomTextField(controller: specCtrl, label: 'Specialization'),
          const SizedBox(height: 8),
        ],
        TextButton.icon(
          onPressed: onPickPoi,
          icon: const Icon(Icons.search),
          label: Text(
            selectedPoi != null ? 'POI: ${selectedPoi!.name}' : 'Select POI',
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

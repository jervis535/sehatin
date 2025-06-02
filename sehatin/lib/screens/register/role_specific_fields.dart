import 'package:flutter/material.dart';
import '../../models/poi_model.dart';
import '../../widgets/custom_text_field.dart';
import 'poi_picker_button.dart';
import 'evidence_picker_button.dart';

class RoleSpecificFields extends StatelessWidget {
  final String role;
  final TextEditingController specializationCtrl;
  final PoiModel? selectedPoi;
  final VoidCallback onPickPoi;
  final VoidCallback onPickEvidence;
  final bool evidencePicked;

  const RoleSpecificFields({
    super.key,
    required this.role,
    required this.specializationCtrl,
    required this.selectedPoi,
    required this.onPickPoi,
    required this.onPickEvidence,
    required this.evidencePicked,
  });

  @override
  Widget build(BuildContext context) {
    if (role == 'user') return const SizedBox.shrink();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (role == 'doctor') ...[
        CustomTextField(controller: specializationCtrl, label: 'Specialization'),
        const SizedBox(height: 8),
      ],
      PoiPickerButton(selectedPoi: selectedPoi, onPick: onPickPoi),
      const SizedBox(height: 8),
      EvidencePickerButton(picked: evidencePicked, onPick: onPickEvidence),
    ]);
  }
}

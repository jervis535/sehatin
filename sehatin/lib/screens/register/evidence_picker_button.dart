import 'package:flutter/material.dart';

class EvidencePickerButton extends StatelessWidget {
  final bool picked;
  final VoidCallback onPick;

  const EvidencePickerButton({Key? key, required this.picked, required this.onPick})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPick,
      icon: const Icon(Icons.upload_file),
      label: Text(picked ? 'Image Selected' : 'Upload Evidence'),
    );
  }
}

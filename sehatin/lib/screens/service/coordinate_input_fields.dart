import 'package:flutter/material.dart';

class CoordinateInputFields extends StatelessWidget {
  final TextEditingController latCtrl;
  final TextEditingController lngCtrl;

  const CoordinateInputFields({
    Key? key,
    required this.latCtrl,
    required this.lngCtrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: latCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Your Latitude'),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: lngCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Your Longitude'),
        ),
      ],
    );
  }
}

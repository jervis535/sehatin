import 'package:flutter/material.dart';

class RoleSpecificFields extends StatelessWidget {
  final String role;
  final TextEditingController specializationController;
  final TextEditingController poiIdController;

  const RoleSpecificFields({
    super.key,
    required this.role,
    required this.specializationController,
    required this.poiIdController,
  });

  @override
  Widget build(BuildContext context) {
    if (role == 'doctor') {
      return Column(
        children: [
          TextField(
            controller: specializationController,
            decoration: const InputDecoration(labelText: 'Specialization'),
          ),
          TextField(
            controller: poiIdController,
            decoration: const InputDecoration(labelText: 'POI ID'),
            keyboardType: TextInputType.number,
          ),
        ],
      );
    } else if (role == 'customer_service') {
      return TextField(
        controller: poiIdController,
        decoration: const InputDecoration(labelText: 'POI ID'),
        keyboardType: TextInputType.number,
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}

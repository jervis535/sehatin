import 'package:flutter/material.dart';

class ConsultationForm extends StatelessWidget {
  final List<String> specializations;
  final String? selectedSpecialization;
  final void Function(String?) onSelectSpecialization;
  final VoidCallback onSubmit;
  final String? errorMessage;

  const ConsultationForm({
    super.key,
    required this.specializations,
    required this.selectedSpecialization,
    required this.onSelectSpecialization,
    required this.onSubmit,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (errorMessage != null) ...[
            Text(errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
          ],
          DropdownButtonFormField<String>(
            value: selectedSpecialization,
            items: specializations
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: onSelectSpecialization,
            decoration: const InputDecoration(labelText: 'Specialization'),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onSubmit,
            child: const Text('Find Doctor & Chat'),
          ),
        ],
      ),
    );
  }
}

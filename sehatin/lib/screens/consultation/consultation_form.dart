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
    return Container(
      color: const Color(0xFFFFE6E6),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (errorMessage != null) ...[
            Text(
              errorMessage!,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
          ],
          DropdownButtonFormField<String>(
            value: selectedSpecialization,
            items:
                specializations
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
            onChanged: onSelectSpecialization,
            decoration: InputDecoration(
              labelText: 'Specialization',
              labelStyle: const TextStyle(color: Color(0xFFB87575)),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFFB87575)),
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 218, 195, 199),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 3,
              ),
              child: const Text(
                'Find Doctor & Chat',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

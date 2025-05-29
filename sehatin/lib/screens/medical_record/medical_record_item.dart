import 'package:flutter/material.dart';
import '../../models/medical_record_model.dart';

class MedicalRecordItem extends StatelessWidget {
  final MedicalRecord record;

  const MedicalRecordItem({Key? key, required this.record}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        title: Text('Medications: ${record.medications}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Conditions: ${record.medicalConditions}'),
            Text('Notes: ${record.notes}'),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../models/medical_record_model.dart';
import 'medical_record_item.dart';

class MedicalRecordList extends StatelessWidget {
  final List<MedicalRecord> records;

  const MedicalRecordList({Key? key, required this.records}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return const Center(child: Text('No medical history found.'));
    }
    return ListView.builder(
      itemCount: records.length,
      itemBuilder: (context, index) {
        return MedicalRecordItem(record: records[index]);
      },
    );
  }
}

import 'package:flutter/material.dart';
import '../../models/medical_record_model.dart';
import 'medical_record_item.dart';

class MedicalRecordList extends StatelessWidget {
  final bool showUser;
  final bool showDoctor;
  final List<MedicalRecord> records;

  const MedicalRecordList({super.key, required this.records, this.showUser=false, this.showDoctor=false});

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return const Center(child: Text('No medical records found.'));
    }
    return ListView.builder(
      itemCount: records.length,
      itemBuilder: (context, index) {
        return MedicalRecordItem(record: records[index],showUser: showUser, showDoctor: showDoctor,);
      },
    );
  }
}

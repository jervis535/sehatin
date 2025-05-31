import 'package:flutter/material.dart';
import '../../models/medical_record_model.dart';
import '../../services/medical_record_service.dart';
import 'medical_record_list.dart';
import '../../models/user_model.dart';

class MedicalRecordScreen extends StatefulWidget {
  final UserModel user;
  const MedicalRecordScreen({super.key, required this.user});

  @override
  State<MedicalRecordScreen> createState() => _MedicalRecordScreenState();
}

class _MedicalRecordScreenState extends State<MedicalRecordScreen> {
  late Future<List<MedicalRecord>> _futureHistory;

  @override
  void initState() {
    super.initState();
    _futureHistory = MedicalRecordService.getByUserId(widget.user.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical History'),
        backgroundColor: const Color.fromARGB(255, 52, 43, 182),
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<MedicalRecord>>(
        future: _futureHistory,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final history = snapshot.data ?? [];
          return MedicalRecordList(records: history);
        },
      ),
    );
  }
}

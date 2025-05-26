import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/medical_record_model.dart';
import '../services/medical_record_service.dart';

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
      appBar: AppBar(title: const Text('Medical History')),
      body: FutureBuilder<List<MedicalRecord>>(
        future: _futureHistory,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No medical history found.'));
          }

          final history = snapshot.data!;
          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final entry = history[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text('Medications: ${entry.medications}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Conditions: ${entry.medicalConditions}'),
                      Text('Notes: ${entry.notes}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

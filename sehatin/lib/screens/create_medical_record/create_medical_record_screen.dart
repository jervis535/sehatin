import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import 'medical_record_form.dart';
import 'user_picker_button.dart';

class CreateMedicalRecordScreen extends StatefulWidget {
  final UserModel user;
  const CreateMedicalRecordScreen({super.key, required this.user});

  @override
  State<CreateMedicalRecordScreen> createState() =>
      _CreateMedicalRecordScreenState();
}

class _CreateMedicalRecordScreenState extends State<CreateMedicalRecordScreen> {
  UserModel? _selectedUser;

  void _setUser(UserModel user) {
    setState(() => _selectedUser = user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Medical Record'),
        backgroundColor: const Color.fromARGB(255, 52, 43, 182),
        elevation: 0,
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          color: Color.fromARGB(255, 255, 255, 255),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            UserPickerButton(
              selectedUser: _selectedUser,
              onUserSelected: _setUser,
            ),
            const SizedBox(height: 16),
            MedicalRecordForm(selectedUser: _selectedUser,user: widget.user),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/medical_record_service.dart';
import '../widgets/custom_text_field.dart';
import 'user_search_screen.dart';

class CreateMedicalRecordScreen extends StatefulWidget {
  const CreateMedicalRecordScreen({super.key});

  @override
  State<CreateMedicalRecordScreen> createState() => _CreateMedicalRecordScreenState();
}

class _CreateMedicalRecordScreenState extends State<CreateMedicalRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _medicationsController = TextEditingController();
  final _conditionsController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isSubmitting = false;
  String? _error;

  UserModel? _selectedUser;

  Future<void> _pickUser() async {
    final user = await Navigator.push<UserModel?>(
      context,
      MaterialPageRoute(builder: (_) => const UserSearchScreen()),
    );
    if (user != null) {
      setState(() {
        _selectedUser = user;
      });
    }
  }

  Future<void> _submit() async {
    if (_selectedUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a user first')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      await MedicalRecordService.createRecord(
        userId: _selectedUser!.id,
        medications: _medicationsController.text.trim(),
        medicalConditions: _conditionsController.text.trim(),
        notes: _notesController.text.trim(),
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medical record created')),
        );
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _medicationsController.dispose();
    _conditionsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Medical Record')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextButton.icon(
              onPressed: _pickUser,
              icon: const Icon(Icons.person_search),
              label: Text(
                _selectedUser != null
                    ? 'User: ${_selectedUser!.username}'
                    : 'Select User',
              ),
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextField(
                    controller: _medicationsController,
                    label: 'Medications',
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: _conditionsController,
                    label: 'Medical Conditions',
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: _notesController,
                    label: 'Notes',
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Submit'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

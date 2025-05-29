import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/medical_record_service.dart';
import '../../widgets/custom_text_field.dart';

class MedicalRecordForm extends StatefulWidget {
  final UserModel? selectedUser;
  const MedicalRecordForm({super.key, required this.selectedUser});

  @override
  State<MedicalRecordForm> createState() => _MedicalRecordFormState();
}

class _MedicalRecordFormState extends State<MedicalRecordForm> {
  final _formKey = GlobalKey<FormState>();
  final _medicationsController = TextEditingController();
  final _conditionsController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _medicationsController.dispose();
    _conditionsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (widget.selectedUser == null) {
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
        userId: widget.selectedUser!.id,
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
  Widget build(BuildContext context) {
    return Column(
      children: [
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
    );
  }
}

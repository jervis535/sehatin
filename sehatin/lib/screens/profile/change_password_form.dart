import 'package:flutter/material.dart';
import '../../widgets/custom_text_field.dart';

class ChangePasswordForm extends StatelessWidget {
  final TextEditingController oldPassCtrl;
  final TextEditingController newPassCtrl;
  final VoidCallback? onChange;
  final bool isSaving;

  const ChangePasswordForm({
    Key? key,
    required this.oldPassCtrl,
    required this.newPassCtrl,
    required this.onChange,
    required this.isSaving,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Change Password', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        CustomTextField(
          controller: oldPassCtrl,
          label: 'Old Password',
          isPassword: true,
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: newPassCtrl,
          label: 'New Password',
          isPassword: true,
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: onChange,
          child: isSaving
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Change Password'),
        ),
      ],
    );
  }
}

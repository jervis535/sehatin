import 'package:flutter/material.dart';
import '../../widgets/custom_text_field.dart';

class ProfileInfoForm extends StatelessWidget {
  final TextEditingController usernameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController telCtrl;
  final TextEditingController currentPassCtrl;
  final VoidCallback? onSave;
  final bool isSaving;

  final bool showEmail;
  final bool showTel;
  final bool showCurrentPass;

  const ProfileInfoForm({
    super.key,
    required this.usernameCtrl,
    required this.emailCtrl,
    required this.telCtrl,
    required this.currentPassCtrl,
    required this.onSave,
    required this.isSaving,
    this.showEmail = true,
    this.showTel = true,
    this.showCurrentPass = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(controller: usernameCtrl, label: 'Username'),
        CustomTextField(controller: emailCtrl, label: 'Email'),
        CustomTextField(controller: telCtrl, label: 'Telephone'),
        CustomTextField(controller: currentPassCtrl,label: 'Current Password',isPassword: true,),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: onSave,
          child:
              isSaving
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Text('Save Username'),
        ),
      ],
    );
  }
}

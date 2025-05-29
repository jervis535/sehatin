import 'package:flutter/material.dart';
import '../../widgets/custom_text_field.dart';

class CredentialFields extends StatelessWidget {
  final TextEditingController emailCtrl, passwordCtrl, nameCtrl;
  const CredentialFields({
    Key? key,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.nameCtrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      CustomTextField(controller: emailCtrl, label: 'Email'),
      const SizedBox(height: 8),
      CustomTextField(controller: passwordCtrl, label: 'Password', isPassword: true),
      const SizedBox(height: 8),
      CustomTextField(controller: nameCtrl, label: 'Name'),
    ]);
  }
}

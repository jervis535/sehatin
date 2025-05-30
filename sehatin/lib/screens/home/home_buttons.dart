import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../consultation/consultation_screen.dart';
import '../medical_record/medical_record_screen.dart';
import '../channels/channels_screen.dart';
import '../service/service_screen.dart';
import '../create_medical_record/create_medical_record_screen.dart';

class HomeButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const HomeButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(onPressed: onPressed, child: Text(label)),
    );
  }
}

List<Widget> buildRoleBasedButtons(BuildContext context, UserModel user) {
  final role = user.role;
  final List<Widget> buttons = [];

  void add(String label, Widget screen) {
    buttons.add(
      HomeButton(
        label: label,
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => screen),
            ),
      ),
    );
  }

  if (role == 'user') {
    add('Consultation', ConsultationScreen(user: user));
    add('Chat', ChannelsScreen(user: user));
    add('Service', ServiceScreen(user: user));
    add('Medical History', MedicalRecordScreen(user: user));
  } else if (role == 'doctor') {
    add('Chat', ChannelsScreen(user: user));
    add('Medical History', MedicalRecordScreen(user: user));
  } else if (role == 'customer service') {
    add('Chat', ChannelsScreen(user: user));
    add('Create Medical Record', CreateMedicalRecordScreen());
  }

  return buttons;
}

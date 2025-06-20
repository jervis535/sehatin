import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../consultation/consultation_screen.dart';
import '../medical_record/medical_record_screen.dart';
import '../channels/channels_screen.dart';
import '../service/service_screen.dart';
import '../create_medical_record/create_medical_record_screen.dart';
import '../reviews/reviews_screen.dart';
import '../payment/bundle_screen.dart';

class RoleBasedButton extends StatelessWidget {
  final String label;
  final Widget iconWidget;
  final VoidCallback onTap;

  const RoleBasedButton({
    super.key,
    required this.label,
    required this.iconWidget,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Column(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: const Color(0xFFF4F8FC),
            child: iconWidget,
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 100,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

List<Widget> buildRoleBasedButtons(BuildContext context, UserModel user, String token) {
  final role = (user.role).trim().toLowerCase();

  if (role == 'user') {
    return [
      RoleBasedButton(
        label: 'Consultation',
        iconWidget: ColorFiltered(
          colorFilter: const ColorFilter.mode(
            Colors.grey,
            BlendMode.srcIn,
          ),
          child: Image.asset(
            'assets/doctor.png',
            width: 40,
            height: 40,
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ConsultationScreen(user: user)),
          );
        },
      ),
      RoleBasedButton(
        label: 'Chat',
        iconWidget: const Icon(Icons.chat, size: 30, color: Colors.grey),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ChannelsScreen(user: user)),
          );
        },
      ),
      RoleBasedButton(
        label: 'Service',
        iconWidget: const Icon(
          Icons.miscellaneous_services,
          size: 30,
          color: Colors.grey,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ServiceScreen(user: user)),
          );
        },
      ),
      RoleBasedButton(
        label: 'Medical records',
        iconWidget: const Icon(Icons.history, size: 30, color: Colors.grey),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => MedicalRecordScreen(user: user, showDoctor: true)),
          );
        },
      ),
      RoleBasedButton(
        label: 'Reviews',
        iconWidget: const Icon(Icons.star, size: 30, color: Colors.grey),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ReviewsScreen(reviewerId: user.id,token:token)),
          );
        },
      ),
      RoleBasedButton(
        label: 'payment',
        iconWidget: const Icon(Icons.shopping_cart, size: 30, color: Colors.grey),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => BundleScreen(user: user)),
          );
        },
      ),
    ];
  } else if (role == 'doctor') {
    return [
      RoleBasedButton(
        label: 'Chat',
        iconWidget: const Icon(Icons.chat, size: 30, color: Colors.grey),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ChannelsScreen(user: user)),
          );
        },
      ),
      RoleBasedButton(
        label: 'Create Medical Record',
        iconWidget: const Icon(Icons.create, size: 30, color: Colors.grey),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CreateMedicalRecordScreen(user:user)),
          );
        },
      ),
      RoleBasedButton(
        label: 'Medical records',
        iconWidget: const Icon(Icons.history, size: 30, color: Colors.grey),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => MedicalRecordScreen(user: user,showUser: true)),
          );
        },
      ),
    ];
  } else if (role == 'customer service') {
    return [
      RoleBasedButton(
        label: 'Chat',
        iconWidget: const Icon(Icons.chat, size: 30, color: Colors.grey),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ChannelsScreen(user: user)),
          );
        },
      ),
    ];
  } else {
    return [];
  }
}

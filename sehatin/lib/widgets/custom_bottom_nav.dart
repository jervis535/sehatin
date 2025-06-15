import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../screens/home/home_screen.dart';
import '../screens/consultation/consultation_screen.dart';
import '../screens/medical_record/medical_record_screen.dart';

class CustomBottomNav extends StatelessWidget {
  final UserModel user;
  final int selectedIndex;
  final String token;

  const CustomBottomNav({
    super.key,
    required this.user,
    required this.token,
    this.selectedIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final role = user.role.trim().toLowerCase();

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 80,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _buildBottomNavItems(context, role),
        ),
      ),
    );
  }

  List<Widget> _buildBottomNavItems(BuildContext context, String role) {
    if (role == 'user') {
      return [
        _navItem(context, Icons.home, 'HOME', 0, () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => HomeScreen(user: user, token: token),
            ),
          );
        }),
        _navItemImage(context, 'assets/doctor.png', 'KONSULTASI ONLINE', 40, 1, () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ConsultationScreen(user: user),
            ),
          );
        }),
        _navItemImage(context, 'assets/history.png', 'RIWAYAT', 28, 2, () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MedicalRecordScreen(user: user),
            ),
          );
        }),
      ];
    } else {
      return [
        _navItem(context, Icons.home, 'HOME', 0, () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => HomeScreen(user: user, token: token),
            ),
          );
        }),
      ];
    }
  }

  Widget _navItem(
    BuildContext context,
    IconData icon,
    String label,
    int index,
    VoidCallback onTap,
  ) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSelected ? Colors.blue : Colors.black),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: isSelected ? Colors.blue : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItemImage(
    BuildContext context,
    String assetPath,
    String label,
    double size,
    int index,
    VoidCallback onTap,
  ) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ColorFiltered(
            colorFilter: isSelected
                ? const ColorFilter.mode(Colors.blue, BlendMode.srcIn)
                : const ColorFilter.mode(Colors.black, BlendMode.srcIn),
            child: Image.asset(assetPath, width: size, height: size),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: isSelected ? Colors.blue : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
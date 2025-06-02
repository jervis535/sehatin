import 'package:flutter/material.dart';

class LogoutButton extends StatelessWidget {
  final VoidCallback onLogout;
  const LogoutButton({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onLogout,
      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
      child: const Text('Logout'),
    );
  }
}

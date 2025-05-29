import 'package:flutter/material.dart';

class LogoutButton extends StatelessWidget {
  final VoidCallback onLogout;
  const LogoutButton({Key? key, required this.onLogout}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onLogout,
      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
      child: const Text('Logout'),
    );
  }
}

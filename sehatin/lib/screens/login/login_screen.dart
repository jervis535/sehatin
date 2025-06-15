import 'package:flutter/material.dart';
import 'login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCEEEE),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Custom Wave Background
                SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Image.asset(
                      'assets/wave.png', // export bentuk wave dari Figma
                      fit: BoxFit.cover,
                      height: 220,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 90),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: LoginForm(),
            ),
          ],
        ),
      ),
    );
  }
}

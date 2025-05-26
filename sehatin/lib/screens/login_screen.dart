import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/auth_text_field.dart';
import 'register_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final authService = AuthService();
  String error = '';

  void _login() async {
  try {
    final result = await authService.login(usernameController.text, passwordController.text);
    final user = result['user'];
    final token = result['token'];

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Welcome ${user.email}!')));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(user: user, token: token),
      ),
    );
  } catch (e) {
    setState(() => error = e.toString());
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AuthTextField(controller: usernameController, label: 'Username'),
            AuthTextField(controller: passwordController, label: 'Password', isPassword: true),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _login, child: const Text('Login')),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
              child: const Text('Don’t have an account? Register'),
            ),
            if (error.isNotEmpty) Text(error, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}

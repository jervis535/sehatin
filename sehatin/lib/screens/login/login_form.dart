import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/auth_text_field.dart';
import '../register/register_screen.dart';
import '../home/home_screen.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _authService = AuthService();
  String _error = '';

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    try {
      final result = await _authService.login(
        _usernameCtrl.text.trim(),
        _passwordCtrl.text.trim(),
      );
      final user = result['user'];
      final token = result['token'];

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Welcome ${user.email}!')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(user: user, token: token),
        ),
      );
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AuthTextField(controller: _usernameCtrl, label: 'Username'),
        AuthTextField(
          controller: _passwordCtrl,
          label: 'Password',
          isPassword: true,
        ),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: _login, child: const Text('Login')),
        TextButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RegisterScreen()),
          ),
          child: const Text('Don’t have an account? Register'),
        ),
        if (_error.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(_error, style: const TextStyle(color: Colors.red)),
        ],
      ],
    );
  }
}

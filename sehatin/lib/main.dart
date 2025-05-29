import 'package:flutter/material.dart';
import 'package:sehatin/services/session_service.dart';
import 'package:sehatin/services/auth_service.dart';
import 'package:sehatin/models/user_model.dart';
import 'package:sehatin/screens/login/login_screen.dart';
import 'package:sehatin/screens/home/home_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sehatin',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const RootDecider(),
      routes: {
        '/login': (_) => const LoginScreen(),
      },
    );
  }
}

class RootDecider extends StatelessWidget {
  const RootDecider({super.key});

  Future<Widget> _decide() async {
    final token = await SessionService.getToken();
    final userId = await SessionService.getUserId();

    if (token != null && userId != null) {
      try {
        final userJson =
            await AuthService.fetchUserWithToken(userId, token);
        final user = UserModel.fromJson(userJson);
        return HomeScreen(user: user, token: token);
      } catch (_) {
        await SessionService.clearSession();
      }
    }
    return const LoginScreen();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _decide(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return snapshot.data!;
      },
    );
  }
}

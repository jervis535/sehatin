import 'package:flutter/material.dart';
import 'package:sehatin/services/customer_service_service.dart';
import '../../models/user_model.dart';
import '../../services/doctor_service.dart';
import 'home_buttons.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final UserModel user;
  final String token;

  const HomeScreen({
    super.key,
    required this.user,
    required this.token,
  });

  @override
  State<HomeScreen> createState() => _HomePageState();
}

class _HomePageState extends State<HomeScreen> {
  bool? isVerified;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _checkVerificationStatus();
  }

  Future<void> _checkVerificationStatus() async {
    switch (widget.user.role) {
      case 'doctor':
        final doctor = await DoctorService.getByUserId(widget.user.id);
        isVerified = doctor?.verified ?? false;
        break;
      case 'customer service':
        final csEntry =
            await CustomerServiceService.getOneByUserId(widget.user.id);
        isVerified = csEntry?.verified ?? false;
        break;
      default:
        isVerified = true;
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (isVerified == false) {
      return Scaffold(
        appBar: AppBar(title: const Text('Home')),
        body: const Center(
          child: Text(
            'Please wait as the admins verify your account.',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          HomeButton(
            label: 'Profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(
                    user: widget.user,
                    token: widget.token,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          ...buildRoleBasedButtons(context, widget.user),
        ],
      ),
    );
  }
}

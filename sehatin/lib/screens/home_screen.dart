import 'package:flutter/material.dart';
import 'package:sehatin/services/customer_service_service.dart';
import '../models/user_model.dart';
import '../services/doctor_service.dart';
import 'consultation_screen.dart';
import 'medical_record_screen.dart';
import 'channels_screen.dart';
import 'service_screen.dart';
import 'profile_screen.dart';
import 'create_medical_record_screen.dart';

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
    if (widget.user.role == 'doctor') {
      final doctor = await DoctorService.getByUserId(widget.user.id);
      setState(() {
        isVerified = doctor?.verified ?? false;
        loading = false;
      });
    } else if (widget.user.role == 'customer service') {
      final csEntry =
          await CustomerServiceService.getOneByUserId(widget.user.id);
      setState(() {
        isVerified = csEntry?.verified ?? false;
        loading = false;
      });
    } else {
      setState(() {
        isVerified = true;
        loading = false;
      });
    }
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
          _buildButton(context, 'Profile', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfileScreen(
                  user: widget.user,
                  token: widget.token,
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          ..._buildButtons(context),
        ],
      ),
    );
  }

  List<Widget> _buildButtons(BuildContext context) {
    final role = widget.user.role;

    if (role == 'user') {
      return [
        _buildButton(context, 'Consultation', () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ConsultationScreen(user: widget.user),
            ),
          );
        }),
        _buildButton(context, 'Chat', () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChannelsScreen(user: widget.user),
            ),
          );
        }),
        _buildButton(context, 'Service', () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ServiceScreen(user: widget.user),
            ),
          );
        }),
        _buildButton(context, 'Medical History', () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  MedicalRecordScreen(user: widget.user),
            ),
          );
        }),
      ];
    } else if (role == 'doctor') {
      return [
        _buildButton(context, 'Chat', () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChannelsScreen(user: widget.user),
            ),
          );
        }),
        _buildButton(context, 'Medical History', () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  MedicalRecordScreen(user: widget.user),
            ),
          );
        }),
      ];
    } else if (role == 'customer service') {
      return [
        _buildButton(context, 'Chat', () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChannelsScreen(user: widget.user),
            ),
          );
        }),
        _buildButton(context, 'create medical record', () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateMedicalRecordScreen(),
            ),
          );
        }),
      ];
    }
    return [];
  }

  Widget _buildButton(
      BuildContext context, String label, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(onPressed: onPressed, child: Text(label)),
    );
  }
}

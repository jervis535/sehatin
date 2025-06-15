import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/poi_model.dart';
import '../../services/auth_service.dart';
import '../../services/evidence_service.dart';
import '../home/home_screen.dart';
import '../poi_search/poi_search_screen.dart';
import 'credential_fields.dart';
import 'role_selector.dart';
import 'role_specific_fields.dart';
import '../login/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedRole = 'user';
  PoiModel? _selectedPoi;
  File? _evidenceFile;
  String? _evidenceBase64;

  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _specializationCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    _specializationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPoi() async {
    final poi = await Navigator.push<PoiModel?>(
      context,
      MaterialPageRoute(builder: (_) => const PoiSearchScreen()),
    );
    if (poi != null) setState(() => _selectedPoi = poi);
  }

  Future<void> _pickEvidence() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 80,
    );
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _evidenceFile = File(picked.path);
        _evidenceBase64 = base64Encode(bytes);
      });
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if ((_selectedRole == 'doctor' &&
            (_specializationCtrl.text.isEmpty || _selectedPoi == null)) ||
        (_selectedRole == 'customer service' && _selectedPoi == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }
    if ((_selectedRole != 'user') && _evidenceBase64 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload evidence image')),
      );
      return;
    }

    try {
      final resp = await AuthService.register(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
        name: _nameCtrl.text.trim(),
        role: _selectedRole,
        specialization:
            _selectedRole == 'doctor' ? _specializationCtrl.text.trim() : null,
        poiId: _selectedPoi?.id.toString(),
      );
      final user = resp['user'], token = resp['token'];

      if (_selectedRole != 'user' && _evidenceBase64 != null) {
        await EvidenceService.uploadEvidence(
          userId: user.id,
          base64Image: _evidenceBase64!,
        );
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(user: user, token: token)),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

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
                SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Image.asset(
                      'assets/wave.png',
                      fit: BoxFit.cover,
                      height: 220,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 90),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    CredentialFields(
                      emailCtrl: _emailCtrl,
                      passwordCtrl: _passwordCtrl,
                      nameCtrl: _nameCtrl,
                    ),
                    const SizedBox(height: 16),
                    RoleSelector(
                      selectedRole: _selectedRole,
                      onRoleChanged: (r) {
                        if (r != null) {
                          setState(() {
                            _selectedRole = r;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    RoleSpecificFields(
                      role: _selectedRole,
                      specializationCtrl: _specializationCtrl,
                      selectedPoi: _selectedPoi,
                      onPickPoi: _pickPoi,
                      onPickEvidence: _pickEvidence,
                      evidencePicked: _evidenceFile != null,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF38B83),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'REGISTER',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(thickness: 1, color: Colors.grey),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFF38B83)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'LOGIN',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFFF38B83),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/poi_model.dart';
import '../services/auth_service.dart';
import '../services/evidence_service.dart';
import '../widgets/custom_text_field.dart';
import 'poi_search_screen.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final specializationController = TextEditingController();

  String selectedRole = 'user';
  PoiModel? _selectedPoi;

  File? _evidenceImageFile;
  String? _evidenceBase64;

  void _pickPoi() async {
    final poi = await Navigator.push<PoiModel?>(
      context,
      MaterialPageRoute(builder: (_) => const PoiSearchScreen()),
    );
    if (poi != null) {
      setState(() {
        _selectedPoi = poi;
      });
    }
  }

  Future<void> _pickEvidenceImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      final imageBytes = await pickedFile.readAsBytes();
      setState(() {
        _evidenceImageFile = File(pickedFile.path);
        _evidenceBase64 = base64Encode(imageBytes);
      });
    }
  }

  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    final role = selectedRole;
    final specialization = specializationController.text.trim();
    final poiId = _selectedPoi?.id;

    if ((role == 'doctor' && (specialization.isEmpty || poiId == null)) ||
        (role == 'customer service' && poiId == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }
    if ((role == 'doctor' || role == 'customer service') && _evidenceBase64 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload evidence image')),
      );
      return;
    }

    try {
      final response = await AuthService.register(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        name: nameController.text.trim(),
        role: role,
        specialization: role == 'doctor' ? specialization : null,
        poiId: poiId?.toString(),
      );
      final user = response['user'];
      final token = response['token'];

      if ((role == 'doctor' || role == 'customer service') && _evidenceBase64 != null) {
        await EvidenceService.uploadEvidence(
          userId: user.id,
          base64Image: _evidenceBase64!,
        );
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(user: user, token: token),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Widget _buildRoleSpecificFields() {
    switch (selectedRole) {
      case 'doctor':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              controller: specializationController,
              label: 'Specialization',
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              icon: const Icon(Icons.search),
              label: Text(_selectedPoi != null
                  ? 'POI: ${_selectedPoi!.name}'
                  : 'Select POI'),
              onPressed: _pickPoi,
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              icon: const Icon(Icons.upload_file),
              label: Text(_evidenceImageFile != null
                  ? 'Image Selected'
                  : 'Upload Evidence'),
              onPressed: _pickEvidenceImage,
            ),
          ],
        );
      case 'customer service':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton.icon(
              icon: const Icon(Icons.search),
              label: Text(_selectedPoi != null
                  ? 'POI: ${_selectedPoi!.name}'
                  : 'Select POI'),
              onPressed: _pickPoi,
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              icon: const Icon(Icons.upload_file),
              label: Text(_evidenceImageFile != null
                  ? 'Image Selected'
                  : 'Upload Evidence'),
              onPressed: _pickEvidenceImage,
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              CustomTextField(controller: emailController, label: 'Email'),
              const SizedBox(height: 8),
              CustomTextField(
                controller: passwordController,
                label: 'Password',
                isPassword: true,
              ),
              const SizedBox(height: 8),
              CustomTextField(controller: nameController, label: 'Name'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedRole,
                onChanged: (v) => setState(() => selectedRole = v!),
                items: const [
                  DropdownMenuItem(value: 'user', child: Text('User')),
                  DropdownMenuItem(value: 'doctor', child: Text('Doctor')),
                  DropdownMenuItem(
                      value: 'customer service', child: Text('Customer Service')),
                ],
                decoration: const InputDecoration(labelText: 'Role'),
              ),
              const SizedBox(height: 16),
              _buildRoleSpecificFields(),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _register,
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
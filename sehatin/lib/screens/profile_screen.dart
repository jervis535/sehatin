import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/doctor_model.dart';
import '../models/customer_service_model.dart';
import '../models/poi_model.dart';
import '../services/user_service.dart';
import '../services/doctor_service.dart';
import '../services/customer_service_service.dart';
import '../services/poi_service.dart';
import '../widgets/custom_text_field.dart';
import 'poi_search_screen.dart';
import '../services/session_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel user;
  final String token;

  const ProfileScreen({
    Key? key,
    required this.user,
    required this.token,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loading = true, _saving = false, _pwSaving = false;
  String? _error;


  late TextEditingController _usernameCtrl,
      _emailCtrl,
      _telCtrl,
      _currentPassCtrl;

  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();

  late TextEditingController _specCtrl;


  PoiModel? _selectedPoi;

  DoctorModel? _doctor;
  CustomerServiceModel? _cs;

  @override
  void initState() {
    super.initState();
    _usernameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _telCtrl = TextEditingController();
    _currentPassCtrl = TextEditingController();
    _specCtrl = TextEditingController();
    _loadProfile();
  }

  Future<void> _logout() async {
  await SessionService.clearSession();
  Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => LoginScreen(),
      ),
    );
}

  Future<void> _loadProfile() async {
    try {
      final u = await UserService.fetchUser(widget.user.id, widget.token);
      _usernameCtrl.text = u['username'];
      _emailCtrl.text = u['email'];
      _telCtrl.text = (u['telno'] ?? '');

      if (widget.user.role == 'doctor') {
        _doctor = await DoctorService.getByUserId(widget.user.id);
        _specCtrl.text = _doctor?.specialization ?? '';
        if (_doctor?.poiId != null) {
          _selectedPoi =
              (await PoiService.fetchPois()).firstWhere((p) => p.id == _doctor!.poiId);
        }
      } else if (widget.user.role == 'customer service') {
        _cs = await CustomerServiceService.getOneByUserId(widget.user.id);
        if (_cs?.poiId != null) {
          _selectedPoi =
              (await PoiService.fetchPois()).firstWhere((p) => p.id == _cs!.poiId);
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _pickPoi() async {
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

  Future<void> _saveProfile() async {
    if (_currentPassCtrl.text.isEmpty) {
      setState(() => _error = 'Enter current password');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await UserService.updateUser(
        userId: widget.user.id,
        username: _usernameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        telno: _telCtrl.text.trim(),
        currentPassword: _currentPassCtrl.text,
        token: widget.token,
      );

      if (widget.user.role == 'doctor' && _doctor != null) {
        await DoctorService.updateDoctor(
          userId: widget.user.id,
          specialization: _specCtrl.text.trim(),
          poiId: _selectedPoi!.id,
          token: widget.token,
        );
      } else if (widget.user.role == 'customer service' && _cs != null) {
        await CustomerServiceService.updateCustomerService(
          entryId: _cs!.userId,
          poiId: _selectedPoi!.id,
          token: widget.token,
        );
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Profile updated')));
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _saving = false);
    }
  }

  Future<void> _changePassword() async {
    if (_oldPassCtrl.text.isEmpty || _newPassCtrl.text.isEmpty) {
      setState(() => _error = 'Fill both password fields');
      return;
    }
    setState(() {
      _pwSaving = true;
      _error = null;
    });
    try {
      await UserService.changePassword(
        userId: widget.user.id,
        oldPassword: _oldPassCtrl.text,
        newPassword: _newPassCtrl.text,
        token: widget.token,
      );
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Password changed')));
      _oldPassCtrl.clear();
      _newPassCtrl.clear();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _pwSaving = false);
    }
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _telCtrl.dispose();
    _currentPassCtrl.dispose();
    _specCtrl.dispose();
    _oldPassCtrl.dispose();
    _newPassCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(children: [
          if (_error != null)
            Text(_error!, style: const TextStyle(color: Colors.red)),
          CustomTextField(
              controller: _usernameCtrl, label: 'Username'),
          const SizedBox(height: 8),
          CustomTextField(
              controller: _emailCtrl, label: 'Email'),
          const SizedBox(height: 8),
          CustomTextField(
              controller: _telCtrl, label: 'Telephone'),
          const SizedBox(height: 8),
          CustomTextField(
            controller: _currentPassCtrl,
            label: 'Current Password',
            isPassword: true,
          ),
          const SizedBox(height: 16),

          if (widget.user.role == 'doctor') ...[
            CustomTextField(
                controller: _specCtrl, label: 'Specialization'),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _pickPoi,
              icon: const Icon(Icons.search),
              label: Text(
                _selectedPoi != null
                    ? 'POI: ${_selectedPoi!.name}'
                    : 'Select POI',
              ),
            ),
            const SizedBox(height: 16),
          ]
          else if (widget.user.role == 'customer service') ...[
            TextButton.icon(
              onPressed: _pickPoi,
              icon: const Icon(Icons.search),
              label: Text(
                _selectedPoi != null
                    ? 'POI: ${_selectedPoi!.name}'
                    : 'Select POI',
              ),
            ),
            const SizedBox(height: 16),
          ],

          ElevatedButton(
            onPressed: _saving ? null : _saveProfile,
            child: _saving
                ? const CircularProgressIndicator()
                : const Text('Save Profile'),
          ),

          const Divider(height: 32),
          const Text('Change Password',
              style: TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          CustomTextField(
            controller: _oldPassCtrl,
            label: 'Old Password',
            isPassword: true,
          ),
          const SizedBox(height: 8),
          CustomTextField(
            controller: _newPassCtrl,
            label: 'New Password',
            isPassword: true,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _pwSaving ? null : _changePassword,
            child: _pwSaving
                ? const CircularProgressIndicator()
                : const Text('Change Password'),
          ),
          ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Logout'),
          ),
        ]),
      ),
    );
  }
}

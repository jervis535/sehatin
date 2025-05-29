import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../models/poi_model.dart';
import '../../models/doctor_model.dart';
import '../../models/customer_service_model.dart';
import '../../services/user_service.dart';
import '../../services/doctor_service.dart';
import '../../services/customer_service_service.dart';
import '../../services/poi_service.dart';
import '../../services/session_service.dart';
import 'profile_info_form.dart';
import 'role_poi_section.dart';
import 'change_password_form.dart';
import 'logout_button.dart';
import '../poi_search/poi_search_screen.dart';
import '../login/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel user;
  final String token;
  const ProfileScreen({Key? key, required this.user, required this.token}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loading = true, _saving = false, _pwSaving = false;
  String? _error;
  late TextEditingController _usernameCtrl, _emailCtrl, _telCtrl, _currentPassCtrl;
  late TextEditingController _specCtrl, _oldPassCtrl, _newPassCtrl;
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
    _oldPassCtrl = TextEditingController();
    _newPassCtrl = TextEditingController();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final u = await UserService.fetchUser(widget.user.id, widget.token);
      _usernameCtrl.text = u['username'];
      _emailCtrl.text = u['email'];
      _telCtrl.text = u['telno'] ?? '';

      if (widget.user.role == 'doctor') {
        _doctor = await DoctorService.getByUserId(widget.user.id);
        _specCtrl.text = _doctor?.specialization ?? '';
        if (_doctor?.poiId != null) {
          _selectedPoi = (await PoiService.fetchPois())
              .firstWhere((p) => p.id == _doctor!.poiId);
        }
      } else if (widget.user.role == 'customer service') {
        _cs = await CustomerServiceService.getOneByUserId(widget.user.id);
        if (_cs?.poiId != null) {
          _selectedPoi = (await PoiService.fetchPois())
              .firstWhere((p) => p.id == _cs!.poiId);
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
    if (poi != null) setState(() => _selectedPoi = poi);
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

  Future<void> _logout() async {
    await SessionService.clearSession();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ProfileInfoForm(
              usernameCtrl: _usernameCtrl,
              emailCtrl: _emailCtrl,
              telCtrl: _telCtrl,
              currentPassCtrl: _currentPassCtrl,
              onSave: _saving ? null : _saveProfile,
              isSaving: _saving,
            ),
            if (widget.user.role == 'doctor' || widget.user.role == 'customer service')
              RolePoiSection(
                role: widget.user.role,
                specCtrl: _specCtrl,
                selectedPoi: _selectedPoi,
                onPickPoi: _pickPoi,
                isDoctor: widget.user.role == 'doctor',
              ),
            const Divider(height: 32),
            ChangePasswordForm(
              oldPassCtrl: _oldPassCtrl,
              newPassCtrl: _newPassCtrl,
              onChange: _pwSaving ? null : _changePassword,
              isSaving: _pwSaving,
            ),
            const SizedBox(height: 16),
            LogoutButton(onLogout: _logout),
          ],
        ),
      ),
    );
  }
}

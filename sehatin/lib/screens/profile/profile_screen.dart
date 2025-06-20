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
import '../../widgets/custom_bottom_nav.dart';
import 'profile_info_form.dart';
import 'change_password_form.dart';
import '../login/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel user;
  final String token;
  const ProfileScreen({super.key, required this.user, required this.token});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loading = true, _saving = false, _pwSaving = false;
  late TextEditingController _usernameCtrl,
      _emailCtrl,
      _telCtrl,
      _currentPassCtrl;
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
          _selectedPoi = (await PoiService.fetchPois()).firstWhere(
            (p) => p.id == _doctor!.poiId,
          );
        }
      } else if (widget.user.role == 'customer service') {
        _cs = await CustomerServiceService.getOneByUserId(widget.user.id);
        if (_cs?.poiId != null) {
          _selectedPoi = (await PoiService.fetchPois()).firstWhere(
            (p) => p.id == _cs!.poiId,
          );
        }
      }
    } finally {
      setState(() => _loading = false);
    }
  }


  Future<void> _saveProfile() async {
    if (_currentPassCtrl.text.isEmpty) {
      return;
    }
    setState(() {
      _saving = true;
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile updated')));
    } finally {
      setState(() => _saving = false);
    }
  }

  Future<void> _changePassword() async {
    if (_oldPassCtrl.text.isEmpty || _newPassCtrl.text.isEmpty) {
      return;
    }
    setState(() {
      _pwSaving = true;
    });
    try {
      await UserService.changePassword(
        userId: widget.user.id,
        oldPassword: _oldPassCtrl.text,
        newPassword: _newPassCtrl.text,
        token: widget.token,
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Password changed')));
      _oldPassCtrl.clear();
      _newPassCtrl.clear();
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

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Ubah Kata Sandi'),
            content: ChangePasswordForm(
              oldPassCtrl: _oldPassCtrl,
              newPassCtrl: _newPassCtrl,
              onChange: _pwSaving ? null : _changePassword,
              isSaving: _pwSaving,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
            ],
          ),
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
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/wave3.png',
              fit: BoxFit.cover,
              height: 180,
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 80),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 30),
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _usernameCtrl.text.isEmpty
                          ? 'USERNAME'
                          : _usernameCtrl.text.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 3,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  ProfileInfoForm(
                    usernameCtrl: _usernameCtrl,
                    emailCtrl: _emailCtrl,
                    telCtrl: _telCtrl,
                    currentPassCtrl: _currentPassCtrl,
                    onSave: _saving ? null : _saveProfile,
                    isSaving: _saving,
                    showEmail: false,
                    showTel: false,
                    showCurrentPass: false,
                  ),

                  const SizedBox(height: 50),

                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFB87575),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        _buildMenuItem(
                          context,
                          icon: Icons.lock,
                          label: 'Ubah Kata Sandi',
                          onTap:
                              _pwSaving
                                  ? null
                                  : () => _showChangePasswordDialog(context),
                        ),
                        _buildDivider(),
                        _buildMenuItem(
                          context,
                          icon: Icons.logout,
                          label: 'Keluar',
                          onTap: _logout,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
          CustomBottomNav(user: widget.user, token: widget.token),


          Positioned(
            top: 40,
            left: 12,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 50,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Icon(Icons.arrow_back, color: Colors.white, size: 30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      enabled: onTap != null,
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      color: Colors.white54,
      indent: 24,
      endIndent: 24,
    );
  }
}

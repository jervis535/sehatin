import 'package:flutter/material.dart';
import 'package:sehatin/services/customer_service_service.dart';
import '../../models/user_model.dart';
import '../../services/doctor_service.dart';
import '../profile/profile_screen.dart';
import '../consultation/consultation_screen.dart'; // Import consultation screen

class HomeScreen extends StatefulWidget {
  final UserModel user;
  final String token;

  const HomeScreen({super.key, required this.user, required this.token});

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final path in [
        'assets/wave2.png',
        'assets/logo.png',
        'assets/maps.png',
        'assets/doctor.png',
        'assets/history.png',
        'assets/pendaftaran.png',
      ]) {
        precacheImage(AssetImage(path), context);
      }
    });
  }

  Future<void> _checkVerificationStatus() async {
    switch (widget.user.role) {
      case 'doctor':
        final doctor = await DoctorService.getByUserId(widget.user.id);
        isVerified = doctor?.verified ?? false;
        break;
      case 'customer service':
        final csEntry = await CustomerServiceService.getOneByUserId(
          widget.user.id,
        );
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
      backgroundColor: const Color(0xFF49568B),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: const Image(
              image: AssetImage('assets/wave2.png'),
              fit: BoxFit.cover,
              height: 200,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Image(
                        image: AssetImage('assets/logo.png'),
                        width: 100,
                        height: 100,
                      ),
                      SizedBox(height: 130),
                      SizedBox(width: 10),
                    ],
                  ),
                  const SizedBox(height: 50),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildIconButton(
                              "Info Lokasi Klinik",
                              'assets/maps.png',
                              () {},
                            ),
                            _buildIconButton(
                              "Konsultasi Online",
                              'assets/doctor.png',
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => ConsultationScreen(
                                          user: widget.user,
                                        ),
                                  ),
                                );
                              },
                            ),
                            _buildIconButton(
                              "Riwayat Kesehatan",
                              'assets/history.png',
                              () {},
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildIconButton(
                              "Pendaftaran Layanan Medis",
                              'assets/pendaftaran.png',
                              () {},
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => ProfileScreen(
                                          user: widget.user,
                                          token: widget.token,
                                        ),
                                  ),
                                );
                              },
                              child: Column(
                                children: const [
                                  CircleAvatar(
                                    radius: 36,
                                    backgroundColor: Color(0xFFF4F8FC),
                                    child: Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(height: 7),
                                  SizedBox(
                                    width: 80,
                                    child: Text(
                                      'Profil',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 40),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7A8CB5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "S - Sehat Bersama\n"
                      "E - Efisien & Mudah Diakses\n"
                      "H - Hubungkan dengan Dokter\n"
                      "A - Akses Informasi Faskes\n"
                      "T - Teknologi Tepat Guna\n"
                      "I - Inovasi Layanan Medis\n"
                      "N - Nyaman Dalam Genggaman",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 80,
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _bottomNavItem(Icons.home, 'HOME'),
                  _bottomNavItemImage(
                    'assets/doctor.png',
                    'KONSULTASI ONLINE',
                    40,
                  ),
                  _bottomNavItemImage('assets/history.png', 'RIWAYAT', 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(String label, String assetPath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: const Color(0xFFF4F8FC),
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Image.asset(assetPath, width: 30, height: 30),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 80,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomNavItem(IconData icon, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.black),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _bottomNavItemImage(String assetPath, String label, double size) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(assetPath, width: size, height: size),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

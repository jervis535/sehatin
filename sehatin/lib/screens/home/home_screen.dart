import 'package:flutter/material.dart';
import '/services/customer_service_service.dart';
import '/services/channel_service.dart'; // Import the channel service
import '../../models/user_model.dart';
import '../../services/doctor_service.dart';
import '../home/home_buttons.dart';
import '../profile/profile_screen.dart';
import '../../widgets/custom_bottom_nav.dart';

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
  String? dailyChatCount;

  @override
  void initState() {
    super.initState();
    _checkVerificationStatus();
    _fetchDailyChatCount();
  }

  Future<void> _checkVerificationStatus() async {
    final roleLower = widget.user.role.trim().toLowerCase();
    switch (roleLower) {
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

  // Fetch daily chat count based on the role using the existing function in channel_service.dart
  Future<void> _fetchDailyChatCount() async {
    final roleLower = widget.user.role.trim().toLowerCase();

    // Only fetch count for customer service or doctor roles
    if (roleLower == 'customer service' || roleLower == 'doctor') {
      try {
        final count = await ChannelService.getStaffChannelCounts(
          staffId: widget.user.id,
          period: 'day', // Fetch daily count
        );

        setState(() {
          // Check if there's data and map the correct key
          dailyChatCount = count.isNotEmpty && count[0].containsKey('chat_count')
              ? count[0]['chat_count'] ?? 0
              : 0;
        });
      } catch (e) {
        setState(() {
          dailyChatCount = "0";
        });
        print('Error fetching daily chat count: $e');
      }
    }
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

    final roleButtons = buildRoleBasedButtons(context, widget.user, widget.token);

    final profileButton = RoleBasedButton(
      label: 'Profil',
      iconWidget: const Icon(Icons.person, size: 50, color: Colors.grey),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProfileScreen(user: widget.user, token: widget.token),
          ),
        );
      },
    );

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
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Image(
                        image: AssetImage('assets/logo.png'),
                        width: 100,
                        height: 100,
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),

                  // Display daily chat count if applicable
                  if (dailyChatCount != null)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Daily Chat Count: $dailyChatCount',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),

                  // Tombol role-based + profil
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      alignment: WrapAlignment.center,
                      children: [...roleButtons, profileButton],
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
          CustomBottomNav(user: widget.user, token: widget.token, selectedIndex: 0)
        ],
      ),
    );
  }
}
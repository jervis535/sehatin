import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sehatin/services/user_service.dart';
import '../../models/medical_record_model.dart';

class MedicalRecordItem extends StatefulWidget {
  final MedicalRecord record;
  final bool showUser;
  final bool showDoctor; // Added

  const MedicalRecordItem({
    super.key,
    required this.record,
    this.showUser = false,
    this.showDoctor = false, // Added
  });

  @override
  State<MedicalRecordItem> createState() => _MedicalRecordItemState();
}

class _MedicalRecordItemState extends State<MedicalRecordItem> {
  String? username;
  String? doctorname; // Added
  bool isLoadingUser = false;
  bool isLoadingDoctor = false; // Added
  
  @override
  void initState() {
    super.initState();
    if (widget.showUser) {
      _loadUser();
    }
    if (widget.showDoctor) {
      _loadDoctor();
    }
  }

  Future<void> _loadUser() async {
    setState(() {
      isLoadingUser = true;
    });

    try {
      final user = await UserService.fetchUserById(widget.record.userId);
      if (user != null) {
        setState(() {
          username = user.username;
        });
      }
    } catch (e) {
      print('Failed to fetch user: $e');
    } finally {
      setState(() {
        isLoadingUser = false;
      });
    }
  }

  // New function to load doctor
  Future<void> _loadDoctor() async {
    setState(() {
      isLoadingDoctor = true;
    });

    try {
      final doctor = await UserService.fetchUserById(widget.record.doctorId);
      if (doctor != null) {
        setState(() {
          doctorname = doctor.username;
        });
      }
    } catch (e) {
      print('Failed to fetch doctor: $e');
    } finally {
      setState(() {
        isLoadingDoctor = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime createdAt = DateTime.parse(widget.record.createdtAt);
    String formattedDate = DateFormat('yyyy-MM-dd').format(createdAt);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.showUser) ...[
              Row(
                children: [
                  const Icon(Icons.person, size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  isLoadingUser
                      ? const Text(
                          'Memuat pengguna...',
                          style: TextStyle(color: Colors.grey),
                        )
                      : Text(
                          username != null
                              ? 'Pasien: $username'
                              : 'Pengguna tidak ditemukan',
                          style: const TextStyle(
                              fontSize: 14, color: Colors.grey),
                        ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // Show doctor info if showDoctor == true
            if (widget.showDoctor) ...[
              Row(
                children: [
                  const Icon(Icons.medical_services, size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  isLoadingDoctor
                      ? const Text(
                          'Memuat dokter...',
                          style: TextStyle(color: Colors.grey),
                        )
                      : Text(
                          doctorname != null
                              ? 'Dokter: $doctorname'
                              : 'Dokter tidak ditemukan',
                          style: const TextStyle(
                              fontSize: 14, color: Colors.grey),
                        ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🩺 ', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Diagnosa: ${widget.record.medicalConditions}',
                    style: const TextStyle(fontSize: 16),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💊 ', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Obat: ${widget.record.medications}',
                    style: const TextStyle(fontSize: 16),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (widget.record.notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.note_alt, size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Catatan: ${widget.record.notes}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tanggal: $formattedDate',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../services/channel_service.dart';
import '../../services/doctor_service.dart';
import '../chat/chat_screen.dart';
import 'consultation_form.dart';

class ConsultationScreen extends StatefulWidget {
  final UserModel user;
  const ConsultationScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  List<String> _specializations = [];
  String? _selectedSpec;
  String? _error;
  bool _loading = true;
  bool _locked = false;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    final existing = await ChannelService.getUserChannels(
      widget.user.id,
      type: 'consultation',
    );
    if (existing.isNotEmpty) {
      setState(() {
        _locked = true;
        _loading = false;
      });
      return;
    }

    try {
      final doctors = await DoctorService.getAllDoctors();
      setState(() {
        _specializations =
            doctors.map((d) => d.specialization).toSet().toList();
      });
    } catch (e) {
      _error = 'Failed to load specializations';
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _findAndChat() async {
    if (_selectedSpec == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final docs = await DoctorService.getBySpecialization(_selectedSpec!);

      int? chosenDoctorId;
      for (final d in docs) {
        final consults = await ChannelService.getDoctorConsultations(d.userId);
        if (consults.length < 3) {
          chosenDoctorId = d.userId;
          break;
        }
      }

      if (chosenDoctorId == null) {
        setState(() {
          _error = 'All doctors in "$_selectedSpec" are busy. Try later.';
          _loading = false;
        });
        return;
      }

      final channelId = await ChannelService.createConsultationChannel(
        widget.user.id,
        chosenDoctorId,
      );

      if (channelId != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(channelId: channelId, user: widget.user),
          ),
        );
      } else {
        setState(() => _error = 'Failed to create channel');
      }
    } catch (e) {
      setState(() => _error = 'Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_locked) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Consultation'),
          backgroundColor: const Color.fromARGB(255, 52, 43, 182),
          foregroundColor:
              Colors.white, // ini untuk teks dan ikon back jadi putih
          iconTheme: const IconThemeData(
            color: Colors.white,
          ), // untuk ikon back
        ),
        body: const Center(
          child: Text(
            'You already have an active consultation.\nPlease finish that first.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Consultation'),
        backgroundColor: const Color.fromARGB(255, 52, 43, 182),
        foregroundColor: Colors.white, // teks & ikon back putih
        iconTheme: const IconThemeData(color: Colors.white), // ikon back putih
      ),
      body: ConsultationForm(
        specializations: _specializations,
        selectedSpecialization: _selectedSpec,
        errorMessage: _error,
        onSelectSpecialization: (spec) => setState(() => _selectedSpec = spec),
        onSubmit: _findAndChat,
      ),
    );
  }
}

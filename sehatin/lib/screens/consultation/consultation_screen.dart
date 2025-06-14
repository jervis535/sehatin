import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../services/channel_service.dart';
import '../../services/doctor_service.dart';
import '../../services/user_service.dart';
import '../chat/chat_screen.dart';
import 'consultation_form.dart';

class ConsultationScreen extends StatefulWidget {
  final UserModel user;
  const ConsultationScreen({super.key, required this.user});

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  List<String> _specializations = [];
  String? _selectedSpec;
  String? _error;
  bool _loading = true;
  bool _locked = false;
  String? _lockReason;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    // First lock: no consultations left
    if ((widget.user.consultationCount ?? 0) <= 0) {
      setState(() {
        _locked = true;
        _lockReason = 'You have no consultations left.';
        _loading = false;
      });
      return;
    }

    // Second lock: already has an active consultation
    final existing = await ChannelService.getUserChannels(
      widget.user.id,
      type: 'consultation',
    );
    if (existing.isNotEmpty) {
      setState(() {
        _locked = true;
        _lockReason = 'You already have an active consultation.\nPlease finish that first.';
        _loading = false;
      });
      return;
    }

    try {
      final doctors = await DoctorService.getAllDoctors();
      setState(() {
        _specializations = doctors.map((d) => d.specialization).toSet().toList();
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
      UserService.updateConsultationCount(userId: widget.user.id ,subtract: 1);

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
          foregroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              _lockReason ?? 'Access restricted.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Consultation'),
        backgroundColor: const Color.fromARGB(255, 52, 43, 182),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Text(
            'Remaining Consultations: ${widget.user.consultationCount ?? 0}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: ConsultationForm(
              specializations: _specializations,
              selectedSpecialization: _selectedSpec,
              errorMessage: _error,
              onSelectSpecialization: (spec) => setState(() => _selectedSpec = spec),
              onSubmit: _findAndChat,
            ),
          ),
        ],
      ),
    );
  }
}

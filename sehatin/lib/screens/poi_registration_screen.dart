import 'package:flutter/material.dart';
import '../services/poi_service.dart';
import '../widgets/custom_text_field.dart';

class PoiRegistrationScreen extends StatefulWidget {
  const PoiRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<PoiRegistrationScreen> createState() => _PoiRegistrationScreenState();
}

class _PoiRegistrationScreenState extends State<PoiRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();

  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final poi = await PoiService.createPoi(
        name: _nameCtrl.text.trim(),
        category: _categoryCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        latitude: double.parse(_latCtrl.text.trim()),
        longitude: double.parse(_lngCtrl.text.trim()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('POI "${poi.name}" created (ID: ${poi.id})')),
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register a POI')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              CustomTextField(controller: _nameCtrl, label: 'Name'),
              CustomTextField(controller: _categoryCtrl, label: 'Category'),
              CustomTextField(controller: _addressCtrl, label: 'Address'),
              CustomTextField(
                controller: _latCtrl,
                label: 'Latitude',
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              CustomTextField(
                controller: _lngCtrl,
                label: 'Longitude',
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 24),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Create POI'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

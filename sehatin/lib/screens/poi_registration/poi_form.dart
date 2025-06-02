import 'package:flutter/material.dart';
import '../../services/poi_service.dart';
import '../../widgets/custom_text_field.dart';
import 'submit_button.dart';

class PoiForm extends StatefulWidget {
  const PoiForm({super.key});

  @override
  State<PoiForm> createState() => _PoiFormState();
}

class _PoiFormState extends State<PoiForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _categoryCtrl.dispose();
    _addressCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    super.dispose();
  }

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('POI "${poi.name}" created (ID: ${poi.id})')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        children: [
          CustomTextField(controller: _nameCtrl, label: 'Name'),
          const SizedBox(height: 8),
          CustomTextField(controller: _categoryCtrl, label: 'Category'),
          const SizedBox(height: 8),
          CustomTextField(controller: _addressCtrl, label: 'Address'),
          const SizedBox(height: 8),
          CustomTextField(
            controller: _latCtrl,
            label: 'Latitude',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 8),
          CustomTextField(
            controller: _lngCtrl,
            label: 'Longitude',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 16),
          if (_error != null)
            Text(_error!, style: const TextStyle(color: Colors.red)),
          SubmitButton(
            loading: _loading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

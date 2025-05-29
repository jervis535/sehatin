import 'package:flutter/material.dart';
import '../../models/poi_model.dart';
import '../../services/poi_service.dart';
import '../../widgets/custom_text_field.dart';

class PoiSearchForm extends StatefulWidget {
  final Function(List<PoiModel>) onResults;
  final Function(String) setError;
  final Function(bool) setLoading;

  const PoiSearchForm({
    super.key,
    required this.onResults,
    required this.setError,
    required this.setLoading,
  });

  @override
  State<PoiSearchForm> createState() => _PoiSearchFormState();
}

class _PoiSearchFormState extends State<PoiSearchForm> {
  final _nameCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _categoryCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    widget.setLoading(true);
    widget.setError('');

    try {
      final name = _nameCtrl.text.trim();
      final category = _categoryCtrl.text.trim();
      final lat = double.tryParse(_latCtrl.text.trim());
      final lng = double.tryParse(_lngCtrl.text.trim());

      final results = await PoiService.fetchPois(
        name: name.isNotEmpty ? name : null,
        category: category.isNotEmpty ? category : null,
        latitude: lat,
        longitude: lng,
      );
      widget.onResults(results);
    } catch (e) {
      widget.setError(e.toString());
    } finally {
      widget.setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(controller: _nameCtrl, label: 'Name'),
        const SizedBox(height: 8),
        CustomTextField(controller: _categoryCtrl, label: 'Category'),
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
        ElevatedButton(
          onPressed: _search,
          child: const Text('Search'),
        ),
      ],
    );
  }
}

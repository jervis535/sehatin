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
        // Name Field
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'POI Name',
                border: InputBorder.none,
                labelStyle: TextStyle(color: Colors.grey),
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Category Field
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: TextField(
              controller: _categoryCtrl,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: InputBorder.none,
                labelStyle: TextStyle(color: Colors.grey),
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Latitude Field
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: TextField(
              controller: _latCtrl,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Latitude',
                border: InputBorder.none,
                labelStyle: TextStyle(color: Colors.grey),
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Longitude Field
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: TextField(
              controller: _lngCtrl,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Longitude',
                border: InputBorder.none,
                labelStyle: TextStyle(color: Colors.grey),
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Search Button
        ElevatedButton.icon(
          onPressed: _search,
          icon: const Icon(Icons.search),
          label: const Text('Search POI'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 52, 43, 182),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 3,
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

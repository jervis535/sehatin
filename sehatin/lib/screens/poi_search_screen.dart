import 'package:flutter/material.dart';
import '../models/poi_model.dart';
import '../services/poi_service.dart';
import '../widgets/custom_text_field.dart';
import 'poi_registration_screen.dart';

class PoiSearchScreen extends StatefulWidget {
  const PoiSearchScreen({Key? key}) : super(key: key);

  @override
  State<PoiSearchScreen> createState() => _PoiSearchScreenState();
}

class _PoiSearchScreenState extends State<PoiSearchScreen> {
  final _nameCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();

  bool _loading = false;
  String? _error;
  List<PoiModel> _results = [];

  Future<void> _search() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final name = _nameCtrl.text.trim();
      final category = _categoryCtrl.text.trim();
      final lat = double.tryParse(_latCtrl.text.trim());
      final lng = double.tryParse(_lngCtrl.text.trim());

      final pois = await PoiService.fetchPois(
        name: name.isEmpty ? null : name,
        category: category.isEmpty ? null : category,
        latitude: lat,
        longitude: lng,
      );

      setState(() {
        _results = pois;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _categoryCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    super.dispose();
  }

  void _createPoi() async {
    Navigator.push<PoiModel?>(
      context,
      MaterialPageRoute(builder: (_) => const PoiRegistrationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search POIs')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomTextField(controller: _nameCtrl, label: 'Name'),
            const SizedBox(height: 8),
            CustomTextField(controller: _categoryCtrl, label: 'Category'),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _latCtrl,
              label: 'Latitude',
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _lngCtrl,
              label: 'Longitude',
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _search,
              child: _loading
                  ? const SizedBox(
                      width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Search'),
            ),
            TextButton.icon(
              icon: const Icon(Icons.add),
              label: Text("didnt find your poi? register one here!"),
              onPressed: _createPoi,
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _results.isEmpty
                      ? const Center(child: Text('No POIs found.'))
                      : ListView.separated(
                          itemCount: _results.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, i) {
                            final poi = _results[i];
                                                       return ListTile(
                             title: Text(poi.name),
                             subtitle: Text('${poi.category} • ${poi.address}'),
                             trailing: poi.verified == true
                                 ? const Icon(Icons.check_circle, color: Colors.green)
                                 : const Icon(Icons.hourglass_bottom),
                             onTap: () {
                               Navigator.pop(context, poi);
                             },
                           );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

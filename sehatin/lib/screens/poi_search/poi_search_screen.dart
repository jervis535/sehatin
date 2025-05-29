import 'package:flutter/material.dart';
import '../../models/poi_model.dart';
import '../poi_registration/poi_registration_screen.dart';
import 'poi_search_form.dart';
import 'poi_result_list.dart';

class PoiSearchScreen extends StatefulWidget {
  const PoiSearchScreen({Key? key}) : super(key: key);

  @override
  State<PoiSearchScreen> createState() => _PoiSearchScreenState();
}

class _PoiSearchScreenState extends State<PoiSearchScreen> {
  bool _loading = false;
  String? _error;
  List<PoiModel> _results = [];

  void _updateResults(List<PoiModel> results) {
    setState(() {
      _results = results;
    });
  }

  void _setError(String error) {
    setState(() => _error = error);
  }

  void _setLoading(bool value) {
    setState(() => _loading = value);
  }

  void _createPoi() {
    Navigator.push(
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
            PoiSearchForm(
              onResults: _updateResults,
              setLoading: _setLoading,
              setError: _setError,
            ),
            TextButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("Didn't find your POI? Register one here!"),
              onPressed: _createPoi,
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : PoiResultList(pois: _results),
            ),
          ],
        ),
      ),
    );
  }
}

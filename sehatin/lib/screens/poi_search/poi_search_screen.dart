import 'package:flutter/material.dart';
import '../../models/poi_model.dart';
import '../poi_registration/poi_registration_screen.dart';
import 'poi_search_form.dart';
import 'poi_result_list.dart';

class PoiSearchScreen extends StatefulWidget {
  const PoiSearchScreen({super.key});

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
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 52, 43, 182),
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text(
          'Search POIs',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: PoiSearchForm(
                  onResults: _updateResults,
                  setLoading: _setLoading,
                  setError: _setError,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const SizedBox(height: 10),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            Expanded(
              child:
                  _loading
                      ? const Center(child: CircularProgressIndicator())
                      : PoiResultList(pois: _results),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'poi_form.dart';

class PoiRegistrationScreen extends StatelessWidget {
  const PoiRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register a POI')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: PoiForm(),
      ),
    );
  }
}

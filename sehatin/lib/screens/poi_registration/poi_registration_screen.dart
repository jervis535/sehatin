import 'package:flutter/material.dart';
import 'poi_form.dart';

class PoiRegistrationScreen extends StatelessWidget {
  const PoiRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 52, 43, 182),
        foregroundColor: Colors.white,
        title: const Text('Register a POI'),
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: const Padding(padding: EdgeInsets.all(20), child: PoiForm()),
    );
  }
}

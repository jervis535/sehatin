import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isPassword;
  final TextInputType? keyboardType; // <-- Add this

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.label,
    this.isPassword=false,
    this.keyboardType, // <-- Add this
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType, // <-- Use it here
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
    );
  }
}

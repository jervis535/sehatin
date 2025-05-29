import 'package:flutter/material.dart';

class ErrorMessage extends StatelessWidget {
  final String message;

  const ErrorMessage({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: const TextStyle(color: Colors.red),
      textAlign: TextAlign.center,
    );
  }
}

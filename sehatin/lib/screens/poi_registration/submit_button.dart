import 'package:flutter/material.dart';

class SubmitButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onPressed;

  const SubmitButton({
    Key? key,
    required this.loading,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: loading ? null : onPressed,
      child: loading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text('Create POI'),
    );
  }
}

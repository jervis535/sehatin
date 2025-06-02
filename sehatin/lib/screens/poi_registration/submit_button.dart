import 'package:flutter/material.dart';

class SubmitButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onPressed;

  const SubmitButton({Key? key, required this.loading, required this.onPressed})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: loading ? null : onPressed,
      icon:
          loading
              ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
              : const Icon(Icons.add),
      label: Text(loading ? 'Creating...' : 'Create POI'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 52, 43, 182),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}

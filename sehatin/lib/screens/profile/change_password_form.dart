import 'package:flutter/material.dart';

class ChangePasswordForm extends StatelessWidget {
  final TextEditingController oldPassCtrl;
  final TextEditingController newPassCtrl;
  final VoidCallback? onChange;
  final bool isSaving;

  const ChangePasswordForm({
    Key? key,
    required this.oldPassCtrl,
    required this.newPassCtrl,
    required this.onChange,
    required this.isSaving,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // agar dialog sesuai isi
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ubah Kata Sandi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFFB87575),
          ),
        ),
        const SizedBox(height: 16),

        TextField(
          controller: oldPassCtrl,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Kata Sandi Lama',
            labelStyle: const TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFB87575)),
            ),
          ),
          style: const TextStyle(color: Colors.black87),
        ),

        const SizedBox(height: 16),

        TextField(
          controller: newPassCtrl,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Kata Sandi Baru',
            labelStyle: const TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFB87575)),
            ),
          ),
          style: const TextStyle(color: Colors.black87),
        ),

        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onChange,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB87575),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child:
                isSaving
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : const Text(
                      'Ubah Kata Sandi',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
          ),
        ),
      ],
    );
  }
}

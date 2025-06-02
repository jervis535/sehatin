import 'package:flutter/material.dart';

class ChangePasswordForm extends StatefulWidget {
  final TextEditingController oldPassCtrl;
  final TextEditingController newPassCtrl;
  final VoidCallback? onChange;
  final bool isSaving;

  const ChangePasswordForm({
    super.key,
    required this.oldPassCtrl,
    required this.newPassCtrl,
    required this.onChange,
    required this.isSaving,
  });

  @override
  _ChangePasswordFormState createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<ChangePasswordForm> {
  bool _obscureOld = true;
  bool _obscureNew = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
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
          controller: widget.oldPassCtrl,
          obscureText: _obscureOld,
          decoration: InputDecoration(
            labelText: 'Kata Sandi Lama',
            labelStyle: const TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFB87575)),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureOld ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _obscureOld = !_obscureOld;
                });
              },
            ),
          ),
          style: const TextStyle(color: Colors.black87),
        ),

        const SizedBox(height: 16),

        TextField(
          controller: widget.newPassCtrl,
          obscureText: _obscureNew,
          decoration: InputDecoration(
            labelText: 'Kata Sandi Baru',
            labelStyle: const TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFB87575)),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureNew ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _obscureNew = !_obscureNew;
                });
              },
            ),
          ),
          style: const TextStyle(color: Colors.black87),
        ),

        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: widget.onChange,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB87575),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child:
                widget.isSaving
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

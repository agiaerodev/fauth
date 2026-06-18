import 'package:flutter/material.dart';

class AuthInputField extends StatelessWidget {
  const AuthInputField({
    super.key,
    required this.label,
    required this.controller,
    required this.validator,
  });

  final String label;
  final TextEditingController controller;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    const Color fillColor = Color(0xFFF2F6FA);

    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.blue),
        ),
        fillColor: fillColor,
        filled: true,
      ),
    );
  }
}

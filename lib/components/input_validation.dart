import 'package:flutter/material.dart';

import '../helpers/colors_theme.dart';

class TextInputValidation extends StatelessWidget {
  const TextInputValidation({
    super.key,
    required this.label,
    required this.validate,
    required TextEditingController controller,
    this.type
  }) : _controller = controller;

  final TextEditingController _controller;
  final String label;
  final bool validate;
  final TextInputType? type;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      validator: validate
          ? (value) {
              if (value == null || value.isEmpty) {
                return '$label harus terisi !';
              }
              return null;
            }
          : null,

      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColor.secondary, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColor.light),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColor.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Colors.black54),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        errorStyle: const TextStyle(color: Colors.red, fontSize: 10),
      ),
      keyboardType: type ?? TextInputType.text,
    );
  }
}

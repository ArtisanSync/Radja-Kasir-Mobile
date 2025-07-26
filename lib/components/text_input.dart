import 'package:flutter/material.dart';
import 'package:kasir/helpers/colors_theme.dart';

class TextInput extends StatelessWidget {
  const TextInput({
    super.key,
    required this.label,
    required TextEditingController controller,
    this.onTap,
    this.type,
  }) : _controller = controller;

  final TextEditingController _controller;
  final String label;
  final Function? onTap;
  final TextInputType? type;
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onTap: () => onTap,
      decoration: InputDecoration(
        labelText: "$label",
        labelStyle: const TextStyle(color: AppColor.secondary, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Colors.black54),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColor.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
      ),
      keyboardType: type ?? TextInputType.text,
    );
  }
}

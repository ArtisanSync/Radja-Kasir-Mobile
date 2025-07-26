import 'package:flutter/material.dart';
import 'package:kasir/helpers/colors_theme.dart';

class ButtonPrimary extends StatefulWidget {
  const ButtonPrimary({required this.label, required this.onTap, super.key});

  final String label;
  final Function onTap;
  @override
  State<ButtonPrimary> createState() => _ButtonPrimaryState();
}

class _ButtonPrimaryState extends State<ButtonPrimary> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: 20,
        ),
        decoration: BoxDecoration(
          color: AppColor.primary,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: Text(
            widget.label,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
      onTap: () => widget.onTap(),
    );
  }
}

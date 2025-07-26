import 'package:flutter/material.dart';

class ButtonLight extends StatefulWidget {
  const ButtonLight({required this.label, required this.onTap, super.key});

  final String label;
  final Function onTap;
  @override
  State<ButtonLight> createState() => _ButtonLightState();
}

class _ButtonLightState extends State<ButtonLight> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: 20,
        ),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: Text(
            widget.label,
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ),
      onTap: () => widget.onTap(),
    );
  }
}

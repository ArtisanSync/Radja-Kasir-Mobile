import 'package:flutter/material.dart';
import 'package:kasir/helpers/colors_theme.dart';

class ButtonPrimary extends StatefulWidget {
  const ButtonPrimary({
    required this.label,
    required this.onTap,
    this.loading = false,
    super.key,
  });

  final String label;
  final Function? onTap;
  final bool loading;
  @override
  State<ButtonPrimary> createState() => _ButtonPrimaryState();
}

class _ButtonPrimaryState extends State<ButtonPrimary> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: widget.loading || widget.onTap == null
              ? AppColor.primary.withOpacity(0.6)
              : AppColor.primary,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: widget.loading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(widget.label, style: const TextStyle(color: Colors.white)),
        ),
      ),
      onTap: widget.loading || widget.onTap == null
          ? null
          : () => widget.onTap!(),
    );
  }
}

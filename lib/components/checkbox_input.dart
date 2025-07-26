import 'package:flutter/material.dart';

class CheckBoxInput extends StatefulWidget {
  const CheckBoxInput({
    super.key,
    this.label,
    required this.stateCallback,
  });

  final String? label;
  final Function stateCallback;
  @override
  State<CheckBoxInput> createState() => _CheckBoxInputState();
}

class _CheckBoxInputState extends State<CheckBoxInput> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.green;
      }
      return isChecked ? Colors.green : Colors.black12;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('${widget.label}'),
        Checkbox(
          checkColor: Colors.white,
          fillColor: MaterialStateProperty.resolveWith(getColor),
          value: isChecked,
          onChanged: (bool? value) {
            widget.stateCallback(value);
            setState(() {
              isChecked = value!;
            });
          },
        ),
      ],
    );
  }
}

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class InputDropDown extends StatefulWidget {
  const InputDropDown({
    required this.lists,
    required this.onSelect,
    this.val,
    this.placeholder,
    Key? key,
  }) : super(key: key);

  final List<String> lists;
  final String? val;
  final String? placeholder;
  final Function onSelect;
  @override
  State<InputDropDown> createState() => _InputDropDownState();
}

class _InputDropDownState extends State<InputDropDown> {
  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        isExpanded: true,
        hint: Row(
          children: [
            Expanded(
              child: Text(
                widget.placeholder ?? 'Pilih item',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        items: widget.lists
            .map(
              (String item) => DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              ),
            )
            .toList(),
        value: widget.val,
        onChanged: (value) => widget.onSelect(value),
        buttonStyleData: ButtonStyleData(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: Colors.black26,
            ),
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

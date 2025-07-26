import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class InputDropdownSearch extends StatefulWidget {
  const InputDropdownSearch({
    required this.items,
    this.placeholder,
    super.key,
  });

  final String? placeholder;
  final List<dynamic> items;
  @override
  State<InputDropdownSearch> createState() => _InputDropdownSearchState();
}

class _InputDropdownSearchState extends State<InputDropdownSearch> {
  String? selectedValue;
  final TextEditingController textEditingController = TextEditingController();

  List<dynamic> props = [];
  List<String> labels = [];

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<dynamic>(
        isExpanded: true,
        hint: Text(
          '${widget.placeholder ?? 'Pilih data'}',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).hintColor,
          ),
        ),
        items: widget.items.map((dynamic item) {
          return DropdownMenuItem(
            value: item['value'].toString(),
            child: Text(
              item['label'],
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          );
        }).toList(),
        value: selectedValue,
        onChanged: (value) {
          setState(() {
            selectedValue = value;
          });
        },
        buttonStyleData: const ButtonStyleData(
          padding: EdgeInsets.symmetric(horizontal: 16),
          height: 40,
          width: 200,
        ),
        dropdownStyleData: const DropdownStyleData(
          maxHeight: 200,
        ),
        menuItemStyleData: const MenuItemStyleData(
          height: 40,
        ),
        dropdownSearchData: DropdownSearchData(
          searchController: textEditingController,
          searchInnerWidgetHeight: 50,
          searchInnerWidget: Container(
            height: 50,
            padding: const EdgeInsets.only(
              top: 8,
              bottom: 4,
              right: 8,
              left: 8,
            ),
            child: TextFormField(
              expands: true,
              maxLines: null,
              controller: textEditingController,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                hintText: 'Search for an ${widget.placeholder ?? 'item'}...',
                hintStyle: const TextStyle(fontSize: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          // searchMatchFn: (item, searchValue) {
          //   // return item.value['label'].toString().contains(searchValue);
          // },
        ),
        onMenuStateChange: (isOpen) {
          if (!isOpen) {
            textEditingController.clear();
          }
        },
      ),
    );
  }
}

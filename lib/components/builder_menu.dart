import 'package:flutter/material.dart';

class MenuBuilder extends StatelessWidget {
  const MenuBuilder({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext context) {
        return IconButton(
          icon: const Icon(
            Icons.sort,
            color: Colors.black87,
          ),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
          tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
        );
      },
    );
  }
}

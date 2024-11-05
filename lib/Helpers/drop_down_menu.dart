import 'package:flutter/material.dart';

class Dropdown extends StatelessWidget {
  const Dropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert), // The icon displayed for the button
      onSelected: (String value) {
        // Action when an option is selected
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selected: $value')),
        );
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'Option 1',
          child: Text('Option 1'),
        ),
        const PopupMenuItem<String>(
          value: 'Option 2',
          child: Text('Option 2'),
        ),
        const PopupMenuItem<String>(
          value: 'Option 3',
          child: Text('Option 3'),
        ),
      ],
    );
  }
}
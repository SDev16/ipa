import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final bool obscureText;
  final Icon icon;
  final String? Function(String?)? validator;

  const MyTextField({super.key, 
    required this.hintText,
    required this.controller,
    required this.obscureText,
    required this.icon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: icon,
        border: InputBorder.none,
      ),
      validator: validator,
    );
  }
}

// ignore_for_file: must_be_immutable
import 'package:faap/Helpers/my_text.dart';
import 'package:faap/models/const.dart';
import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final Function() ? onTap;
  final String text;

 const MyButton({super.key, required this.onTap, required this.text,});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(25),
        margin: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
          color:primaryColor,
          borderRadius: BorderRadius.circular(10)
        ),
        child: Center(
          child: Text(text, style: AppText.whiteFieldStyle(),),
        ),
      ),
    );
  }
}
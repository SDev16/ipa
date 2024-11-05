import 'package:flutter/material.dart';

class AppText{
  static TextStyle textFieldStyle(){
    return TextStyle(

      fontSize: 16,
      color: Colors.grey[600]
    );

  }
    static TextStyle whiteFieldStyle(){
    return const TextStyle(

      fontSize: 16,
      color: Colors.white
    );

  }

      static TextStyle normalFieldStyle(){
    return TextStyle(

      fontSize: 15,
      color:Colors.grey[700]
    );
      }
}
// to check wether the current user is logged in or not

import 'package:double_back_to_close/double_back_to_close.dart';
import 'package:faap/Auth/auth_screens.dart';
import 'package:faap/Helpers/bottom_nav_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: ( context,  snapshot) {
        // user logged in
        if(snapshot.hasData){
          return const DoubleBack(child: BottomNavBar());
        }
        // not logged in 
        else{
          return const AuthPage();
        }
      },
    );
  }
}
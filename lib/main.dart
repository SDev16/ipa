import 'package:faap/Helpers/cart_provider.dart';
import 'package:faap/Helpers/favorite_provider.dart';
import 'package:faap/Services/auth_gate.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:firebase_core/firebase_core.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Cart()), // Add your Cart provider 
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuickBite',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AuthGate(),
    );
  }
}


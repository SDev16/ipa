import 'package:animate_do/animate_do.dart';
import 'package:faap/Auth/reset_password.dart';
import 'package:faap/Helpers/my_button.dart';
import 'package:faap/Helpers/my_text_field.dart';
import 'package:faap/Helpers/square_tile.dart';
import 'package:faap/Services/auth_gate.dart';
import 'package:faap/Services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) {
      return; // Prevent login if the form is invalid
    }

    setState(() {
      _isLoading = true;
    });

    final authService = AuthService();
    try {
      UserCredential userCredential = await authService.signInWithEmailPassword(
        emailController.text,
        passwordController.text,
      );

      User? user = userCredential.user;

      if (user != null && user.email == 'admin@gmail.com') {
        if (mounted) {
          // Check if the widget is still mounted
        }
      } else {
        if (mounted) {
          // Check if the widget is still mounted
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AuthGate()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        // Check if the widget is still mounted
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: const Text('Login Failed'),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        // Check if the widget is still mounted
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email.';
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password.';
    } else if (value.length < 6) {
      return 'Password must be at least 6 characters long.';
    }
    return null;
  }

  void _showResetPasswordDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const ResetPasswordDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    FadeInUp(
                      duration: const Duration(milliseconds: 1500),
                      child: const Center(
                        child: Text(
                          "Welcome Back! You Have Been Missed!",
                          style: TextStyle(
                            color: Color.fromRGBO(49, 39, 79, 1),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    FadeInUp(
                      duration: const Duration(milliseconds: 1700),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          border: Border.all(
                            color: const Color.fromRGBO(196, 135, 198, .3),
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromRGBO(196, 135, 198, .3),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: <Widget>[
                            MyTextField(
                              hintText: 'Email',
                              controller: emailController,
                              obscureText: false,
                              icon: const Icon(Icons.email),
                              validator: _validateEmail,
                            ),
                            MyTextField(
                              hintText: 'Password',
                              controller: passwordController,
                              obscureText: true,
                              icon: const Icon(Icons.lock),
                              validator: _validatePassword,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FadeInUp(
                      duration: const Duration(milliseconds: 1900),
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : MyButton(
                              onTap: login,
                              text: 'Log In',
                            ),
                    ),
                    const SizedBox(height: 20),
                    FadeInUp(
                      duration: const Duration(milliseconds: 1700),
                      child: Center(
                        child: TextButton(
                          onPressed: _showResetPasswordDialog,
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: Color.fromRGBO(196, 135, 198, 1),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FadeInUp(
                      duration: const Duration(milliseconds: 1900),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SquareTile(
                              onTap: () async {
                                try {
                                  await AuthService().signInWithGoogle();
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const AuthGate(),
                                    ),
                                  );
                                } catch (e) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      content: Text(e.toString()),
                                    ),
                                  );
                                }
                              },
                              imagePath: 'assets/google.png',
                            ),
                            const SizedBox(width: 15),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    FadeInUp(
                      duration: const Duration(milliseconds: 2100),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            TextButton(
                              onPressed: () {
                                // Handle navigation to sign-up page if needed
                              },
                              child: const Text(
                                "",
                                style: TextStyle(
                                  color: Color.fromRGBO(196, 135, 29, 1),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faap/Helpers/my_button.dart';
import 'package:faap/Helpers/my_text_field.dart';
import 'package:faap/Helpers/square_tile.dart';
import 'package:faap/Services/auth_gate.dart';
import 'package:faap/Services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {

  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmpasswordController =
      TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController locationController =
      TextEditingController(); // New Location Controller

  String? emailError;
  String? passwordError;
  String? confirmPasswordError;
  String? firstNameError;
  String? locationError; // New Location Error
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmpasswordController.dispose();
    firstNameController.dispose();
    locationController.dispose(); // Dispose of Location Controller
    super.dispose();
  }

  bool isValidEmail(String email) {
    final RegExp emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  void register() async {
    setState(() {
      emailError = null;
      passwordError = null;
      confirmPasswordError = null;
      firstNameError = null;
      locationError = null; // Reset Location Error
      isLoading = true;
    });

    bool isValid = true;

    if (firstNameController.text.trim().isEmpty) {
      setState(() => firstNameError = "Name is required.");
      isValid = false;
    }

    if (locationController.text.trim().isEmpty) {
      // Validate Location
      setState(() => locationError = "Location is required.");
      isValid = false;
    }

    if (!isValidEmail(emailController.text.trim())) {
      setState(() => emailError = "Invalid email format");
      isValid = false;
    }

    const restrictedEmail = 'admin@gmail.com';
    if (emailController.text.trim().toLowerCase() == restrictedEmail) {
      setState(() => emailError = "This email address is not allowed.");
      isValid = false;
    }

    final password = passwordController.text;
    if (password.isEmpty) {
      setState(() => passwordError = "Password is required.");
      isValid = false;
    } else {
      final passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+$');
      if (!passwordRegex.hasMatch(password)) {
        setState(() => passwordError =
            "Password must contain at least one uppercase letter, one lowercase letter, and one number.");
        isValid = false;
      }
    }

    if (password != confirmpasswordController.text) {
      setState(() => confirmPasswordError = "Passwords don't match.");
      isValid = false;
    }

    if (!isValid) {
      setState(() => isLoading = false);
      return;
    }

    final authService = AuthService();
    try {
      await authService.signUpWithEmailPassword(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      await addUserDetails(
        firstNameController.text.trim(),
        emailController.text.trim(),
        locationController.text.trim(), // Save Location
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account created successfully!")),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AuthGate()),
        );
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text(e.toString()),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future addUserDetails(String name, String email, String location) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': name,
        'email': email,
        'location': location, // Add Location to Firestore
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(
                    height: 50,
                  ),
                  FadeInUp(
                    duration: const Duration(milliseconds: 1500),
                    child: const Center(
                      child: Text(
                        "Let's Create An Account For you",
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
                            color: const Color.fromRGBO(196, 135, 198, .3)),
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
                            hintText: 'Name',
                            controller: firstNameController,
                            obscureText: false,
                            icon: const Icon(Icons.people),
                          ),
                          if (firstNameError != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 15, top: 5),
                              child: Text(firstNameError!,
                                  style: const TextStyle(color: Colors.red)),
                            ),
                          MyTextField(
                            hintText: 'Email',
                            controller: emailController,
                            obscureText: false,
                            icon: const Icon(Icons.email),
                          ),
                          if (emailError != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 15, top: 5),
                              child: Text(emailError!,
                                  style: const TextStyle(color: Colors.red)),
                            ),
                          MyTextField(
                            hintText: 'Location', // New Location Field
                            controller: locationController,
                            obscureText: false,
                            icon: const Icon(Icons.location_on),
                          ),
                          if (locationError != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 15, top: 5),
                              child: Text(locationError!,
                                  style: const TextStyle(color: Colors.red)),
                            ),
                          MyTextField(
                            hintText: 'Password',
                            controller: passwordController,
                            obscureText: true,
                            icon: const Icon(Icons.lock),
                          ),
                          if (passwordError != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 15, top: 5),
                              child: Text(passwordError!,
                                  style: const TextStyle(color: Colors.red)),
                            ),
                          MyTextField(
                            hintText: 'Confirm Password',
                            controller: confirmpasswordController,
                            obscureText: true,
                            icon: const Icon(Icons.lock),
                          ),
                          if (confirmPasswordError != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 15, top: 5),
                              child: Text(confirmPasswordError!,
                                  style: const TextStyle(color: Colors.red)),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  FadeInUp(
                    duration: const Duration(milliseconds: 1900),
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : MyButton(onTap: register, text: 'Sign Up'),
                  ),
                  const SizedBox(height: 26),
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
                                      builder: (context) => const AuthGate()),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

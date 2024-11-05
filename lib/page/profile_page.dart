import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faap/Services/auth_gate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:faap/Helpers/my_button.dart';
import 'package:faap/Helpers/my_text_field.dart';
import 'package:faap/Services/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userData.exists) {
        setState(() {
          nameController.text = userData['name'];
          emailController.text = userData['email'];
          locationController.text = userData['location'] ?? '';
        });

        if (await AuthService().isGoogleUser() && locationController.text.isEmpty) {
          promptForLocation();
        }
      }
    }
  }

  Future<void> promptForLocation() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add Location"),
          content: TextField(
            controller: locationController,
            decoration: const InputDecoration(hintText: "Enter your location"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                if (locationController.text.isNotEmpty) {
                  await updateUserDetails(); // Save location in Firestore
                  Navigator.of(context).pop(); // Close the dialog
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Location cannot be empty."),
                    ),
                  );
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateUserDetails() async {
    setState(() => isLoading = true);
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'location': locationController.text.trim(),
      });

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!")),
      );
    }
  }

  Future<void> deleteUserAccount() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Account"),
          content: const Text(
            "Are you sure you want to delete your account? This action cannot be undone.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                User? user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  try {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .delete();

                    await user.delete();

                    // Check if the widget is still mounted before showing the Snackbar
                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Account deleted successfully."),
                      ),
                    );

                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const AuthGate()),
                    );
                  } catch (e) {
                    // Check if the widget is still mounted before showing the error dialog
                    if (!mounted) return;

                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Error"),
                        content: Text(e.toString()),
                      ),
                    );
                  }
                }
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Navigate to AuthGate or login page after logout
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AuthGate()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Logout failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: deleteUserAccount,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            MyTextField(
              hintText: 'Name',
              controller: nameController,
              obscureText: false,
              icon: const Icon(Icons.person),
            ),
            const SizedBox(height: 15),
            MyTextField(
              hintText: 'Email',
              controller: emailController,
              obscureText: false,
              icon: const Icon(Icons.email),
            ),
            const SizedBox(height: 15),
            MyTextField(
              hintText: 'Location',
              controller: locationController,
              obscureText: false,
              icon: const Icon(Icons.location_on),
            ),
            const SizedBox(height: 30),
            isLoading
                ? const CircularProgressIndicator()
                : MyButton(
                    onTap: updateUserDetails,
                    text: 'Update Profile',
                  ),
            const SizedBox(height: 20), // Add some space
            MyButton(
              
              onTap: logout,
              text: 'Logout', // Logout button
            ),
          ],
        ),
      ),
    );
  }
}

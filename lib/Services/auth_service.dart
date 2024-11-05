import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailPassword(String email, String password) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign up with email and password
  Future<UserCredential> signUpWithEmailPassword(String email, String password) async {
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await signOutGoogle(); // sign out from Google as well
  }

  // Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign-in canceled');
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      // Check if the user is new and save their information
      if (userCredential.additionalUserInfo?.isNewUser == true) {
        await _saveUserData(userCredential.user);
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Check if logged in user used Google Sign-In
  Future<bool> isGoogleUser() async {
    User? user = _firebaseAuth.currentUser;
    return user?.providerData.any((info) => info.providerId == 'google.com') ?? false;
  }

  // Save user data to Firestore
  Future<void> _saveUserData(User? user) async {
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'name': user.displayName ?? 'No Name',
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Sign out from Google
  Future<void> signOutGoogle() async {
    await _googleSignIn.signOut();
  }

  // Handle authentication exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided for that user.';
      case 'weak-password':
        return 'The password provided is too weak. Please use a stronger password.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'email-already-in-use':
        return 'The email address is already in use by another account.';
      case 'operation-not-allowed':
        return 'This operation is not allowed. Please contact support.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}

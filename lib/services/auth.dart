import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

// Sign in function
Future<User?> signInWithGoogle() async {
  try {
    print('Attempting to sign in with Google...');

    final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
    if (googleSignInAccount == null) {
      // Sign in cancelled
      print('Google sign-in was cancelled.');
      return null;
    }

    print('Google sign-in successful.');

    final GoogleSignInAuthentication googleAuth = await googleSignInAccount.authentication;
    print('Google authentication successful.');

    final AuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
      accessToken: googleAuth.accessToken,
    );

    print('Firebase credential created.');

    final UserCredential userCredential = await _auth.signInWithCredential(credential);
    final User? user = userCredential.user;

    assert(!user!.isAnonymous);
    assert(await user?.getIdToken() != null);

    final User? currentUser = _auth.currentUser;
    assert(currentUser?.uid == user?.uid);

    print('Firebase sign-in successful.');
    return user;
  } catch (e) {
    print('Error signing in with Google: $e');
    return null;
  }
}

// Sign out function
Future<void> signOut() async {
  try {
    print('Attempting to sign out...');

    await googleSignIn.signOut();
    await _auth.signOut();

    print('User signed out.');
  } catch (e) {
    print('Error signing out: $e');
  }
}

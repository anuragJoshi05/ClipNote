import 'package:clipnote/home.dart';
import 'package:clipnote/services/firestore_db.dart';
import 'package:clipnote/services/loginInfo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:clipnote/services/auth.dart';
import 'package:flutter/services.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // For FontAwesome icons
import 'package:url_launcher/url_launcher.dart'; // For launching URLs

class Login extends StatefulWidget {
  final bool autoSignIn; // Add this parameter

  const Login({Key? key, this.autoSignIn = false}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw 'Could not launch $url';
    }
  }
  Future<void> _signInWithGoogle() async {
    await signInWithGoogle();
    final User? currentUser = await _auth.currentUser;
    LocalDataSaver.saveLoginData(true);
    LocalDataSaver.saveImg(currentUser!.photoURL.toString());
    LocalDataSaver.saveMail(currentUser.email.toString());
    LocalDataSaver.saveName(currentUser.displayName.toString());
    LocalDataSaver.saveSyncSet(false);
    await FireDB().getAllStoredNotesForUser(currentUser.email.toString());
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Home()),
    );
  }
  @override
  void initState() {
    super.initState();
    if (widget.autoSignIn) {
      _signInWithGoogle();
      // Disable Android's back button
      SystemChannels.platform.invokeMethod<void>('SystemNavigator.pop', true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Handle back button press on Android
        // Exit the app
        SystemNavigator.pop();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black87,
        appBar: AppBar(
          automaticallyImplyLeading: false, // Hide back button on AppBar
          title: const Row(
            children: [
              Icon(Icons.lock_open, color: Colors.white),
              SizedBox(width: 10),
              Text(
                "Login to ClipNote",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.black87,
          elevation: 0,
        ),
        body: Column(
          children: [
            const SizedBox(
                height: 50), // Add spacing between the AppBar and content
            const Text(
              'Welcome to ClipNote',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SignInButton(
              Buttons.google,
              text: "Sign in with Google",
              onPressed: () async {
                await signInWithGoogle();
                final User? currentUser = await _auth.currentUser;
                LocalDataSaver.saveLoginData(true);
                LocalDataSaver.saveImg(currentUser!.photoURL.toString());
                LocalDataSaver.saveMail(currentUser.email.toString());
                LocalDataSaver.saveName(currentUser.displayName.toString());
                LocalDataSaver.saveSyncSet(false);
                await FireDB()
                    .getAllStoredNotesForUser(currentUser.email.toString());
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const Home()));
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 5,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              clipBehavior: Clip.antiAlias,
            ),
            const SizedBox(height: 20),
            const Spacer(), // Pushes the following Row to the bottom
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Created by Anurag Joshi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: () => _launchURL('https://github.com/anuragJoshi05'),
                    child: const Icon(
                      FontAwesomeIcons.github,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

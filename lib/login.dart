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
  final bool autoSignIn;

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
        body: Stack(
          children: [
            // Background image
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("images/appBackground.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              color: Colors.black.withOpacity(0.6), // Dark overlay
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 100),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.note_alt_outlined,
                        color: Colors.green,
                        size: 40,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'ClipNote',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              blurRadius: 10.0,
                              color: Colors.black45,
                              offset: Offset(2.0, 2.0),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                  SignInButton(
                    Buttons.google,
                    text: "Sign in with Google",
                    onPressed: () async {
                      await signInWithGoogle();
                      final User? currentUser = await _auth.currentUser;
                      LocalDataSaver.saveLoginData(true);
                      LocalDataSaver.saveImg(currentUser!.photoURL.toString());
                      LocalDataSaver.saveMail(currentUser.email.toString());
                      LocalDataSaver.saveName(
                          currentUser.displayName.toString());
                      LocalDataSaver.saveSyncSet(false);
                      await FireDB().getAllStoredNotesForUser(
                          currentUser.email.toString());
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Home()));
                    },
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Colors.black, width: 1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 5,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    clipBehavior: Clip.antiAlias,
                  ),
                  const SizedBox(height: 100),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Created by Anurag Joshi',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            shadows: [
                              Shadow(
                                blurRadius: 5.0,
                                color: Colors.black45,
                                offset: Offset(1.0, 1.0),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () =>
                              _launchURL('https://github.com/anuragJoshi05'),
                          child: const Icon(
                            FontAwesomeIcons.github,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ],
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

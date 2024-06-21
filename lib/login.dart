import 'package:clipnote/home.dart';
import 'package:flutter/material.dart';
import 'package:clipnote/services/auth.dart';
import 'package:sign_in_button/sign_in_button.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _loginState();
}

class _loginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login to app"),
        backgroundColor: Colors.tealAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SignInButton(Buttons.google, onPressed: () async {
              //calling signInWithGoogle() that we have made in auth.dart
              //calling this will sign us both in google + firebase
              await signInWithGoogle();

              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => Home()));
            }),
          ],
        ),
      ),
    );
  }
}

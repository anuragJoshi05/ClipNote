import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'home.dart';
import 'login.dart';
import 'services/loginInfo.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensures Flutter is initialized before Firebase

  // Initializing the Firebase app with FirebaseOptions
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyC-nyNMs-iCwqpet-1GaEjbgXBNjBumMcw',
      appId: '1:588557204787:android:da2b5fc3f0aeb8e3741246',
      messagingSenderId: '588557204787',
      projectId: 'clipnote-906d4',
      storageBucket: 'clipnote-906d4.appspot.com',
    ),
  );

  runApp(MyApp()); // Runs the Flutter application
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLogIn = false;

  // Function to get logged-in state
  getLoggedInState() async {
    bool? loggedInState = await LocalDataSaver.getLogData();
    await LocalDataSaver.getLogData().then((value) {
      setState(() {
        isLogIn = value.toString() == "null";
      });
    });
    setState(() {
      isLogIn = loggedInState ?? false; // Default to false if the value is null
    });
  }

  @override
  void initState() {
    super.initState();
    getLoggedInState(); // Check login state when the app starts
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: isLogIn ? Home() : Login(), // Show Home if logged in, else Login
    );
  }
}

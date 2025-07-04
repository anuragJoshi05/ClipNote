import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'views/home.dart';
import 'views/login.dart';
import 'package:clipnote/services/loginInfo.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔐 Load .env
  await dotenv.load(fileName: ".env");

  // 🚀 Initialize Firebase
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyC-nyNMs-iCwqpet-1GaEjbgXBNjBumMcw',
      appId: '1:588557204787:android:da2b5fc3f0aeb8e3741246',
      messagingSenderId: '588557204787',
      projectId: 'clipnote-906d4',
      storageBucket: 'clipnote-906d4.appspot.com',
    ),
  );

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLogIn = false;

  getLoggedInState() async {
    bool? loggedInState = await LocalDataSaver.getLogData();
    setState(() {
      isLogIn = loggedInState ?? false;
    });
  }

  @override
  void initState() {
    super.initState();
    getLoggedInState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ClipNote',
      theme: ThemeData(
        textTheme: TextTheme(
          bodyMedium: TextStyle(
            fontSize: 16,
            fontFamilyFallback: [
              'Noto Color Emoji',
              'Apple Color Emoji',
              'Segoe UI Emoji',
            ],
          ),
        ),
      ),
      routes: {
        '/home': (context) => const Home(),
      },

      // 🏁 Initial screen
      home: isLogIn ? const Home() : const Login(),
    );
  }
}

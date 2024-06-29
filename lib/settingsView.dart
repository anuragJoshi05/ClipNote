import 'package:clipnote/colors.dart';
import 'package:flutter/material.dart';

class Settingsview extends StatefulWidget {
  const Settingsview({super.key});

  @override
  State<Settingsview> createState() => _SettingsviewState();
}

class _SettingsviewState extends State<Settingsview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        iconTheme: IconThemeData(color: white),
        backgroundColor: bgColor,
        elevation: 0.00,
        title: Text(
          "Settings",
          style: TextStyle(color: white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Other settings options if any
          ],
        ),
      ),
    );
  }
}

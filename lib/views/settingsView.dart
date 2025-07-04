import 'package:clipnote/views/colors.dart';
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
        iconTheme: const IconThemeData(color: white),
        backgroundColor: bgColor,
        elevation: 0.00,
        title: const Text(
          "Settings",
          style: TextStyle(color: white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: const Column(
          children: [
            // Other settings options if any
          ],
        ),
      ),
    );
  }
}

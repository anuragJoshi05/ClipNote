import 'package:clipnote/colors.dart';
import 'package:clipnote/services/loginInfo.dart';
import 'package:flutter/material.dart';

class Settingsview extends StatefulWidget {
  const Settingsview({super.key});

  @override
  State<Settingsview> createState() => _SettingsviewState();
}

class _SettingsviewState extends State<Settingsview> {
  bool value = false;

  Future<void> getSyncSet() async {
    bool? valueFromDb = await LocalDataSaver.getSyncSet();
    setState(() {
      value = valueFromDb ?? false;
    });
  }

  @override
  void initState() {
    super.initState();
    getSyncSet();
  }

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
            Row(
              children: [
                const Text(
                  "Sync",
                  style: TextStyle(
                    color: white,
                    fontSize: 18,
                  ),
                ),
                Spacer(),
                Switch.adaptive(
                    value: value,
                    onChanged: (switchValue) {
                      setState(() {
                        value = switchValue;
                        LocalDataSaver.saveSyncSet(switchValue);
                      });
                    }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

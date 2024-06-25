import 'package:clipnote/archieveView.dart';
import 'package:clipnote/colors.dart';
import 'package:clipnote/settingsView.dart';
import 'package:flutter/material.dart';

import 'home.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({super.key});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                child: Text(
                  "ClipNote",
                  style: TextStyle(
                      color: white, fontWeight: FontWeight.bold, fontSize: 25),
                ),
              ),
              Divider(
                color: white.withOpacity(0.3),
              ),
              Container(
                margin: EdgeInsets.only(right: 10),
                child: Column(
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
                      },
                      child: sectionOne(),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ArchieveView()));
                      },
                      child: sectionTwo(),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Settingsview()));
                      },
                      child: sectionThree(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget sectionOne() {
    return Container(
      padding: EdgeInsets.all(5),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outlined,
            size: 25,
            color: white.withOpacity(0.7),
          ),
          SizedBox(
            width: 10,
          ),
          Text(
            "Notes",
            style: TextStyle(color: white.withOpacity(0.7), fontSize: 18),
          ),
        ],
      ),
      decoration: BoxDecoration(
        color: Colors.orangeAccent.withOpacity(0.3),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
    );
  }

  Widget sectionTwo() {
    return Container(
      padding: EdgeInsets.all(5),
      child: Row(
        children: [
          Icon(
            Icons.archive_outlined,
            size: 25,
            color: white.withOpacity(0.7),
          ),
          SizedBox(
            width: 10,
          ),
          Text(
            "Archive",
            style: TextStyle(color: white.withOpacity(0.7), fontSize: 18),
          ),
        ],
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
    );
  }

  Widget sectionThree() {
    return Container(
      padding: EdgeInsets.all(5),
      child: Row(
        children: [
          Icon(
            Icons.settings_outlined,
            size: 25,
            color: white.withOpacity(0.7),
          ),
          SizedBox(
            width: 10,
          ),
          Text(
            "Settings",
            style: TextStyle(color: white.withOpacity(0.7), fontSize: 18),
          ),
        ],
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
    );
  }
}

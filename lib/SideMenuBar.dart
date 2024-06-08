import 'package:clipnote/colors.dart';
import 'package:flutter/material.dart';

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
                child: Text("ClipNote", style: TextStyle(color: white, fontWeight: FontWeight.bold, fontSize: 25),),
              ),
              Divider(
                color: white.withOpacity(0.3),
              )
            ],
          ),
        ),
      ),
    );
  }
}

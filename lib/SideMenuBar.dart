import 'package:flutter/material.dart';
import 'package:clipnote/archieveView.dart';
import 'package:clipnote/settingsView.dart';
import 'package:clipnote/home.dart';
import 'package:clipnote/colors.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: bgColor,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: const Row(
                  children: [
                    Icon(
                      Icons.note_alt_outlined,
                      color: white,
                      size: 30,
                    ),
                    SizedBox(width: 10),
                    Text(
                      "ClipNote",
                      style: TextStyle(
                        color: white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                color: white.withOpacity(0.3),
              ),
              Expanded(
                child: ListView(
                  children: [
                    _buildMenuItem(
                      context,
                      icon: Icons.lightbulb_outline,
                      label: "Notes",
                      destination: const Home(),
                      selected: true,
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.star_border,
                      label: "Starred",
                      destination: ArchieveView(),
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.settings_outlined,
                      label: "Settings",
                      destination: const Settingsview(),
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

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Widget destination,
    bool selected = false,
  }) {
    final color =
        selected ? Colors.orangeAccent.withOpacity(0.7) : Colors.transparent;

    return InkWell(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => destination));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 25,
              color: white.withOpacity(0.9),
            ),
            const SizedBox(width: 20),
            Text(
              label,
              style: TextStyle(
                color: white.withOpacity(0.9),
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

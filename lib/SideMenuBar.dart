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
                      color: Colors.green,
                      size: 30,
                    ),
                    SizedBox(width: 10),
                    Text(
                      "ClipNote",
                      style: TextStyle(
                        color: Colors.grey,
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
                      destination: const ArchieveView(),
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
    final textColor = selected ? Colors.black87 : white.withOpacity(0.9);
    final iconColor = selected ? Colors.black87 : white.withOpacity(0.9);

    return InkWell(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => destination));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 25,
              color: iconColor,
            ),
            const SizedBox(width: 20),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

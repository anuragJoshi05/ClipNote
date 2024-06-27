import 'package:flutter/material.dart';
import 'package:clipnote/archieveView.dart';
import 'package:clipnote/settingsView.dart';
import 'package:clipnote/home.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.black,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: const Row(
                  children: [
                    Icon(
                      Icons.note_alt_outlined,
                      color: Colors.white,
                      size: 30,
                    ),
                    SizedBox(width: 10),
                    Text(
                      "ClipNote",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: ListView(
                  children: [
                    _buildMenuItem(
                      context,
                      icon: Icons.lightbulb_outline,
                      label: "Notes",
                      destination: const Home(),
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.archive_outlined,
                      label: "Archive",
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

  Widget _buildMenuItem(BuildContext context, {
    required IconData icon,
    required String label,
    required Widget destination,
  }) {
    final notesColor = Colors.amber; // Use named color for better readability

    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => destination));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          color: label == "Notes" ? notesColor : Colors.grey.shade900,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 25,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(width: 20),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

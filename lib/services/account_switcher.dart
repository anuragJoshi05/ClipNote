import 'package:clipnote/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:clipnote/login.dart';
import 'package:clipnote/services/auth.dart';

class AccountSwitcher extends StatefulWidget {
  final List<GoogleSignInAccount> accounts;

  const AccountSwitcher({super.key, required this.accounts});

  @override
  _AccountSwitcherState createState() => _AccountSwitcherState();
}

class _AccountSwitcherState extends State<AccountSwitcher> {
  List<GoogleSignInAccount> _accounts = [];

  @override
  void initState() {
    super.initState();
    _accounts = widget.accounts;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ..._accounts.map((account) {
            return Card(
              color: Colors.grey.shade900,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                      NetworkImage(account.photoUrl ?? 'images/googleLogo.png'),
                ),
                title: Text(
                  account.displayName ?? '',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  account.email,
                  style: TextStyle(color: Colors.white70),
                ),
                onTap: () {
                  // Switch account logic (if any)
                },
              ),
            );
          }).toList(),

          Card(
            color: Colors.grey.shade900,
            child: ListTile(
              leading: const Icon(Icons.manage_accounts, color: Colors.white),
              title:
                  const Text("Sign out", style: TextStyle(color: Colors.white)),
              onTap: () async {
                await signOut(); // Call signOut method from AuthService
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        Login(), // Navigate to login screen after signing out
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

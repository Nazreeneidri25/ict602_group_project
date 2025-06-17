import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Application"),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
                accountName: Text("Admin"),
                accountEmail: Text("Admin@admin.com")
            ),
            ListTile(
              title: Text("Profile"),
              onTap: () => {},
            ),
            ListTile(
              title: Text("About "),
              onTap: () => {},
            ),
            ListTile(
              title: Text("Settings"),
              onTap: () => {},
            )
          ],
        ),
      ),
      body: SignOutButton(),
    );
  }
}

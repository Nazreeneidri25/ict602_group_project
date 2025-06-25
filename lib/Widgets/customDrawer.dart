import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

class CustomDrawer extends StatelessWidget {
  final Map<String, dynamic>? userInformation;
  final FirebaseAuth auth;

  const CustomDrawer({super.key , required this.userInformation , required this.auth});

  void onNavigate (context , routePath){

    if(routePath != ModalRoute.of(context)?.settings.name) {
      Navigator.popAndPushNamed(context, routePath);
    }else{
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return  Drawer(
      backgroundColor: Colors.white.withOpacity(0.95),
      child: Column(
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blueAccent.withOpacity(0.7),
                  Colors.lightBlueAccent.withOpacity(0.5)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Row(
                children: [
                  SizedBox(width: 24),
                  GestureDetector(
                    onTap: () =>onNavigate(context , "/profile"),
                    child: CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.white,
                      child: Image.asset(
                        "lib/Assets/Icons/user.png",
                        height: 48,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(userInformation?["username"] ?? '',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            )),
                        SizedBox(height: 4),
                        SizedBox(
                          width: 120,
                          child: Text(
                            userInformation?["email"] ?? '',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                            ),
                            overflow: TextOverflow.ellipsis,
                            // or .fade, .clip
                            maxLines: 1,
                            softWrap: false,
                          ),
                        ),
                      ]),
                ],
              ),
            ),
          ),
          SizedBox(height: 8),
          ListTile(
            leading: Icon(Icons.home_rounded, color: Colors.blueAccent),
            title: Text(
                "Home", style: TextStyle(fontWeight: FontWeight.w500)),
            onTap: () => onNavigate(context , "/home"),
          ),
          ListTile(
            leading: Icon(Icons.add_location , color: Colors.blueAccent),
            title: Text(
                "Add Place",
                style: TextStyle(fontWeight:  FontWeight.w500)),
            onTap: () => onNavigate(context, "/addMarker"),
          ),
          ListTile(
            leading: Icon(
                Icons.info_outline_rounded, color: Colors.blueAccent),
            title: Text(
                "About", style: TextStyle(fontWeight: FontWeight.w500)),
            onTap: () => {},
          ),
          ListTile(
            leading: Icon(
                Icons.settings_rounded, color: Colors.blueAccent),
            title: Text("Settings",
                style: TextStyle(fontWeight: FontWeight.w500)),
            onTap: () => {},
          ),
          Divider(thickness: 1, color: Colors.grey[200], height: 32),
          Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16.0, vertical: 12),
            child: Row(
              children: [
                Expanded(child: Container()),
                TextButton.icon(
                    icon: Icon(
                        Icons.logout
                    ),
                    label: Text("Sign Out"),
                    onPressed: () async {
                      await FirebaseUIAuth.signOut(
                          context: context,
                          auth: auth
                      );
                      Navigator.pushReplacementNamed(context, "/auth");
                    }
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

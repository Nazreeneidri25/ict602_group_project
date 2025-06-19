import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ict602_group_project/Widgets/map.dart';
import 'dart:ui';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  Widget _screen = MapCustom();

  final List<Widget> screens = [
    MapCustom(), //default
    Center(child: Text("Profile")),
    Center(child: Text("About")),
    Center(child: Text("Settings")),
  ];

  void _onItemTapped(int index) {
    setState(() => _screen = screens[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
// ... inside your HomeScreen build method:
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(70),
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(24),
            ),
            child: AppBar(
              backgroundColor: Colors.white.withOpacity(0.7),
              elevation: 0,
              flexibleSpace: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(),
              ),
              title: Text(
                "Application",
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                  letterSpacing: 1.2,
                ),
              ),
              centerTitle: true,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.1),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.2),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                          Icons.notifications_none, color: Colors.blueAccent,
                          size: 28),
                      onPressed: () {},
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        drawer: ClipRRect(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(32),
            bottomRight: Radius.circular(0),
          ),
          child: Drawer(
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
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.white,
                          child: Image.asset(
                            "lib/Assets/Icons/user.png",
                            height: 48,
                          ),
                        ),
                        SizedBox(width: 16),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Admin",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                )),
                            SizedBox(height: 4),
                            Text("Admin@admin.com",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 15,
                                )),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 8),
                ListTile(
                  leading: Icon(Icons.home_rounded, color: Colors.blueAccent),
                  title: Text(
                      "Home", style: TextStyle(fontWeight: FontWeight.w500)),
                  onTap: () => _onItemTapped(0),
                ),
                ListTile(
                  leading: Icon(
                      Icons.info_outline_rounded, color: Colors.blueAccent),
                  title: Text(
                      "About", style: TextStyle(fontWeight: FontWeight.w500)),
                  onTap: () => _onItemTapped(2),
                ),
                ListTile(
                  leading: Icon(
                      Icons.settings_rounded, color: Colors.blueAccent),
                  title: Text("Settings",
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  onTap: () => _onItemTapped(3),
                ),
                Divider(thickness: 1, color: Colors.grey[200], height: 32),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(child: Container()),
                      SignOutButton(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        body: _screen
    );
  }
}



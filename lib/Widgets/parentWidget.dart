import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:ict602_group_project/Widgets/customDrawer.dart';
import 'package:loader_overlay/loader_overlay.dart';

class ParentWidget extends StatefulWidget {
  final Widget child;
  const ParentWidget({super.key, required this.child});



  @override
  State<ParentWidget> createState() => _ParentwidgetState();

}

class _ParentwidgetState extends State<ParentWidget> {

  final auth = FirebaseAuth.instance;
  Map<String, dynamic>? userInformation;

  Future<void> currentUserData() async {
    context.loaderOverlay.show();
    final userData = FirebaseFirestore.instance.collection('users').doc(
        auth.currentUser?.uid);
    final currentUserData = await userData.get();

    setState(() {
      if (currentUserData.exists) {
        userInformation = currentUserData.data();
      }
    });

    context.loaderOverlay.hide();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              "FoodTruck Finder",
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
      drawer: CustomDrawer(userInformation: userInformation, auth: auth),
      body: LoaderOverlay(
        child: widget.child,
        overlayWidgetBuilder: (_) {
          return Center(
              child: SpinKitThreeInOut(
                color: Colors.blueAccent,
                size: 50.0,
              )
          );
        },
      ),
    );
  }
}


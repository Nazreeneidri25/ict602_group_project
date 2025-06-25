import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loader_overlay/loader_overlay.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  File? _image;
  final picker = ImagePicker();
  final _usernameController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _emailController = TextEditingController();

  final auth = FirebaseAuth.instance;
  Timer? _emailCheckTimer;

  Future<void> getUserData() async {
    context.loaderOverlay.show();
    final doc = FirebaseFirestore.instance.collection('users').doc(
        auth.currentUser?.uid);
    final currentUser = await doc.get();
    final userData = currentUser.data();


    context.loaderOverlay.hide();
    if (userData != null) {
      setState(() {
        _usernameController.text = userData['username'] ?? '';
        _emailController.text = userData['email'] ?? '';
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }


  Future<void> _saveProfile() async {

    try {
      context.loaderOverlay.show();
      await FirebaseAuth.instance.currentUser?.verifyBeforeUpdateEmail(_emailController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification email sent to ${_emailController.text} Please verify to update your email.')),
      );
      await verification();

    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        Navigator.popAndPushNamed(context, "/auth");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email cannot be changed')),
        );
      }
    }

    if(_image != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(auth.currentUser?.uid)
          .set({
        'photoURL': _image
      }, SetOptions(merge: true));
      context.loaderOverlay.hide();
    }
  }

  void _changePassword() {
    // Implement password change logic here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Password change requested!')),
    );
  }

  Future<void> verification() async {
    context.loaderOverlay.show();
    _emailCheckTimer = Timer.periodic(Duration(seconds: 3), (timer) async {

      FirebaseAuth.instance.currentUser?.reload();

      if(FirebaseAuth.instance.currentUser == null){
        timer.cancel();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Re-authenticate to complete change of email")));
        FirebaseAuth.instance.signOut();
        Navigator.popAndPushNamed(context, "/auth");
        context.loaderOverlay.hide();
      }



      // FirebaseAuth.instance.currentUser?.reload();
      // print("CURRENT USER EMAIL : ${FirebaseAuth.instance.currentUser}");
      // if (FirebaseAuth.instance.currentUser?.email ==_emailController.text) {
      //   // Update Firestore with the new email
      //   final doc = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid);
      //   await doc.set({
      //     "email": FirebaseAuth.instance.currentUser?.email,
      //     "username": _usernameController.text,
      //     "role": "user"
      //   }, SetOptions(merge: true));
      //   setState(() {}); // Rebuild UI
      //   timer.cancel();
      //   context.loaderOverlay.hide();
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text('Email updated in Firestore!')),
      //   );
      //   Navigator.popAndPushNamed(context, "/auth");
      // }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserData();
  }

  @override
  void dispose() {
    _emailCheckTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: auth.currentUser!.emailVerified ?
          Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  child: _image == null
                      ? Icon(Icons.camera_alt, size: 40, color: Colors.grey)
                      : null,
                ),
              ),
              SizedBox(height: 24),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _saveProfile(),
                child: Text('Save Profile'),
              ),
              Divider(height: 40),
              TextField(
                controller: _currentPasswordController,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 12),
              TextField(
                controller: _newPasswordController,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _changePassword,
                child: Text('Change Password'),
              ),
            ],
          ) : Center(
            child:
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.yellow[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orangeAccent, width: 2),
                ),
                child: Column(
                  children: [
                    Text(
                      'Your email is not verified!',
                      style: TextStyle(
                        color: Colors.orange[900],
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 12),
                    ElevatedButton.icon(
                      icon: Icon(Icons.email, color: Colors.white),
                      label: Text('Send Verification Email'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        await auth.currentUser?.sendEmailVerification();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(
                              'Verification email sent! Please check your inbox.')),
                        );
                      },
                    ),
                  ],
                ),
              ),
          )
      ),
    );
  }
}
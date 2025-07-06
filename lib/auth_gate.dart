import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<void> _handlePostSignIn(BuildContext context, User user) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final doc = await userDoc.get();
    print(doc);
    if (doc.exists && doc['role'] == 'admin') {
      print("admin_dashboard");
      Navigator.pushReplacementNamed(context, '/admin_dashboard');
    } else {
      await userDoc.set({
        'email': user.email,
        'role': 'user',
        'photoURL' : user.photoURL ?? null,
        'username' :  user.displayName ?? null,
      }, SetOptions(merge: true));
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SignInScreen(
            providers: [
              EmailAuthProvider(),
              GoogleProvider(clientId: "662317488999-545r1t8utr6r2d8becvg2cuf0629hhfv.apps.googleusercontent.com"),
            ],
            headerBuilder: (context, constraints, shrinkOffset) => Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Expanded(
                  child:Image.asset(
                "lib/Assets/Icons/food_truck.png",
              ))],
            ),
            subtitleBuilder: (context, action) => Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text(
                  "Welcome to our Application, Please ${action == AuthAction.signIn ? "Sign In" : "Sign Up"}"
              ),
            ),
            footerBuilder: (context, action) => const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text(
                "By signing in, you agree to our terms and conditions",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            actions: [
              AuthStateChangeAction<SignedIn>((context, state) async {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  await _handlePostSignIn(context, user);
                }
              }),
            ],
          );
        }
        // Already signed in, check role and redirect
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            await _handlePostSignIn(context, user);
          }
        });
        return Container(
          color: Colors.white,
          child: Center(
            child: SpinKitThreeInOut(
              color: Colors.blueAccent,
              size: 50,
            ),
          )
        );
      },
    );
  }
}
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:ict602_group_project/Screen/home.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context , snapshot) { //snapshot gain data from stream | stream return firebase user if it is authenticated
          if (!snapshot
              .hasData) { //if there's no user object currently (not login - means data is empty)
            return SignInScreen( //SignInScreen that is provided by FlutterFire allow user to sign , forgot password and register
              providers: [
                EmailAuthProvider(), // This widget is built in from FlutterFire | there will have 'email' and 'password' text input and 'sign in' button
                GoogleProvider(clientId: "662317488999-545r1t8utr6r2d8becvg2cuf0629hhfv.apps.googleusercontent.com"),
              ],
              headerBuilder: (context, constraints, shrinkOffset) {
                //headerBuilder argument allow us to customize above sign form (provider) widgets of SignScreen
                //only for narrow screen !!! | wide screen use sideBuilder
                return Column(
                  children: [
                    Text("[LOGO]"),
                  ],
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                );
              },
              subtitleBuilder: (context, action) {
                //subtitleBuilder is the customization for adding secondary heading in the application
                //intended for text rather than images (although we can add any widget we want)
                return Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text(
                      "Welcome to our Application, Please ${action == AuthAction.signIn
                          ? "Sign In"
                          : "Sign Up"}"
                  ),
                );
              },
              footerBuilder: (context , action){
                //similar like subtitle builder. use for text rather than images
                return const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text(
                        "By signing in, you agree to our terms and conditions",
                      style: TextStyle(color: Colors.grey),
                    )
                );
              },
              // sideBuilder: (context , action){
              //
              // }
            );
          }
          return const HomeScreen();
        }
    );
  }
}

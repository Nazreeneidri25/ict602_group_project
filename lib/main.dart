import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:ict602_group_project/Screen/addMarker.dart';
import 'package:ict602_group_project/Screen/admin_dashboard.dart';
import 'package:ict602_group_project/Screen/home.dart';
import 'package:ict602_group_project/Screen/profile.dart';
import 'package:ict602_group_project/auth_gate.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'Widgets/parentWidget.dart';
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';


void main()async{
  WidgetsFlutterBinding.ensureInitialized(); //tells Flutter to not start the widget code until flutter framework is completely booted
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Our Group Project',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        textTheme: GoogleFonts.poppinsTextTheme()
      ),
      home: LoaderOverlay(
          child: AuthGate(),
          overlayWidgetBuilder: (_){
            return Center(
              child: SpinKitDancingSquare(
                color: Colors.blueAccent,
                size: 50.0,
              )
            );
          },
      ),
      routes: {
        "/auth": (context) => AuthGate(),
        "/admin_dashboard": (context) => AdminDashboard(),
        "/home": (context) => ParentWidget(child: HomeScreen()),
        "/profile" : (context) => ParentWidget(child: Profile()),
        "/addMarker" : (context) => ParentWidget(child: AddMarker()),
      },
    );
  }
}

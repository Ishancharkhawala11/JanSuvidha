import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:safe_alert/screens/LoginScreen.dart';
import 'package:safe_alert/screens/SplashScreen.dart';

import 'firebase_options.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
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
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:const Splashscreen(),
    );
  }
}


// Left-to-right: begin: Offset(-1.0, 0.0), end: Offset.zero
// Top-to-bottom: begin: Offset(0.0, -1.0), end: Offset.zero
// Bottom-to-top: begin: Offset(0.0, 1.0), end: Offset.zero



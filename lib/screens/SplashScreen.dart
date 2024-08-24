

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safe_alert/screens/HomeScreen.dart';
import 'package:safe_alert/screens/LoginScreen.dart';

import '../Utils.dart';


class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(seconds: 3),(){
      if(FirebaseAuth.instance.currentUser==null){
        Utils.navigateWithSlideTransitionWithPushReplacement(context: context, screen:const Loginscreen(), begin: Offset(1, 0), end: Offset.zero);
      }else{
        Utils.navigateWithSlideTransitionWithPushReplacement(context: context, screen:const Homescreen(), begin: Offset(1, 0), end: Offset.zero);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              "images/sos_logo2.png",
              width: 300,
              height: 300,
            ),
            Positioned(
              top: 240,
                child: Text(
              "Safe Alert",
              style: TextStyle(
                  color: Colors.yellow.shade700,
                  fontSize: 30,
                  fontWeight: FontWeight.bold),
            ))
          ],
        ),
      ),
    );
  }
}

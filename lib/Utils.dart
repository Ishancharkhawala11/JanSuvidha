import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Utils{

  static void showSnackbar({required BuildContext context,required String msg}){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  static void navigateWithSlideTransitionWithPushReplacement({
    required BuildContext context,
    required Widget screen,
    required Offset begin,
    required Offset end,
  }) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.easeInOut));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500), // Adjust duration as needed
      ),
    );
  }

  static void navigateWithSlideTransitionWithPush({
    required BuildContext context,
    required Widget screen,
    required Offset begin,
    required Offset end,
  }) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.easeInOut));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500), // Adjust duration as needed
      ),
    );
  }

  static void showdialog({required BuildContext context ,required String msg}){
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissal when tapping outside the dialog
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow.shade700),
              ),
              const SizedBox(height: 20),
               Text(
                msg,
                style:const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        );
      },
    );
  }

}
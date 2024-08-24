
import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:safe_alert/Utils.dart';
import 'package:safe_alert/models/User.dart';

class Services {
  static final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  static final FirebaseFirestore fireStore = FirebaseFirestore.instance;

  static Future<UserCredential?> createAccount(
      {required String email, required String password , required BuildContext context}) async {
    try {
      UserCredential? user = await firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      return user;
    } on FirebaseAuthException catch (e) {
      print("error : ${e.toString()}");
      Utils.showSnackbar(context: context, msg: e.toString());
      return null;
    }
  }

  static Future<void> saveUserDataToFirebase(Map<String, dynamic> data) async {
    User? currentUser = firebaseAuth.currentUser;
    if (currentUser != null) {
      await fireStore.collection("Users").doc(currentUser.uid).set(data);
    } else {
      throw Exception("User not authenticated. Cannot save data.");
    }
  }

  static Future<bool> loginWithEmailAndPassword({required String email , required String password ,required BuildContext context }) async {
      try{
        await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
        return true;
      }on FirebaseAuthException catch(e){

        if(e.code=="user-not-found"){
          Utils.showSnackbar(context: context, msg: "User not found");
        }else if(e.code=="wrong-password"){
          Utils.showSnackbar(context: context, msg: "Wrong Password");
        }else{
          print("error : ${e.toString()}");
          Utils.showSnackbar(context: context, msg: e.toString());
        }


        return false;
      }
  }

  static Future<bool> signOut() async{
    await firebaseAuth.signOut();
    return true;
  }

  static Future<Users> getUserInfo() async {

    String uid = firebaseAuth.currentUser!.uid;

    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await fireStore.collection("Users").doc(uid).get();

    if (documentSnapshot.exists) {
      Users user = Users.fromJson(documentSnapshot.data()!);
      return user;
    } else {
      throw Exception("User not found");
    }
  }

  static Future<void> updateUserInfo({required String name ,required String address , required String phone , required String emergency}) async {

    String uid = firebaseAuth.currentUser!.uid;
    await fireStore.collection("Users").doc(uid).update({
      "fullName" : name,
      "address" : address,
      "mobileNo" : phone,
      "emergencyNo" : emergency,
    });

  }

  static Future<void> addPostToFirebase({required String title , required String body , required String image,required String date}) async {

    await fireStore.collection("Forum").add({
      "title" : title,
      "body" : body,
      "image" : image,
      "date" : date,
    });

  }

  static Future<QuerySnapshot<Map<String, dynamic>>> getAllPosts() async {
    return await fireStore.collection("Forum").get();
  }


}


import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Utils.dart';
class ForgotPass extends StatefulWidget {
  const ForgotPass({super.key});

  @override
  State<ForgotPass> createState() => _ForgotPassState();
}

class _ForgotPassState extends State<ForgotPass> {
  String? email;
  TextEditingController Email=TextEditingController();
  final _formKey = GlobalKey<FormState>();

  resetPass() async{
    try{
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email!);
      Utils.showSnackbar(context: context, msg: "Password Reset link is send to your Email");
    }on FirebaseAuthException catch(e){
      if(e.code=='user-not-found')
      {
        Utils.showSnackbar(context: context, msg: "No user found for the Email");
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          const SizedBox(
            height: 70,
          ),
          Container(
            alignment: Alignment.topCenter,
            child:Text("Password Recovery",style: TextStyle(color: Colors.yellow.shade700,fontSize: 30,fontWeight: FontWeight.bold),),
          ),
         const SizedBox(height: 10,),
          Text("Enter your email",style: TextStyle(color: Colors.yellow.shade700,fontSize: 30,fontWeight: FontWeight.bold),),
          const SizedBox(height: 30,),
          Form(
            key: _formKey,
            child: Container(
              margin:const EdgeInsets.symmetric(horizontal: 20),
              padding:const EdgeInsets.only(left: 10,top: 5,bottom: 5) ,
              decoration: BoxDecoration(
                  border: Border.all(color:Colors.white70,width: 2 ),
                  borderRadius: BorderRadius.circular(30)
              ),
              child: TextFormField(
                validator: (value)
                {
                  if(value==null || value.isEmpty)
                  {
                    return "Enter your Email";
                  }
                  return null;
                },
                controller: Email,
                style:const TextStyle(
                    color: Colors.white
                ),
                decoration:const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter your Email",
                    hintStyle: TextStyle(fontSize: 18,color: Colors.grey),
                    prefixIcon: Icon(Icons.mail_outline,color: Colors.white70,size: 30,)
                ),
              ),
            ),
          ),
          const SizedBox(height: 20,),
          GestureDetector(
            onTap: () {
              if(_formKey.currentState!.validate())
              {
                setState(() {
                  email=Email.text;
                });
                resetPass();
              }

            },
            child: Container(
              padding:const EdgeInsets.symmetric(horizontal: 30,vertical: 10),
              decoration: BoxDecoration(
                  color: Colors.yellow.shade700,
                  borderRadius: BorderRadius.circular(30)
              ),
              child:const Text(
                "Send Email",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


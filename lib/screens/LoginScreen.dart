import 'package:flutter/material.dart';
import 'package:safe_alert/Services.dart';
import 'package:safe_alert/screens/ForgotPasswordScreen.dart';
import 'package:safe_alert/screens/HomeScreen.dart';
import 'package:safe_alert/screens/SignInScreen.dart';

import '../Utils.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  String _email = "";
  String _password = "";
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.black,
      body: Container(
        padding:const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset("images/sos_logo2.png",width: 200,height: 150,),
                  Text("Welcome!",style: TextStyle(fontSize: 40,fontWeight: FontWeight.bold,letterSpacing: 0.5,color: Colors.yellow.shade700),),
                  const SizedBox(
                    height: 5,
                  ),
                  const Text("Log in here!!" , style: TextStyle(color: Colors.white,fontSize: 20),),
                  const SizedBox(height: 20),
                  inputTextField(
                      label: "Email",
                      errorMsg: "Please enter email",
                      icon: Icon(
                        Icons.email,
                        color: Colors.yellow.shade700,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      toggle: false,
                      onSaved: (value) {
                        _email = value!;
                      }),
                  const SizedBox(height: 20),
                  inputTextField(
                      label: "Password",
                      errorMsg: "Please enter password",
                      icon: Icon(
                        Icons.password,
                        color: Colors.yellow.shade700,
                      ),
                      keyboardType: TextInputType.text,
                      toggle: true,
                      onSaved: (value) {
                        _password = value!;
                      }),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                              Services.loginWithEmailAndPassword(email: _email, password: _password, context: context).then((value){
                                if(value){
                                  Utils.showSnackbar(context: context, msg: "Logged in successfully!!");
                                  Utils.navigateWithSlideTransitionWithPushReplacement(context: context, screen: const Homescreen(), begin:const Offset(1, 0), end: Offset.zero);
                                }
                                else{
                                  Utils.showSnackbar(context: context, msg: "Error in login");
                                }
                              });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.yellow.shade700),
                      child: const Text(
                        'Login',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20,),
                  InkWell(
                    onTap: (){
                      Utils.navigateWithSlideTransitionWithPush(context: context, screen: const ForgotPass(), begin: const Offset(0.0, 1.0), end: Offset.zero);
                    },
                      child: Text("Forgot password?",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.yellow.shade700),textAlign: TextAlign.end,)),
                  const SizedBox(height: 20,),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Create new Account?",style: TextStyle(fontSize: 16 , color: Colors.white),),
                        const SizedBox(width: 5,),
                        InkWell(
                            onTap: () => Utils.navigateWithSlideTransitionWithPushReplacement(context: context, screen: const Signinscreen(), begin:const Offset(0, 1), end: Offset.zero),
                            child: Text("Create",style: TextStyle(color: Colors.yellow.shade700,fontSize: 18),)),
                        const SizedBox(height: 20,),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget inputTextField(
      {required String label,
        required String errorMsg,
        required Icon icon,
        required TextInputType keyboardType,
        required bool toggle,
        required FormFieldSetter<String> onSaved}) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 60,
      child: TextFormField(
        style: const TextStyle(color: Colors.white),
        keyboardType: keyboardType,
        obscureText: toggle,
        decoration: InputDecoration(
            prefixIcon: icon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(
                color: Colors.grey,
                width: 1,
              ),

            ),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(
                  color: Colors.yellow.shade700,

                )
            ),
            labelStyle: const TextStyle(color: Colors.grey),
            labelText: label),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return errorMsg;
          }
          return null;
        },
        onSaved: onSaved,
      ),
    );
  }
}

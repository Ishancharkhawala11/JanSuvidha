import 'package:flutter/material.dart';
import 'package:safe_alert/Services.dart';
import 'package:safe_alert/Utils.dart';
import 'package:safe_alert/screens/HomeScreen.dart';
import 'package:safe_alert/screens/LoginScreen.dart';

class Signinscreen extends StatefulWidget {
  const Signinscreen({super.key});

  @override
  State<Signinscreen> createState() => _SigninscreenState();
}

class _SigninscreenState extends State<Signinscreen> {
  final _formKey = GlobalKey<FormState>();

  String _fullName = '';
  String _email = '';
  String _password = '';
  String _mobileNo = '';
  String _address = '';
  String _gender = 'Male';
  String _emergencyNo = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Padding(
          padding:const EdgeInsets.only(top: 10),
            child: Text("Get Registered!!" , style: TextStyle(fontSize: 35,fontWeight: FontWeight.bold,letterSpacing: 0.5,color: Colors.yellow.shade700,),textAlign: TextAlign.center,)),
          centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              const SizedBox(height: 10,),
              inputTextField(
                  label: "Full Name",
                  errorMsg: "Please enter full name",
                  icon: Icon(
                    Icons.person,
                    color: Colors.yellow.shade700,
                  ),
                  keyboardType: TextInputType.text,
                  toggle: false,
                  onSaved: (value) {
                    _fullName = value!;
                  }),
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
              inputTextField(
                  label: "Mobile No",
                  errorMsg: "Please enter mobile no",
                  icon: Icon(
                    Icons.phone,
                    color: Colors.yellow.shade700,
                  ),
                  keyboardType: TextInputType.number,
                  toggle: false,
                  onSaved: (value) {
                    _mobileNo = value!;
                  }),
              const SizedBox(height: 20),
              inputTextField(
                  label: "Address",
                  errorMsg: "Please enter address",
                  icon: Icon(
                    Icons.location_pin,
                    color: Colors.yellow.shade700,
                  ),
                  keyboardType: TextInputType.text,
                  toggle: false,
                  onSaved: (value) {
                    _address = value!;
                  }),
              const SizedBox(height: 20),
              Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    border: Border.all(width: 1.5, color: Colors.grey),
                    borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    const Text('Gender',
                        style: TextStyle(fontSize: 16, color: Colors.grey)),
                    Row(
                      children: [
                        Flexible(
                          child: SizedBox(
                            height: 60,
                            child: ListTile(
                              title: const Text(
                                'Male',
                                style: TextStyle(color: Colors.white),
                              ),
                              leading: Radio<String>(
                                activeColor: Colors.yellow.shade700,
                                value: 'Male',
                                groupValue: _gender,
                                onChanged: (String? value) {
                                  setState(() {
                                    _gender = value!;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: SizedBox(
                            height: 60,
                            child: ListTile(
                              title: const Text('Female',
                                  style: TextStyle(color: Colors.white)),
                              leading: Radio<String>(
                                activeColor: Colors.yellow.shade700,
                                value: 'Female',
                                groupValue: _gender,
                                onChanged: (String? value) {
                                  setState(() {
                                    _gender = value!;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),
              inputTextField(
                  label: "Emergency No",
                  errorMsg: "Please enter emergency no",
                  icon: Icon(
                    Icons.phone_iphone,
                    color: Colors.yellow.shade700,
                  ),
                  keyboardType: TextInputType.number,
                  toggle: false,
                  onSaved: (value) {
                    _emergencyNo = value!;
                  }),
              const SizedBox(height: 20),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: ()  {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      Map<String , dynamic> data = {
                        "fullName": _fullName,
                        "email": _email,
                        "mobileNo": _mobileNo,
                        "address": _address,
                        "gender": _gender,
                        "emergencyNo": _emergencyNo
                      };
                      Services.createAccount(email: _email, password: _password, context: context).then((value) {
                        if(value?.user!=null){
                          Services.saveUserDataToFirebase(data);
                          Utils.showSnackbar(context: context, msg: "Account created successfully!!");
                          Utils.navigateWithSlideTransitionWithPushReplacement(context: context, screen: const Homescreen(), begin:const Offset(1, 0), end: Offset.zero);
                        }else{
                          Utils.showSnackbar(context: context, msg: "User not authenticated!!");
                        }
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.yellow.shade700),
                  child: const Text(
                    'Create Account',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20,),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an Account?",style: TextStyle(fontSize: 16 , color: Colors.white),),
                    const SizedBox(width: 5,),
                    InkWell(
                        onTap: ()=> Utils.navigateWithSlideTransitionWithPushReplacement(context: context, screen: const Loginscreen(), begin:const Offset(0, -1), end: Offset.zero),
                        child: Text("Login",style: TextStyle(color: Colors.yellow.shade700,fontSize: 18),)),
                    const SizedBox(height: 20,),
                  ],
                ),
              )
            ],
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


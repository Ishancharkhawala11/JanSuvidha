import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:safe_alert/Services.dart';
import 'package:safe_alert/Utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/User.dart';

class Profilescreen extends StatefulWidget {
  const Profilescreen({super.key});

  @override
  State<Profilescreen> createState() => _ProfilescreenState();
}

class _ProfilescreenState extends State<Profilescreen> {
  var nameController = TextEditingController();
  var addressController = TextEditingController();
  var phoneController = TextEditingController();
  var emergencyController = TextEditingController();

   String? email;

  @override
  void initState() {
    super.initState();
      getData();
  }

  getData() async{
    SharedPreferences sdf = await SharedPreferences.getInstance();
    nameController.text = sdf.getString("name") ?? "";
    addressController.text = sdf.getString("address") ?? "";
    phoneController.text = sdf.getString("phone") ?? "";
    emergencyController.text = sdf.getString("emergency") ?? "";
    email = sdf.getString("email") ?? "";
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title:Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: () => Navigator.pop(context),
              child: const Icon(CupertinoIcons.back, color: Colors.white,),
            ),
            const SizedBox(width: 10,),
            Text(
              "Profile",
              style: TextStyle(color: Colors.yellow.shade700, fontSize: 26, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(20),
          child: Column(
            children: [
              Image.asset("images/person2.png",width: 250,height: 300,),
              Text(email==null ? "" : email!,style: TextStyle(fontSize: 20,color: Colors.yellow.shade700),textAlign: TextAlign.center,),
              const SizedBox(height: 20),
              buildRow("Name", nameController),
              const SizedBox(height: 20),
              buildRow("Address", addressController),
              const SizedBox(height: 20),
              buildRow("Phone", phoneController),
              const SizedBox(height: 20),
              buildRow("Emergency Contact", emergencyController),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.yellow.shade700),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        side:  BorderSide(color: Colors.yellow.shade700, width: 4),
                      ),
                    ),
                  ),
                  onPressed: () async{
                    SharedPreferences sdf = await SharedPreferences.getInstance();
                    sdf.setString("name", nameController.text);
                    sdf.setString("address", addressController.text);
                    sdf.setString("phone", phoneController.text);
                    sdf.setString("emergency", emergencyController.text);

                    setState(() {

                    });

                    Services.updateUserInfo(name: nameController.text, address: addressController.text, phone: phoneController.text, emergency: emergencyController.text).then((value){
                      Utils.showSnackbar(context: context, msg: "Update Successfully!!");
                    });

                  },
                  child: const Text(
                    "Save",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
        
            ],
        
          ),
        ),
      ),
      backgroundColor: Colors.black,
    );
  }

  Widget buildRow(String label, TextEditingController cnt) {
    return Row(
      children: [
        Container(
          width: 130,
          child: Text(
            label,
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.yellow.shade700),
          ),
        ),
        const Spacer(),
        Expanded(
          flex: 2,
          child: TextField(
            controller: cnt,
            decoration: const InputDecoration(
              isDense: true, // Less vertical padding
              contentPadding: EdgeInsets.symmetric(horizontal: 8),
            ),
            style: TextStyle(color: Colors.white,fontSize: 22), // Adjust the text color
          ),
        ),
      ],
    );
  }
}

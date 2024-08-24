import 'package:flutter/material.dart';
import 'package:safe_alert/Services.dart';
import 'package:safe_alert/Utils.dart';
import 'package:safe_alert/screens/EmergencyScreen.dart';
import 'package:safe_alert/screens/ForumScreen.dart';
import 'package:safe_alert/screens/LoginScreen.dart';
import 'package:safe_alert/screens/ProfileScreen.dart';
import 'package:safe_alert/screens/ReportingScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/GridItem.dart';
import '../models/User.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  final List<GridItem> items = [
    GridItem(
        imagePath: 'images/sos.png',
        title: 'Emergency',
        subText: 'Are you in Trouble ? Send Emergency signal'),
    GridItem(
        imagePath: 'images/reporting.png',
        title: 'Reporting',
        subText: "Want to Report an incident ?"),
    GridItem(
        imagePath: 'images/forum.png',
        title: 'Forum',
        subText: 'Get Your Task here'),
    GridItem(
        imagePath: 'images/profile.png',
        title: 'Profile',
        subText: 'Manage Your Profile here'),
  ];
  late Users user;


  final List<Widget> list = [ const Emergencyscreen(), const Reportingscreen(),const Forumscreen(),const Profilescreen()];


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getUserInfo();
  }

  Future<void> _getUserInfo() async {
    try {
      user = await Services.getUserInfo();
      if (user != null) {
         SharedPreferences sdf = await SharedPreferences.getInstance();
         sdf.setString("name", user.fullName!);
         sdf.setString("address", user.address!);
         sdf.setString("phone", user.mobileNo!);
         sdf.setString("emergency", user.emergencyNo!);
         sdf.setString("email", user.email!);
      }
    } catch (e) {
      print("Error fetching user info: $e");

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 10,),
              Row(
                children: [
                  Image.asset("images/sos_logo2.png",width: 80,height: 80,),
                  const SizedBox(width: 10,),
                  Text("Safe Alert" ,style: TextStyle(color: Colors.yellow.shade700,fontSize: 24,fontWeight: FontWeight.bold),),
                ],
              ),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 columns
                    crossAxisSpacing: 10.0, // Space between columns
                    mainAxisSpacing: 20.0, // Space between rows
                    childAspectRatio: 2 / 3, // Aspect ratio for items
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: (){
                        Utils.navigateWithSlideTransitionWithPush(context: context, screen: list[index], begin:const Offset(1, 0), end: Offset.zero);
                      },
                      child: GridItemCard(
                          imagePath: items[index].imagePath,
                          title: items[index].title,
                          subText: items[index].subText),
                    );
                  },
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                    onPressed: () {
                      Services.signOut().then((value){
                        if(value){
                          Utils.showSnackbar(context: context, msg: "Logout successfully!!");
                          Utils.navigateWithSlideTransitionWithPushReplacement(context: context, screen:const Loginscreen(), begin:const Offset(0, 1), end: Offset.zero);                    }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow.shade700,foregroundColor: Colors.black
                  ),
                  child:const Text(
                      "Logout",
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                ),
              ),
            ],
          ),
        ));
  }

  Widget GridItemCard(
      {required String imagePath,
      required String title,
      required String subText}) {
    return Container(
      padding:const EdgeInsets.all(10),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.yellow.shade700),
          borderRadius: BorderRadius.circular(20)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 5,
          ),
          Image.asset(
            imagePath,
            width: 60,
            height: 60,
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            title,
            style: TextStyle(
                color: Colors.yellow.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 20),
          ),
          const SizedBox(
            height: 10,
          ),
          const Divider(
            color: Colors.grey,
            thickness: 1,
            indent: 16,
            endIndent: 16,
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            subText,
            style:const TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}

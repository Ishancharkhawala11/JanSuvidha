import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:geolocator/geolocator.dart';
import 'package:safe_alert/Utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telephony/telephony.dart';
import '../models/EmergencyContact.dart';

class Emergencyscreen extends StatefulWidget {
  const Emergencyscreen({super.key });

  @override
  State<Emergencyscreen> createState() => _EmergencyscreenState();
}

class _EmergencyscreenState extends State<Emergencyscreen> {

  late double _latitude;
  late double _longitude;
  final Telephony telephony = Telephony.instance;
   String emergencyPhone = "";


  @override
  void initState() {
    super.initState();
    _getLocation();
    _requestPermissions();
    getEmergencyPhone();
  }

  late  List<EmergencyContact> items;

  Future<void> getEmergencyPhone() async{
    SharedPreferences sdf = await SharedPreferences.getInstance();
    emergencyPhone = sdf.getString("emergency").toString();
    setState(() {
      items = [
        EmergencyContact(imagePath:"images/home_call.png",name: "Home", phoneNo:"+91${emergencyPhone}"),
        EmergencyContact(imagePath:"images/ambulance.png",name: "Ambulance", phoneNo: "102"),
        EmergencyContact(imagePath:"images/fire_call.png",name: "Fire", phoneNo: "101"),
        EmergencyContact(imagePath:"images/police_call.png",name: "Police", phoneNo: "100"),
        EmergencyContact(imagePath:"images/women_call.png",name: "Women Help", phoneNo: "181"),
        EmergencyContact(imagePath:"images/child_call.png",name: "Child Support", phoneNo: "1098"),
        EmergencyContact(imagePath:"images/wildlife_call.png",name: "Wildlife Support", phoneNo: "155125"),
      ];
    });
  }


  Future<void> _requestPermissions() async {
    bool? result = await telephony.requestSmsPermissions;
    print("SMS Permission Granted: $result");
    if (result != null && !result) {
      Utils.showSnackbar(context: context, msg: "SMS permission is not granted.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const SizedBox(height: 30,),
            Row(
              children: [
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(CupertinoIcons.back, color: Colors.white,),
                ),
                const SizedBox(width: 10,),
                Text(
                  "One-Touch SOS Alert",
                  style: TextStyle(color: Colors.yellow.shade700, fontSize: 20, fontWeight: FontWeight.bold),
                )
              ],
            ),
            const SizedBox(height: 20,),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "One-touch SMS and phone calling -- safety is just a tap away.",
                style: TextStyle(color: Colors.grey, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10,),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: 2 / 3.2,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {},
                    child: GridItemCard(
                        imagePath: items[index].imagePath,
                        title: items[index].name,
                        phone: items[index].phoneNo
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget GridItemCard({required String imagePath, required String title, required String phone}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.yellow.shade700),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 5,),
          Image.asset(
            imagePath,
            width: MediaQuery.of(context).size.width * 0.09,
            height: MediaQuery.of(context).size.width * 0.09,
          ),
          const SizedBox(height: 5,),
          Text(
            title,
            style: TextStyle(
                color: Colors.yellow.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 16
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5,),
          const Divider(color: Colors.grey, thickness: 1, indent: 16, endIndent: 16,),
          const SizedBox(height: 5,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                  onTap: () {
                    sendMessage(phone, "Emergency Type: $title\nHelp Needed Immediately!\n", _latitude, _longitude);
                  },
                  child: Icon(Icons.message, color: Colors.grey,)
              ),
              const SizedBox(width: 15,),
              InkWell(
                  onTap: () {
                    makeCall(emergencyPhone);
                  },
                  child: Icon(Icons.phone, color: Colors.grey)
              )
            ],
          )
        ],
      ),
    );
  }

  Future<void> _getLocation() async {
    try {
      Map<String, double> location = await getCurrentLocation();
      setState(() {
        _latitude = location['latitude']!;
        _longitude = location['longitude']!;
      });
    } catch (e) {
      setState(() {
        Utils.showSnackbar(context: context, msg: "Error: ${e.toString()}");
      });
    }
  }

  Future<Map<String, double>> getCurrentLocation() async {
    bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationServiceEnabled) {
      Utils.showSnackbar(context: context, msg: "Location services are disabled.");
      throw Exception("Location services are disabled.");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
        throw Exception("Location permission is denied.");
      }
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    return {
      'latitude': position.latitude,
      'longitude': position.longitude,
    };
  }

  Future<void> sendMessage(String phoneNo, String message, double latitude, double longitude) async {
    String locationUrl = 'https://www.google.com/maps?q=$latitude,$longitude';
    String fullMessage = '$message\nLocation: $locationUrl';

    try {
      telephony.sendSms(
        to: phoneNo, // Replace with the actual recipient's phone number
        message: fullMessage,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("SMS sent successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send SMS: $e")),
      );
    }

  }

  Future<void> makeCall(String phoneNumber) async {
    try {
      bool? res = await FlutterPhoneDirectCaller.callNumber(phoneNumber);
      if (!res!) {
        throw 'Could not launch $phoneNumber';
      }
    } catch (e) {
      Utils.showSnackbar(context: context, msg: "Error launching phone: $e");
      print('Error launching phone: $e');
    }
  }
}
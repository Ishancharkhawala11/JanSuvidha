
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:telephony/telephony.dart';

import '../Utils.dart';

class Reportingscreen extends StatefulWidget {
  const Reportingscreen({super.key});

  @override
  State<Reportingscreen> createState() => _ReportingState();
}

class _ReportingState extends State<Reportingscreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<String> items = ["Criminal Activity", "Dead Body", "Lost/Found", "Accident","Suicide","Other"];
  String selected = "Criminal Activity";
  TextEditingController addController = TextEditingController();
  TextEditingController incidentController = TextEditingController();

  String formattedDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
  String formattedTime = DateFormat('hh:mm a').format(DateTime.now());
  String uId = FirebaseAuth.instance.currentUser!.uid;

  XFile? selectedImage;
  XFile? selectedVideo;
  XFile? selectedAudio;
  XFile? selectGallary;
  bool isLoading = false;

  double? latitude;
  double? longitude;

  final Telephony telephony = Telephony.instance;



  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
    _checkSmsPermission();
  }

  Future<void> submitReport() async {
    if (_formKey.currentState!.validate()) {
      String address = addController.text.trim();
      String incidentDescription = incidentController.text.trim();
      String? imageUrl;
      String? videoUrl;
      String? audioUrl;

      setState(() {
        isLoading = true;
      });

      Utils.showdialog(context: context, msg: "Uploading...");

      try {
        if (selectedImage != null) {
          imageUrl = await uploadImage(selectedImage!);
        }
        if(selectGallary!=null)
        {
          imageUrl=await uploadImage(selectGallary!);
        }
        if (selectedVideo != null) {
          videoUrl = await uploadVideo(selectedVideo!);
        }
        if (selectedAudio != null) {
          audioUrl = await uploadAudio(selectedAudio!);
        }

        Map<String, dynamic> report = {
          'dateTime': formattedDate+" "+formattedTime,
          'address': address,
          'description': incidentDescription,
          'userId': uId,
          'location': 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
          'image': imageUrl,
          'video': videoUrl,
          'audio': audioUrl,
        };

        await FirebaseFirestore.instance.collection(selected).add(report);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report submitted successfully!')),
        );

        String message = "Urgent: $selected reported.\nDescription : $incidentDescription\nLocation: https://www.google.com/maps/search/?api=1&query=$latitude,$longitude\nImage link: $imageUrl\nVideo link: $videoUrl\nAudio link: $audioUrl";

        await sendSms(selected, message);

        addController.clear();
        incidentController.clear();
        setState(() {
          selectedImage = null;
          selectedVideo = null;
          selectedAudio = null;
          selectGallary=null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit report: $e')),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
        Navigator.of(context).pop();
      }
    }
  }

  Future<String> uploadImage(XFile image) async {
    Reference storageRef = FirebaseStorage.instance
        .ref()
        .child("reports/images/${DateTime.now().millisecondsSinceEpoch}.jpg");
    UploadTask upload = storageRef.putFile(File(image.path));
    TaskSnapshot snapshot = await upload;
    return await snapshot.ref.getDownloadURL();
  }

  Future<String> uploadVideo(XFile video) async {
    Reference storageRef = FirebaseStorage.instance
        .ref()
        .child("reports/videos/${DateTime.now().millisecondsSinceEpoch}.mp4");
    UploadTask upload = storageRef.putFile(File(video.path));
    TaskSnapshot snapshot = await upload;
    return await snapshot.ref.getDownloadURL();
  }

  Future<String> uploadAudio(XFile audio) async {
    Reference storageRef = FirebaseStorage.instance
        .ref()
        .child("reports/audios/${DateTime.now().millisecondsSinceEpoch}.mp3");
    UploadTask upload = storageRef.putFile(File(audio.path));
    TaskSnapshot snapshot = await upload;
    return await snapshot.ref.getDownloadURL();
  }

  Future<bool> _checkLocationPermission() async {
    if (await Permission.location.isGranted) {
      return true;
    } else {
      var status = await Permission.location.request();
      return status.isGranted;
    }
  }

  Future<Position> _getCurrentLocation() async {
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  void _fetchCurrentLocation() async {
    bool permissionGranted = await _checkLocationPermission();

    if (permissionGranted) {
      try {
        Position position = await _getCurrentLocation();
        setState(() {
          latitude = position.latitude;
          longitude = position.longitude;
        });
        String address = await getAddressFromLatLng(latitude!, longitude!);
        setState(() {
          addController.text = address;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error getting location: $e")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Location permission not granted")),
      );
    }
  }


  Future<String> getAddressFromLatLng(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return " ${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
      }
      return "No address found";
    } catch (e) {
      return "Failed to get address: $e";
    }
  }

  Future<void> pickImage(ImageSource source,String path) async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: source, imageQuality: 80);

    if (file != null) {
      setState(() {
        path=="images/camera.png"?selectedImage = file : selectGallary=file;
      });
    }
  }

  Future<void> pickVideo(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickVideo(source: source);

    if (file != null) {
      setState(() {
        selectedVideo = file;
      });
    }
  }

  Future<void> pickAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedAudio = XFile(result.files.single.path!);
      });
    }
  }

  Future<void> sendSms(String activityType, String message) async{

    final Map<String, String> authorityNumbers = {
      "Criminal Activity": "+919512764192",
      "Dead Body": "+917878708333",
      "Lost/Found": "+91100",
      "Accident": "+91100",
      "Suicide": "+91100",
      "Other": "+91100"
    };

    final String? authorityPhoneNumber = authorityNumbers[activityType];

    try {
      await telephony.sendSms(
        to: "+919512764192", // Replace with the actual recipient's phone number
        message: message,
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          margin: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * .02,
            left: MediaQuery.of(context).size.width * .02,
            right: MediaQuery.of(context).size.width * .02,
          ),
          padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * .02,
            horizontal: MediaQuery.of(context).size.width * .06,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20,),
                Center(
                  child: Text(
                    "Reporting Incident",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 30,
                        color: Colors.yellow.shade700,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * .03),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRow(
                          context,
                          label: "Date and Time:",
                          child: Text(
                            formattedDate+"\n"+formattedTime,
                            style:const TextStyle(
                              fontSize: 20,color: Colors.grey
                            ),
                          ),
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height * .02),
                        _buildRow(
                          context,
                          label: "Address",
                          child: TextFormField(
                            controller: addController,
                            cursorColor: Colors.yellow.shade700,
                            decoration: InputDecoration(
                              hintText: "Enter Address",
                              hintStyle: TextStyle(color: Colors.grey),
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.yellow.shade700,
                                ),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.yellow.shade700,
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.yellow.shade700,
                                  width: 2.0,
                                ),
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter an address';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height * .02),
                        _buildRow(
                          context,
                          label: "Select Activity",
                          child: DropdownButtonFormField<String>(
                            value: selected,
                            items: items.map((item) {
                              return DropdownMenuItem<String>(
                                value: item,
                                child: Text(
                                  item,
                                  style:const TextStyle(fontSize: 20)
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selected = value!;
                              });
                            },
                            decoration: InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.yellow.shade700),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.yellow.shade700),
                              ),
                            ),
                            dropdownColor: Colors.black,
                            style:const TextStyle(color: Colors.white),
                            iconEnabledColor: Colors.yellowAccent,
                            alignment: AlignmentDirectional.bottomStart,
                          ),
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height * .02),
                        _buildRow(
                          context,
                          label: "Location",
                          child: latitude != null && longitude != null
                              ? Text(
                            "Lat: $latitude,\nLng: $longitude",
                            style:const TextStyle(fontSize: 18, color: Colors.grey)
                          ) :const Text(
                            "Fetching location...",
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height * .03),
                        Center(child: Text("Explain your Observation",style: TextStyle(fontSize: 18,color: Colors.yellow.shade700),)),
                       const SizedBox(height: 10,),
                        TextFormField(
                          controller: incidentController,
                          cursorColor: Colors.yellow.shade700,
                          decoration: InputDecoration(
                            hintText: "Write About Incident",
                            hintStyle:const TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: Colors.yellow.shade700),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: Colors.yellow.shade700),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color:Colors.yellow.shade700),
                            ),
                          ),
                          maxLines: 6,
                          style:const TextStyle(color: Colors.white),
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height * .03),
                        Center(child: Text("Upload Media",style: TextStyle(fontSize: 18,color: Colors.yellow.shade700),)),
                       const SizedBox(height: 10,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => pickImage(ImageSource.camera,"images/camera.png"),
                              child: _buildImageContainer("images/camera.png"),
                            ),
                            GestureDetector(
                              onTap: () => pickImage(ImageSource.gallery,"images/galary.png"),
                              child: _buildImageContainer("images/galary.png"),
                            ),
                            GestureDetector(
                              onTap: () => pickVideo(ImageSource.gallery),
                              child: _buildImageContainer("images/video.png"),
                            ),
                            GestureDetector(
                              onTap: () => pickAudio(),
                              child: _buildImageContainer("images/audio.png"),
                            ),
                          ],
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.03),
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
                            onPressed: submitReport,
                            child: const Text(
                              "Submit",
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, {required String label, required Widget child}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.3,
          child: Text(
            label,
            style:const TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
        SizedBox(width: MediaQuery.of(context).size.width * 0.02),
        Expanded(child: child),
      ],
    );
  }

  Widget _buildImageContainer(String imagePath) {
    if (imagePath == "images/camera.png") {
      return selectedImage != null
          ? Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.yellow.shade700),
          borderRadius: BorderRadius.circular(20),
        ),
        width: 70,
        height: 70,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Image.file(File(selectedImage!.path)),
        ),
      )
          : defaultContainer(imagePath);
    }else if(imagePath=="images/galary.png")
    {
      return selectGallary != null
          ? Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.yellow.shade700),
          borderRadius: BorderRadius.circular(20),
        ),
        width: 70,
        height: 70,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Image.file(File(selectGallary!.path)),
        ),
      )
          : defaultContainer(imagePath);
    }
    else if (imagePath == "images/video.png") {
      return selectedVideo != null
          ? Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.yellow.shade700),
          borderRadius: BorderRadius.circular(20),
        ),
        width: 70,
        height: 70,
        child:const Padding(
          padding:  EdgeInsets.all(12.0),
          child:  Icon(Icons.video_library, color: Colors.white),
        ),
      )
          : defaultContainer(imagePath);
    } else if (imagePath == "images/audio.png") {
      return selectedAudio != null
          ? Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.yellow.shade700),
          borderRadius: BorderRadius.circular(20),
        ),
        width: 70,
        height: 70,
        child:const Padding(
          padding:  EdgeInsets.all(12.0),
          child:  Icon(Icons.audiotrack, color: Colors.white),
        ),
      )
          : defaultContainer(imagePath);
    } else {
      return defaultContainer(imagePath);
    }
  }

  Widget defaultContainer(String imagePath) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.yellow.shade700),
        borderRadius: BorderRadius.circular(20),
      ),
      width: 70,
      height: 70,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Image.asset(imagePath),
      ),
    );
  }

  Future<void> _checkSmsPermission() async {
    if (await Permission.sms.isGranted) {
      // Permission is granted
    } else {
      var status = await Permission.sms.request();
      if (status.isGranted) {
        // Permission granted
      } else {
        // Permission denied
      }
    }
  }
}



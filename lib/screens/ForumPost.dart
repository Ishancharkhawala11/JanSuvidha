import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:safe_alert/Services.dart';
import 'package:safe_alert/Utils.dart';
import 'package:safe_alert/screens/ForumScreen.dart';

class Forumpost extends StatefulWidget {
  const Forumpost({super.key});

  @override
  State<Forumpost> createState() => _ForumpostState();
}

class _ForumpostState extends State<Forumpost> {
  var titleController = TextEditingController();
  var bodyController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {

    });
  }

  XFile? image;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title :Center(child: Text("Report an Incident",style: TextStyle(fontSize: 30,color: Colors.yellow.shade700,fontWeight: FontWeight.bold),),),

      ),
      body: Container(
        margin:const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              InkWell(
                onTap: (){
                    addPhoto();
                },
                  child: image==null ?  Image.asset("images/image_add.png",width: MediaQuery.of(context).size.width , height: MediaQuery.of(context).size.height / 3,)
                      : Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height/3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20)
                    ),
                      child: Image.file(File(image!.path)),),),
              const SizedBox(height: 10,),

              Center(child: Text("Title",style: TextStyle(fontSize: 18,color: Colors.yellow.shade700),)),
              const SizedBox(height: 10,),
              TextFormField(
                controller: titleController,
                cursorColor: Colors.yellow.shade700,
                decoration: InputDecoration(
                  hintText: "Title",
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
                maxLines: 1,
                style:const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20,),
              Center(child: Text("Write about incident",style: TextStyle(fontSize: 18,color: Colors.yellow.shade700),)),
              const SizedBox(height: 10,),
              TextFormField(
                controller: bodyController,
                cursorColor: Colors.yellow.shade700,
                decoration: InputDecoration(
                  hintText: "Write about incident",
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
                maxLines: 7,
                style:const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 30,),
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
                    if(titleController.text!="" && bodyController.text!="" && image!=null){
                      Utils.showdialog(context: context, msg: "Adding post...");
                      String imageUrl = await uploadImage(image!);
                      Services.addPostToFirebase(title: titleController.text, body: bodyController.text, image: imageUrl, date: DateTime.now().millisecondsSinceEpoch.toString()).then((val){
                        Utils.showSnackbar(context: context, msg: "Post added successfully!!");
                      });
                      Navigator.pop(context);
                      Utils.navigateWithSlideTransitionWithPushReplacement(context: context, screen:const Forumscreen(), begin: const Offset(1,0), end: Offset.zero);
                    }else{
                      Utils.showSnackbar(context: context, msg: "Please fill the field");
                    }
                  },
                  child: const Text(
                    "Add Post",
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
    );
  }



  Future<void> addPhoto() async{
    XFile? file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if(file!=null){
      setState(() {
        image = file;
      });
    }else{
      Utils.showSnackbar(context: context, msg: "Image not picked...");
    }

  }

  Future<String> uploadImage(XFile image) async {
    Reference storageRef = FirebaseStorage.instance
        .ref()
        .child("forums/images/${DateTime.now().millisecondsSinceEpoch}.jpg");
    UploadTask upload = storageRef.putFile(File(image.path));
    TaskSnapshot snapshot = await upload;
    return await snapshot.ref.getDownloadURL();
  }


}

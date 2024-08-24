import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:safe_alert/Services.dart';
import 'package:safe_alert/Utils.dart';
import 'package:safe_alert/screens/ForumPost.dart';

class Forumscreen extends StatefulWidget {
  const Forumscreen({super.key});

  @override
  State<Forumscreen> createState() => _ForumscreenState();
}

class _ForumscreenState extends State<Forumscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: InkWell(
          onTap: () {
            Utils.navigateWithSlideTransitionWithPush(
                context: context,
                screen: const Forumpost(),
                begin: const Offset(0, 1),
                end: Offset.zero);
          },
          child: CircleAvatar(
              backgroundColor: Colors.yellow.shade700,
              radius: 30,
              child:const Icon(
                Icons.add,
                color: Colors.black,
                size: 35,
              ))),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(
          child: Text(
            "All Reposts",
            style: TextStyle(
                fontSize: 30,
                color: Colors.yellow.shade700,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Container(
        padding:const EdgeInsets.all(10),
        child: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
          future: Services.getAllPosts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return buildSkeletonLoader(context);
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No posts available.',style: TextStyle(color: Colors.yellow.shade700),));
            } else {
              final posts = snapshot.data!.docs.reversed.toList();

              return ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index].data();
                  return Container(
                    margin:const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.yellow.shade700)
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 10,),
                        Container(
                          margin:const EdgeInsets.all(20),
                            
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                                child: Image.network(post["image"],width: MediaQuery.of(context).size.width , height: MediaQuery.of(context).size.height / 3.5,fit: BoxFit.cover,)),),
                        const SizedBox(width: 10,),
                        Container(
                          margin: EdgeInsets.only(left: 10,right: 10,bottom: 15),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(post["title"],style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.white),),
                              const SizedBox(height: 10,),
                              Text(post["body"],style: TextStyle(fontSize: 14,color: Colors.grey),),
                              const SizedBox(height: 10,),
                              Text(getDateAndTime(post["date"]),style: TextStyle(fontSize: 14,color: Colors.yellow.shade700),)
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  String getDateAndTime(String millisecondEpoch){
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(int.parse(millisecondEpoch));
    String formattedDateTime = DateFormat('dd-MM-yyyy hh:mm a').format(dateTime);

    return formattedDateTime;
  }

  Widget buildSkeletonLoader(BuildContext context) {
    return ListView.builder(
      itemCount: 5, // Display a few placeholders
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade700),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                margin: const EdgeInsets.all(20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 3.5,
                    color: Colors.grey.shade300, // Skeleton for the image
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                margin: const EdgeInsets.only(left: 10, right: 10, bottom: 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 20,
                      color: Colors.grey.shade300, // Skeleton for the title
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      height: 14,
                      color: Colors.grey.shade300, // Skeleton for the body
                    ),
                    const SizedBox(height: 5),
                    Container(
                      width: double.infinity,
                      height: 14,
                      color: Colors.grey.shade300, // Skeleton for the body
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

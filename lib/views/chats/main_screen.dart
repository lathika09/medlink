import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medlink/constant/image_string.dart';
import 'package:medlink/views/chats/api.dart';
import 'package:medlink/views/chats/user_chat.dart';

import '../patient/MainPage.dart';
import 'model/user.dart';

class MainChatScreen extends StatefulWidget {
  MainChatScreen({Key? key,required this.pemail}) : super(key: key);
 final String pemail;
  @override
  State<MainChatScreen> createState() => _MainChatScreenState();
}

class _MainChatScreenState extends State<MainChatScreen> {

  Future<String> getDoctorName(String doctorId) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    try {
      DocumentSnapshot doctorSnapshot = await _firestore
          .collection('doctor')
          .doc(doctorId)
          .get();

      if (doctorSnapshot.exists) {
        return doctorSnapshot.get('name') as String;
      } else {
        return ''; // Handle the case when the doctor document does not exist
      }
    } catch (e) {
      print('Error fetching doctor name: $e');
      return ''; // Handle the error as needed
    }
  }


  Future<List<UserCard>> fetchChatsForPatient(String patientId) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('chats')
          .where('participants.patientId', isEqualTo: patientId)
          .get();

      List<UserCard> chats = [];

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> chatData = doc.data() as Map<String, dynamic>;

        String chatId = doc.id;
        String doctorId = chatData['participants']['doctorId'] ?? '';
        String doctorName = await getDoctorName(doctorId);

        chats.add(UserCard(
          chatId: chatId,
          patientId: patientId,
          doctorId: doctorId,
          doctorName: doctorName,
          usermail: widget.pemail,
        ));
      }

      return chats;
    } catch (e) {
      print('Error fetching chats for patient: $e');
      return []; // Return an empty list or handle the error as needed.
    }
  }

  Map<String, dynamic> patientData = {};
  Future<void> fetchPatientData() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection("patients").where("email", isEqualTo: widget.pemail).get();
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          patientData = snapshot.docs.first.data() as Map<String, dynamic>;
          print(patientData['name']);
        });
      }
    } catch (e) {
      print("Error fetching doctor data: $e");
    }
  }

  // Future<void> updateDoctorFCMToken(String userEmail) async {
  //   FirebaseMessaging fMessaging = FirebaseMessaging.instance;
  //
  //   // Request permission for push notifications
  //   await fMessaging.requestPermission();
  //
  //   // Get the Firebase Messaging token
  //   String? fcmToken = await fMessaging.getToken();
  //
  //   if (fcmToken != null) {
  //     // Update the FCM token for the doctor identified by their email
  //     final CollectionReference Collection = FirebaseFirestore.instance.collection('patients');
  //
  //     // Update the FCM token for the doctor with the specified email
  //     await Collection
  //         .where('email', isEqualTo: userEmail)
  //         .get()
  //         .then((querySnapshot) {
  //       if (querySnapshot.docs.isNotEmpty) {
  //         final doctorDoc = querySnapshot.docs.first;
  //
  //         // Update the FCM token field in the doctor document
  //         doctorDoc.reference.update({'push_token': fcmToken}).then((_) {
  //           print('FCM Token updated for doctor with email $userEmail');
  //         }).catchError((error) {
  //           print('Error updating FCM token: $error');
  //         });
  //       } else {
  //         print('Doctor with email $userEmail not found');
  //       }
  //     }).catchError((error) {
  //       print('Error querying doctor: $error');
  //     });
  //   } else {
  //     print('Failed to get FCM token');
  //   }
  // }

  @override
  void initState() {
    super.initState();
    fetchPatientData();
    // updateDoctorFCMToken(widget.pemail);
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=>FocusScope.of(context).unfocus(),
      child: Scaffold(
          appBar: AppBar(
            backgroundColor:Colors.blueAccent.shade700,
            iconTheme: IconThemeData(
              color: Colors.white,
            ),
            leading: IconButton(
                onPressed: (){
                  // Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>MainPage(pemail: widget.pemail)),
                  );
                },
                icon: const Icon(
                  Icons.arrow_back,
                  size:20,
                  color: Colors.white,)
            ),

            title:Text(appname,
              style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),

          ),
          body: patientData['id'] != null
              ?Column(
            children: [
              FutureBuilder<List<UserCard>>(
                future: fetchChatsForPatient(patientData["id"]), // Replace patientId with the actual patient ID
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    List<UserCard> userCards = snapshot.data ?? [];

                    return ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: userCards.length,
                      itemBuilder: (context, index) {
                        return userCards[index];// Render each userCard widget here.
                      },
                    );
                  }
                },
              ),
            ],
          )
              :Container(),

      ),
    );
  }
}

//
// class MainChatScreen extends StatefulWidget {
//   const MainChatScreen({Key? key,required this.email}) : super(key: key);
// final String email;
//   @override
//   State<MainChatScreen> createState() => _MainChatScreenState();
// }
//
// class _MainChatScreenState extends State<MainChatScreen> {
//   List<ChatUser> list=[];
//   final List<ChatUser> searchList=[];
//   bool isSearching=false;
//
//   @override
//   Widget build(BuildContext context) {
    // return GestureDetector(
    //   onTap: ()=>FocusScope.of(context).unfocus(),
    //   child: Scaffold(
    //     appBar: AppBar(
    //       backgroundColor:Colors.blueAccent.shade700,
    //       iconTheme: IconThemeData(
    //         color: Colors.white,
    //       ),
    //       leading: IconButton(
    //           onPressed: (){
    //             // Navigator.pop(context);
    //             Navigator.push(
    //               context,
    //               MaterialPageRoute(builder: (context) =>MainPage(pemail: widget.email)),
    //             );
    //             },
    //           icon: const Icon(
    //             Icons.arrow_back,
    //             size:20,
    //             color: Colors.white,)
    //       ),
    //
    //       title:Center(
    //         child: isSearching?
    //             TextField(
    //               decoration: InputDecoration(
    //                 border: InputBorder.none,hintText: 'Name'
    //               ),
    //               autofocus: true,
    //               style: TextStyle(fontSize: 17,letterSpacing: 0.5),
    //               onChanged: (val){
    //                 //searcj
    //                 searchList.clear();
    //                 for (var i in list){
    //                   if(i.name.toLowerCase().contains(val.toLowerCase())){
    //                     searchList.add(i);
    //                     setState(() {
    //                       searchList;
    //                       // String? docId = await APIs.getDocIdByEmail('johndoe@example.com');
    //                       // print("id :   ${}")
    //                     });
    //                   }
    //
    //                 }
    //               },
    //             )
    //             :Text("MediWise",
    //           style: TextStyle(
    //               fontSize: 30,
    //               color: Colors.white,
    //               fontWeight: FontWeight.bold),
    //         ),
    //       ),
    //       elevation: 24.0,
    //       actions: <Widget>[
    //         IconButton(//search
    //           icon: Icon(isSearching?Icons.clear_rounded: Icons.search,
    //             size: 30,
    //             color: Colors.white,
    //           ),
    //           onPressed: () {
    //             setState(() {
    //               isSearching=!isSearching;
    //             });
    //           },
    //         ),
    //       ],
    //     ),
    //     body:StreamBuilder(
    //         stream: APIs.firestore.collection("doctor").snapshots(),
    //         builder: (context,snapshot){
    //           switch (snapshot.connectionState){
    //             case ConnectionState.waiting:
    //             case ConnectionState.none:
    //               return const Center(child: CircularProgressIndicator(),);
    //             case ConnectionState.active:
    //               case ConnectionState.done:
    //             final data=snapshot.data?.docs;
    //             list=data?.map((e) => ChatUser.fromJson(e.data())).toList()??[];
    //             // log("CURRENT USER : ${APIs.user.uid}");
    //             if(list.isNotEmpty){
    //               return ListView.builder(
    //                   itemCount:isSearching ? searchList.length : list.length,
    //                   physics:BouncingScrollPhysics(),
    //                   padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.01),
    //                   itemBuilder: (context,index){
    //                     return UserCard(doctor_user:isSearching ? searchList[index] : list[index],);
    //
    //                   });
    //             }
    //             else{
    //               return const Center(
    //                 child: Text("No Connection Found !!",style: TextStyle(fontSize: 20),),
    //               );
    //             }
    //
    //
    //
    //           }
    //
    //
    //     })
    //   ),
    // );
//   }
// }

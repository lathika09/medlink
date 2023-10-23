import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../constant/image_string.dart';
import '../../chats/user_chat.dart';
import '../../patient/MainPage.dart';
import 'home_doc.dart';

class MainChatScreenDoc extends StatefulWidget {
  MainChatScreenDoc({Key? key, required this.email}) : super(key: key);
  final String email;
  @override
  State<MainChatScreenDoc> createState() => _MainChatScreenDocState();
}

class _MainChatScreenDocState extends State<MainChatScreenDoc> {

  Future<String> getPatientName(String patientId) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    try {
      DocumentSnapshot patientSnapshot = await _firestore
          .collection('patients')
          .doc(patientId)
          .get();

      if (patientSnapshot.exists) {
        return patientSnapshot.get('name') as String;
      } else {
        return ''; // Handle the case when the patient document does not exist
      }
    } catch (e) {
      print('Error fetching patient name: $e');
      return ''; // Handle the error as needed
    }
  }


  Future<List<UserCard>> fetchChatsForDoctor(String doctorId) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('chats')
          .where('participants.doctorId', isEqualTo: doctorId)
          .get();

      List<UserCard> chats = [];

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> chatData = doc.data() as Map<String, dynamic>;

        String chatId = doc.id;
        String patientId = chatData['participants']['patientId'] ?? '';
        String pName = await getPatientName(patientId);
        // You can also fetch patient name using a similar approach as with doctors

        chats.add(UserCard(
          chatId: chatId,
          doctorId: doctorId,
          patientId: patientId,
          doctorName: pName,
          usermail: widget.email,
          // Other properties for UserCard
        ));
      }

      return chats;
    } catch (e) {
      print('Error fetching chats for doctor: $e');
      return []; // Return an empty list or handle the error as needed.
    }
  }

  Map<String, dynamic> doctorData = {};
  Future<void> fetchDoctorData() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection("doctor").where("email", isEqualTo: widget.email).get();
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          doctorData = snapshot.docs.first.data() as Map<String, dynamic>;
          print(doctorData['name']);
          print("PRINT THIS : ${doctorData['id']}");
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
  //     final CollectionReference doctorsCollection = FirebaseFirestore.instance.collection('doctor');
  //
  //     // Update the FCM token for the doctor with the specified email
  //     await doctorsCollection
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

  // Future<void> updateActiveStatus(String email, bool isOnline) async {
  //   QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
  //       .collection("doctor")
  //       .where('email', isEqualTo: email)
  //       .get();
  //   if (snapshot.docs.isNotEmpty) {
  //     final userRef = snapshot.docs.first.reference;
  //
  //     await userRef.update({
  //       'is_online': isOnline,
  //       'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
  //     });
  //     print("Data updated");
  //   } else {
  //     print("User not found");
  //   }
  // }
  @override
  void initState() {
    super.initState();
    fetchDoctorData();
    // updateDoctorFCMToken(widget.email);

    // SystemChannels.lifecycle.setMessageHandler((message) {
    //   log('Message: $message');
    //
    //   if (widget.email != null) {
    //     if (message.toString().contains('resume')) {
    //       updateActiveStatus(widget.email, true);
    //     }
    //     if (message.toString().contains('pause')) {
    //       updateActiveStatus(widget.email, false);
    //     }
    //   }
    //
    //   return Future.value(message);
    // });
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
                    MaterialPageRoute(builder: (context) =>HomePage_doc(email: widget.email)),
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
          body: doctorData['id'] != null
              ? Column(
            children: [
              FutureBuilder<List<UserCard>>(
                future: fetchChatsForDoctor(doctorData['id']),
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
                        return userCards[index];
                      },
                    );
                  }
                },
              ),
            ],
          )
              : Container(),


      ),
    );
  }
}

import 'dart:typed_data';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:medlink/constant/image_string.dart';
import 'package:medlink/constant/utils.dart';
import 'package:medlink/views/doctor/login_doc.dart';
import 'package:medlink/views/doctor/screens/home_doc.dart';
import 'package:medlink/views/doctor/screens/update_prof.dart';
import 'package:medlink/views/prescript/mainPrescript.dart';

import '../../chats/chat_screen.dart';
import 'main_chat_screen_doc.dart';

class PatientListPage extends StatefulWidget {
  const PatientListPage({Key? key, required this.dEmail}) : super(key: key);
final String dEmail;
  @override
  State<PatientListPage> createState() => _PatientListPageState();
}

class _PatientListPageState extends State<PatientListPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<PatientData>> fetchPatientsForDoctor(String doctorId) async {
    try {
      // Reference the doctor's subcollection of patients
      CollectionReference doctorPatientsCollection = _firestore.collection('doctor/$doctorId/patients');

      QuerySnapshot querySnapshot = await doctorPatientsCollection.get();

      List<PatientData> patients = querySnapshot.docs.map((doc) {
        Map<String, dynamic> patientData = doc.data() as Map<String, dynamic>;

        // Access fields from the document with null checks
        String id = (patientData['id'] is String) ? patientData['id'] : '';
        String name = (patientData['name'] is String) ? patientData['name'] : '';
        String email = (patientData['email'] is String) ? patientData['email'] : '';
        // Add more fields as needed

        return PatientData(
          id: id,
          name: name,
          email: email,
          docEmail: widget.dEmail,
          // Add more fields here to match your PatientData class.
        );
      }).toList();

      return patients;
    } catch (e) {
      print('Error fetching patients: $e');
      return []; // Return an empty list or handle the error as needed.
    }
  }
  Map<String, dynamic> doctorData = {};
  Future<void> fetchDoctorData() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection("doctor").where("email", isEqualTo: widget.dEmail).get();
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

  @override
  void initState() {
    super.initState();
    fetchDoctorData();
  }
  TextEditingController search_name = TextEditingController();
  String searchText='';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        backgroundColor:Colors.blueAccent.shade700,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title:Center(
          child: Text(appname,
            style: TextStyle(
                fontSize: 30,
                color: Colors.white,
                fontWeight: FontWeight.bold),
          ),
        ),
          elevation: 24.0,
          actions: <Widget>[IconButton(
            icon: Icon(Icons.refresh,size: 30,color: Colors.blueAccent.shade700,),
            onPressed: () {
              // Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateProfile()),);
            },
          ),]

      ),
      body:
      SafeArea(
          child: SingleChildScrollView(
            child: Container(
              child:
              Column(
                children: [
                  Container(
                      margin: EdgeInsets.symmetric(vertical: 10.0,horizontal: 15.0),
                      // padding: EdgeInsets.symmetric(vertical: 2.0,horizontal: 20.0),
                      child:  TextField(

                        style:const TextStyle(fontSize: 19.0,fontWeight: FontWeight.w600,color: Colors.black),
                        controller: search_name,
                        onChanged: (value){
                          setState(() {
                            searchText=value;

                          });
                        },
                        decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(vertical: 5.0,horizontal: 20.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide:const BorderSide(width: 0.8),
                            ),
                            hintText: "Search by Patient Name",
                            // prefixIcon:const Icon(Icons.search,size:20.0,),
                            suffixIcon: IconButton(onPressed: (){}, icon:const Icon(Icons.search,size: 20.0,))
                        ),
                      ),
                  ),
                  if (doctorData['id'] != null)
                  FutureBuilder<List<PatientData>>(
                    future: fetchPatientsForDoctor(doctorData['id']!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return  Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        List<PatientData> patients = snapshot.data ?? [];
                        patients = patients.where((patient) {

                          bool nameMatches = searchText.isEmpty ||
                              patient.name.toLowerCase().contains(searchText.toLowerCase());
                          return nameMatches;
                        }).toList();

                        return ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: patients.length,
                          itemBuilder: (context, index) {
                            return patients[index];
                          },

                        );
                      }
                    },
                  ),
                ],
              )
            ),

      )),
    );
  }
}



class PatientData extends StatefulWidget {
  const PatientData({Key? key, required this.id, required this.name, required this.email, required this.docEmail}) : super(key: key);
  final String id;
  final String name;

  final String email;

  final String docEmail;

  @override
  State<PatientData> createState() => _PatientDataState();
}

class _PatientDataState extends State<PatientData> {
  Future<String?> createChat(String patientId, String doctorId) async {
    try {
      QuerySnapshot existingChats = await FirebaseFirestore.instance.collection('chats')
          .where('participants.patientId', isEqualTo: patientId)
          .where('participants.doctorId', isEqualTo: doctorId)
          .get();

      if (existingChats.docs.isNotEmpty) {
        String existingChatId = existingChats.docs[0].id;
        return existingChatId;
      }
      else {
        Map<String, dynamic> chatData = {
          'participants': {
            'patientId': patientId,
            'doctorId': doctorId,
          },
          'created_at': FieldValue.serverTimestamp(),
        };

        DocumentReference docRef = await FirebaseFirestore.instance.collection('chats').add(chatData);
        String docId = docRef.id;
        await docRef.update({'id': docId});

        return docId;
      }
    } catch (e) {
      print('Error creating or checking chat document: $e');
      return null; // Return null to indicate an error
    }
  }



  Map<String, dynamic> patientData = {};
  Future<void> fetchPatientData() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection("patients").where("email", isEqualTo: widget.email).get();
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
  Map<String, dynamic> doctorData = {};
  Future<void> fetchDoctorData() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection("doctor").where("email", isEqualTo: widget.docEmail).get();
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

  @override
  void initState() {
    super.initState();
    fetchDoctorData();
    fetchPatientData();
  }
  final color1 = Colors.white;
  final color2 = Colors.greenAccent.shade400;
  final ratio = 0.5;
  get mixednewColor => Color.lerp(color1, color2, ratio);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 13),
      // height: 210,
      child: GestureDetector(
        child: Card(
          elevation: 5,
          color: Colors.greenAccent,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                          left: 10, right: 10, bottom: 10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: Container(
                          height: MediaQuery.of(context).size.width*0.15,
                          width: MediaQuery.of(context).size.width*0.15,
                          color:Colors.transparent,
                          child:CircleAvatar(
                            backgroundColor: Colors.blue,
                            radius:MediaQuery.of(context).size.width*0.09,//60
                            child:Icon(Icons.person,color:Colors.white,size: MediaQuery.of(context).size.width*0.09,),
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding:
                        EdgeInsets.symmetric(horizontal: 5, vertical: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width:
                                  MediaQuery.of(context).size.width *
                                      0.4,
                                  child: Text(
                                    widget.name,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    softWrap: true,
                                  ),
                                ),

                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal:18.0),
                      child: MaterialButton(
                        onPressed: ()async {
                          String? chatId = await createChat(patientData['id'],doctorData['id']);
                          if (chatId != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  chat_id: chatId,
                                  doc_id: doctorData['id'],
                                  pat_id: patientData['id'],
                                  userId: doctorData['id'],
                                  Name: patientData['name'],
                                ),
                              ),
                            );
                          }

                          // Navigator.push(context,
                          //     MaterialPageRoute(builder:
                          //         (context)=>ChatScreen(chat_id:chatId!,doc_id:doctorData['id'],pat_id:patientData['id'])
                          // ));

                        },
                        child: Icon(
                          Icons.chat,
                          color: Colors.white,
                          size: 30,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        color: Colors.blue,
                        minWidth: MediaQuery.of(context).size.width/6,
                      ),
                    ),
                  ],
                ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                //   children: [
                //     MaterialButton(
                //       onPressed: ()async {
                //         String? chatId = await createChat(patientData['id'],doctorData['id']);
                //         if (chatId != null) {
                //           Navigator.push(
                //             context,
                //             MaterialPageRoute(
                //               builder: (context) => ChatScreen(
                //                 chat_id: chatId,
                //                 doc_id: doctorData['id'],
                //                 pat_id: patientData['id'],
                //                 userId: patientData['id'], Name: doctorData['name'],
                //               ),
                //             ),
                //           );
                //         }
                //
                //         // Navigator.push(context,
                //         //     MaterialPageRoute(builder:
                //         //         (context)=>ChatScreen(chat_id:chatId!,doc_id:doctorData['id'],pat_id:patientData['id'])
                //         // ));
                //
                //       },
                //       child: Icon(
                //         Icons.chat,
                //         color: Colors.white,
                //         size: 30,
                //       ),
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(12.0),
                //       ),
                //       color: Colors.blueAccent.shade700,
                //       minWidth: MediaQuery.of(context).size.width/6,
                //     ),
                //
                //   ],
                // ),
              ],
            ),
          ),
        ),
        onTap: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MainPrescript(patientEmail: widget.email, doctorId: doctorData['id'], doctorEmail: widget.docEmail)
            ),
          );
          // String? chatId = await createChat(patientData['id'],doctorData['id']);
          // if (chatId != null) {
          //   Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //       builder: (context) => ChatScreen(
          //         chat_id: chatId,
          //         doc_id: doctorData['id'],
          //         pat_id: patientData['id'],
          //         userId: doctorData['id'],
          //         Name: patientData['name'],
          //       ),
          //     ),
          //   );
          // }
        },
      ),
    );
  }
}


// class PatientListPage extends StatefulWidget {
//   const PatientListPage({Key? key}) : super(key: key);
//
//   @override
//   State<PatientListPage> createState() => _PatientListPageState();
// }
//
// class _PatientListPageState extends State<PatientListPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   Future<List<PatientData>> fetchDoctors() async {
//     try {
//       QuerySnapshot querySnapshot = await _firestore.collection('doctor').get();
//
//       List<PatientData> doctors = querySnapshot.docs.map((doc) {
//         Map<String, dynamic> doctorData = doc.data() as Map<String, dynamic>;
//
//         // to access the availability field so default ytakrn
//         Map<String, dynamic> availability = doctorData['availability'] ?? {
//           'weekday': '',
//           'time': '',
//         };
//
//         List<dynamic> weekdays =
//         availability['weekday'] is List ? List<dynamic>.from(availability['weekday']) : [];
//         List<dynamic> time =
//         availability['time'] is List ? List<dynamic>.from(availability['time']) : [];
//
//         // to access fields from the document with null checks
//         String id = (doctorData['id'] is String) ? doctorData['id'] : '';
//
//         String name = (doctorData['name'] is String) ? doctorData['name'] : '';
//         List<String> speciality = (doctorData['speciality'] is List) ? List<String>.from(doctorData['speciality']) : [];
//         String qualification = (doctorData['qualification'] is String) ? doctorData['qualification'] : '';
//         String hospital = (doctorData['hospital'] is String) ? doctorData['hospital'] : '';
//         String address = (doctorData['address'] is String) ? doctorData['address'] : '';
//         String experience = (doctorData['experience'] is String) ? doctorData['experience'] : '';
//         String description = (doctorData['description'] is String) ? doctorData['description'] : '';
//         String email = (doctorData['email'] is String) ? doctorData['email'] : '';
//         String city = (doctorData['city'] is String) ? doctorData['city'] : '';
//         String pemail =(patientData['email'] is String) ? patientData['email'] : '';
//         //  availability map in doc
//         Map<String, dynamic> doctorAvailability = {
//           'weekday': weekdays,
//           'time': time,
//         };
//
//         return DoctorData(
//           route: 'doc_details',
//           id:id,
//           name: name,
//           speciality: speciality,
//           qualification: qualification,
//           hospital: hospital,
//           address: address,
//           experience: experience,
//           description: description,
//           availability: doctorAvailability,
//           email:email,
//           city: city,
//           pemail:pemail,
//         );
//       }).toList();
//
//       return doctors;
//     } catch (e) {
//       print('Error fetching doctors: $e');
//       return []; // Return an empty list or handle the error as needed.
//     }
//   }
//   @override
//   Widget build(BuildContext context) {
//     return const Placeholder();
//   }
// }
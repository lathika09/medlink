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

class PatientListPage extends StatefulWidget {
  const PatientListPage({Key? key}) : super(key: key);

  @override
  State<PatientListPage> createState() => _PatientListPageState();
}

class _PatientListPageState extends State<PatientListPage> {


  @override
  void initState() {
    super.initState();
  }

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
      body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              child:
              Column(
                children: [
                  FutureBuilder<List<PatientData>>(
                    future: null,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        // List<DoctorData> doctors = snapshot.data ?? [];

                        return ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          // itemCount: doctors.length,
                          // itemBuilder: (context, index) {
                          //   return doctors[index];
                          // },
                          itemCount: 6,
                          itemBuilder: (context, index) {

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
  const PatientData({Key? key, required this.id, required this.phoneNumber, required this.name, required this.lastActive, required this.isOnline, required this.email, required this.pushToken}) : super(key: key);
  final String id;
  final String phoneNumber;
  final String name;

  final String lastActive;
  final bool isOnline;
  final String email;
  final String pushToken;

  @override
  State<PatientData> createState() => _PatientDataState();
}

class _PatientDataState extends State<PatientData> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
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
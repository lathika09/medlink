import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:medlink/constant/image_string.dart';
import 'package:medlink/views/doctor/login_doc.dart';
import 'package:medlink/views/doctor/screens/home_doc.dart';
final usersCollection = FirebaseFirestore.instance.collection('doctor');
void fetchUserData(String userEmail) async {
  final snapshot = await usersCollection.where('email', isEqualTo: userEmail).get();
  if (snapshot.docs.isNotEmpty) {
    final userData = snapshot.docs.first.data();
    // Pass `userData` to the home screen for displaying data

    print("done ${userData}");
  } else {

  }
}
void fetchDoctorData() async {
  final String doctorId = 'your_doctor_id'; // Replace with the actual document ID or path
  final DocumentReference doctorReference = FirebaseFirestore.instance.collection('doctors').doc(doctorId);

  try {
    final DocumentSnapshot doctorSnapshot = await doctorReference.get();

    if (doctorSnapshot.exists) {
      final Map<String, dynamic> doctorData = doctorSnapshot.data() as Map<String, dynamic>;
      // Now you have the doctor's data in the doctorData map

      // You can access the fields like this:
      final String doctorName = doctorData['name'];
      final String doctorSpecialty = doctorData['specialty'];
      // Add similar lines for other fields

      // Use the doctor data as needed
    } else {
      // Handle the case where the document doesn't exist
      print('Doctor document does not exist.');
    }
  } catch (e) {
    // Handle any errors that occur during the fetch process
    print('Error fetching doctor data: $e');
  }
}

class ProfileSetting extends StatefulWidget {
  const ProfileSetting({Key? key}) : super(key: key);

  @override
  State<ProfileSetting> createState() => _ProfileSettingState();

}

class _ProfileSettingState extends State<ProfileSetting> {
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String? email = args?['email'] as String?;

    if (args != null) {
      print(args);
      final usersCollection = FirebaseFirestore.instance.collection('doctor');
      void fetchUserData(String userEmail) async {
        final snapshot = await usersCollection.where('email', isEqualTo: userEmail).get();
        if (snapshot.docs.isNotEmpty) {
          final userData = snapshot.docs.first.data();
          // Pass `userData` to the home screen for displaying data

          print("done ${userData['name']}");
        } else {

        }
      }
      fetchUserData(email!);

    }

    return Scaffold(
        body:SingleChildScrollView(
          child: Column(
            children: [

              Image.asset(SplashAbove,width:MediaQuery.of(context).size.width ),

              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 64,
                          backgroundImage:NetworkImage("https://shop.phuongdonghuyenbi.vn/wp-content/uploads/avatars/520/default-avatar-bpthumb.png"),
                        )
                      ],
                    )
                  ],
                ),
              )



            ],
          ),
        )
    );
  }

}
// void fetchDoctorData() async {
//   final String doctorId = 'your_doctor_id'; // Replace with the actual document ID or path
//   final DocumentReference doctorReference = FirebaseFirestore.instance.collection('doctor').doc(doctorId);
//
//   try {
//     final DocumentSnapshot doctorSnapshot = await doctorReference.get();
//
//     if (doctorSnapshot.exists) {
//       final Map<String, dynamic> doctorData = doctorSnapshot.data() as Map<String, dynamic>;
//       // Now you have the doctor's data in the doctorData map
//
//       // You can access the fields like this:
//       final String doctorName = doctorData['name'];
//       final String doctorSpecialty = doctorData['specialty'];
//       // Add similar lines for other fields
//
//       // Use the doctor data as needed
//     } else {
//       // Handle the case where the document doesn't exist
//       print('Doctor document does not exist.');
//     }
//   } catch (e) {
//     // Handle any errors that occur during the fetch process
//     print('Error fetching doctor data: $e');
//   }
// }

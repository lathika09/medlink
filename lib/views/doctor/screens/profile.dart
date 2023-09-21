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

  Uint8List? image;

  void selectedImage() async {
    Uint8List img = await pickImage(ImageSource.gallery);
    if (img != null) {
      // Convert the image data to a base64-encoded string
      String base64Image = base64Encode(img);

      // Update the user's document in Firestore with the image
      final Map<String, dynamic>? args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final String? email = args?['email'] as String?;

      if (email != null) {
        // final userDoc = FirebaseFirestore.instance.collection('doctor').doc(email);
        // final docSnapshot = await userDoc.get();
        final snapshot = await usersCollection.where('email', isEqualTo: email).get();
        if (snapshot.docs.isNotEmpty) {
          final docSnapshot = snapshot.docs.first;
          final docData =docSnapshot.data()as Map<String, dynamic>;
          try {
            print(docData);
            docData['prof_image']=base64Image;
            await docSnapshot.reference.update(docData);
            print('Document updated successfully.');


            // Update the UI to display the selected image
            setState(() {
              image = img;
            });
          } catch (error) {
            print('Error updating profile image: $error');
            // Handle the error as needed
          }

          print("done ${docSnapshot}");
        } else {
          print('Document does not exist.');

        }



      }
    }
  }

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

          print("done ${userData}");
        } else {

        }
      }
      fetchUserData(email!);

    }

    return Scaffold(
        appBar:AppBar(
          backgroundColor:Colors.blueAccent.shade700,
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
          title:Center(
            child: Text("MediWise",
              style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
          elevation: 24.0,
          actions: <Widget>[IconButton(
            icon: Icon(Icons.edit,size: 30,color: Colors.white,),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateProfile()),);
            },
          ),
          ],
        ),
        body:SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 20,),
              Center(
                child: Stack(
                  // alignment: AlignmentDirectional.topStart,
                  // fit: StackFit.expand,
                  children: [
                    image!=null?CircleAvatar(
                        radius: 60,
                        backgroundImage:MemoryImage(image!),
                    ):

                    CircleAvatar(
                      radius: 60,
                      backgroundImage:NetworkImage("https://www.pngitem.com/pimgs/m/421-4212266_transparent-default-avatar-png-default-avatar-images-png.png"),
                    ),
                    Positioned(
                        child: IconButton(
                            onPressed: selectedImage,
                            icon: Icon(Icons.add_a_photo),
                          iconSize: 30,
                          color: Colors.black,
                        ),
                      bottom: -1,
                      left: 80,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10,),
              Container(
                width: MediaQuery.of(context).size.width/1.05,
                // height: ,
                padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 18.0),
                decoration: BoxDecoration(
                  color:Colors.greenAccent,
                  borderRadius: BorderRadius.circular(30.0),    // Bottom-left corner

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3), // Shadow color
                      spreadRadius: 3, // Spread radius
                      blurRadius: 5, // Blur radius
                      offset: Offset(0, 20), // Offset of the shadow
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Name : ",
                      style: TextStyle(color: Colors.black,fontSize: 21,fontWeight: FontWeight.w600),
                    ),
                  ],
                ),

              )




            ],
          ),
        )
    );
  }

}

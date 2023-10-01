import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medlink/constant/image_string.dart';
import 'package:medlink/views/patient/home.dart';

import 'fetchDoc.dart';




class SpecialityList extends StatefulWidget {
  const SpecialityList({Key? key,required this.pemail,required this.category}) : super(key: key);
final String pemail;
  final String category;
  @override
  State<SpecialityList> createState() => _SpecialityListState();
}

class _SpecialityListState extends State<SpecialityList> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<int> getDoctorCount() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('doctor').get();
      return querySnapshot.docs.length;
    } catch (e) {
      print('Error fetching doctor count: $e');
      return 0; // Handle the error as needed.
    }
  }
  Future<List<DoctorData>> fetchDoctors(String? specCategory) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('doctor').get();

      List<DoctorData> doctors = querySnapshot.docs
          .map((doc) {
        Map<String, dynamic> doctorData = doc.data() as Map<String, dynamic>;

        // Access the availability field
        Map<String, dynamic> availability = doctorData['availability'] ?? {
          'weekday': [],
          'time': 0, // Assuming a default time of 0 if not specified
        };

        // Extract 'weekday' and 'time' from the availability map
        List<dynamic> weekdays = List<dynamic>.from(availability['weekday'] ?? []);
        int time = availability['time'] ?? 0;

        // Access fields from the document with null checks
        String name = (doctorData['name'] is String) ? doctorData['name'] : '';
        List<String> speciality = (doctorData['speciality'] is List) ? List<String>.from(doctorData['speciality']) : [];
        String qualification = (doctorData['qualification'] is String) ? doctorData['qualification'] : '';
        String hospital = (doctorData['hospital'] is String) ? doctorData['hospital'] : '';
        String address = (doctorData['address'] is String) ? doctorData['address'] : '';
        String experience = (doctorData['experience'] is String) ? doctorData['experience'] : '';
        String description = (doctorData['description'] is String) ? doctorData['description'] : '';
        String email = (doctorData['email'] is String) ? doctorData['email'] : '';
        String city = (doctorData['city'] is String) ? doctorData['city'] : '';

        // Create the availability map here
        Map<String, dynamic> doctorAvailability = {
          'weekday': weekdays,
          'time': time,
        };

        return DoctorData(
          route: 'doc_details',
          name: name,
          speciality: speciality,
          qualification: qualification,
          hospital: hospital,
          address: address,
          experience: experience,
          description: description,
          availability: doctorAvailability,
          email: email,
          city: city,
            pemail: widget.pemail
        );
      })
          .where((doctor) => doctor.speciality.contains(specCategory))
          .toList();

      return doctors;
    } catch (e) {
      print('Error fetching doctors: $e');
      return [];
    }
  }



//dropdoen city4
  Future<List<DoctorData>> fetchDoctorsbyBoth(String? citydrp, String? specCategory) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('doctor').get();

      List<DoctorData> doctors = querySnapshot.docs
          .map((doc) {
        Map<String, dynamic> doctorData = doc.data() as Map<String, dynamic>;

        // Access the availability field
        Map<String, dynamic> availability = doctorData['availability'] ?? {
          'weekday': [],
          'time': 0, // Assuming a default time of 0 if not specified
        };

        // Extract 'weekday' and 'time' from the availability map
        List<dynamic> weekdays = List<dynamic>.from(availability['weekday'] ?? []);
        int time = availability['time'] ?? 0;

        // Access fields from the document with null checks
        String name = (doctorData['name'] is String) ? doctorData['name'] : '';
        List<String> speciality = (doctorData['speciality'] is List) ? List<String>.from(doctorData['speciality']) : [];
        String qualification = (doctorData['qualification'] is String) ? doctorData['qualification'] : '';
        String hospital = (doctorData['hospital'] is String) ? doctorData['hospital'] : '';
        String address = (doctorData['address'] is String) ? doctorData['address'] : '';
        String experience = (doctorData['experience'] is String) ? doctorData['experience'] : '';
        String description = (doctorData['description'] is String) ? doctorData['description'] : '';
        String email = (doctorData['email'] is String) ? doctorData['email'] : '';
        String city=(doctorData['city'] is String) ? doctorData['city'] : '';

        // Create the availability map here
        Map<String, dynamic> doctorAvailability = {
          'weekday': weekdays,
          'time': time,
        };

        return DoctorData(
          route: 'doc_details',
          name: name,
          speciality: speciality,
          qualification: qualification,
          hospital: hospital,
          address: address,
          experience: experience,
          description: description,
          availability: doctorAvailability,
          email: email,
          city: city,
          pemail: widget.pemail,
        );
      })
          .where((doctor) {
        if (citydrp != null && citydrp.isNotEmpty) {
          // Check both city and spec_category if the city is selected
          return doctor.speciality.contains(specCategory) && doctor.city.contains(citydrp);
        } else {
          // Check only spec_category if the city is not selected
          return doctor.speciality.contains(specCategory);
        }
      })
          .toList();

      return doctors;
    } catch (e) {
      print('Error fetching doctors: $e');
      return [];
    }
  }


  String? valueChoose;
  List listItem=[
    "Mumbai","Delhi","Pune","Chennai"
  ];
  TextEditingController search_name = TextEditingController();
  String searchText='';



  @override
  Widget build(BuildContext context) {
    print(widget.pemail);
    return Scaffold(
      appBar: AppBar(
        backgroundColor:Colors.blueAccent.shade700,
        iconTheme: IconThemeData(
          color: Colors.white, // Change the color to your desired color
        ),
        title:Container(
          // width:260,
          width: MediaQuery.of(context).size.width/2,
          // decoration: BoxDecoration(border: Border.all(color:Colors.black,width: 1.0,),borderRadius: BorderRadius.circular(10.0)),
          height:40,
          padding: EdgeInsets.all(3.0),
          child: Center(
            child: Text(widget.category!,
              style: TextStyle(
                  fontSize: 25,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              child: Column(
                children: [

                  SizedBox(height: 10.0,),
                  //list of DOCTOR
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FutureBuilder<List<DoctorData>>(
                        future: fetchDoctors(widget.category),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator()); // Display a loading indicator while fetching data.
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            List<DoctorData> doctors = snapshot.data ?? [];
                            if (doctors.isEmpty) {
                              return Container(child: Center(child: Text('No matching doctors found.')));
                            }


                            return ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: doctors.length,
                              itemBuilder: (context, index) {
                                return doctors[index];
                              },
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20,),
                ],

              ),
            ),

          )),
    );
  }
}




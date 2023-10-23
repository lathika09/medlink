import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:medlink/views/patient/home.dart';

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
      return 0;
    }
  }
  Future<List<DoctorData>> fetchDoctors(String? specCategory) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('doctor').get();

      List<DoctorData> doctors = querySnapshot.docs
          .map((doc) {
        Map<String, dynamic> doctorData = doc.data() as Map<String, dynamic>;

        Map<String, dynamic> availability = doctorData['availability'] ?? {
          'weekday': '',
          'time': '',
        };

        // weekday and time' from the availability map
        List<dynamic> weekdays =
        availability['weekday'] is List ? List<dynamic>.from(availability['weekday']) : [];
        List<dynamic> time =
        availability['time'] is List ? List<dynamic>.from(availability['time']) : [];
        String id = (doctorData['id'] is String) ? doctorData['id'] : '';

        String name = (doctorData['name'] is String) ? doctorData['name'] : '';
        List<String> speciality = (doctorData['speciality'] is List) ? List<String>.from(doctorData['speciality']) : [];
        String qualification = (doctorData['qualification'] is String) ? doctorData['qualification'] : '';
        String hospital = (doctorData['hospital'] is String) ? doctorData['hospital'] : '';
        String address = (doctorData['address'] is String) ? doctorData['address'] : '';
        String experience = (doctorData['experience'] is String) ? doctorData['experience'] : '';
        String description = (doctorData['description'] is String) ? doctorData['description'] : '';
        String email = (doctorData['email'] is String) ? doctorData['email'] : '';
        String city = (doctorData['city'] is String) ? doctorData['city'] : '';

        //  availability map
        Map<String, dynamic> doctorAvailability = {
          'weekday': weekdays,
          'time': time,
        };

        return DoctorData(
          route: 'doc_details',
          id: id,
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

        // access availability field
        Map<String, dynamic> availability = doctorData['availability'] ?? {
          'weekday': '',
          'time': '',
        };

        List<dynamic> weekdays =
        availability['weekday'] is List ? List<dynamic>.from(availability['weekday']) : [];
        List<dynamic> time =
        availability['time'] is List ? List<dynamic>.from(availability['time']) : [];
        String id = (doctorData['id'] is String) ? doctorData['id'] : '';

        String name = (doctorData['name'] is String) ? doctorData['name'] : '';
        List<String> speciality = (doctorData['speciality'] is List) ? List<String>.from(doctorData['speciality']) : [];
        String qualification = (doctorData['qualification'] is String) ? doctorData['qualification'] : '';
        String hospital = (doctorData['hospital'] is String) ? doctorData['hospital'] : '';
        String address = (doctorData['address'] is String) ? doctorData['address'] : '';
        String experience = (doctorData['experience'] is String) ? doctorData['experience'] : '';
        String description = (doctorData['description'] is String) ? doctorData['description'] : '';
        String email = (doctorData['email'] is String) ? doctorData['email'] : '';
        String city=(doctorData['city'] is String) ? doctorData['city'] : '';

        // availability map
        Map<String, dynamic> doctorAvailability = {
          'weekday': weekdays,
          'time': time,
        };

        return DoctorData(
          route: 'doc_details',
          id: id,
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
          // check both city and spec_category if the city is selected
          return doctor.speciality.contains(specCategory) && doctor.city.contains(citydrp);
        } else {
          // check only spec_category if the city is not selected
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
          color: Colors.white,
        ),
        title:Container(
          // width:260,
          width: MediaQuery.of(context).size.width/2,
          height:40,
          padding: EdgeInsets.all(3.0),
          child: Center(
            child: Text(widget.category,
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
                            return Center(child: CircularProgressIndicator());
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




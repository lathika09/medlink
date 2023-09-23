import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medlink/constant/image_string.dart';
import 'package:medlink/views/patient/home.dart';

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

Future<List<DoctorData>> fetchDoctors() async {
  try {
    QuerySnapshot querySnapshot = await _firestore.collection('doctor').get();

    List<DoctorData> doctors = querySnapshot.docs.map((doc) {
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
      );
    }).toList();

    return doctors;
  } catch (e) {
    print('Error fetching doctors: $e');
    return [];
  }
}



class DoctorList extends StatefulWidget {
  const DoctorList({Key? key}) : super(key: key);

  @override
  State<DoctorList> createState() => _DoctorListState();
}

class _DoctorListState extends State<DoctorList> {

  // List listItem=[
  //   "Mumbai","Delhi","Pune","Chennai"
  // ];
  TextEditingController search_name = TextEditingController();
  String searchText='';
  String? valueChoose; // Initialize with null initially

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialize valueChoose with the value of val if available
    final Map<String, dynamic>? arguments =
    ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String? val = arguments?['val'] as String?;

    if (val != null) {
      setState(() {
        valueChoose = val;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String? val = arguments?['val'] as String?;
    final List<String>? listItem = arguments?['list'] as List<String>?;

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
          child: DropdownButton(
            elevation: 0,
            menuMaxHeight: 300,

            hint: Text("Select City ",style:TextStyle(
              color: Colors.white,
              fontSize: 22,
            ),),
            dropdownColor: Colors.green.shade50,
            icon: Icon(Icons.arrow_drop_down),
            iconSize: 26,
            isExpanded: true,
            style:TextStyle(
              color: Colors.white,
              fontSize: 22,
            ),
            value:valueChoose,
            onChanged: (newValue){
              setState(() {
                valueChoose=newValue as String?;
              });
            },
            items: listItem?.map((valueItem){
              return DropdownMenuItem(

                  value:valueItem,
                  child:Text(valueItem)
              );
            }).toList(),
          ),
        ),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              child: Column(
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
                          hintText: "Search by Speciality",
                          // prefixIcon:const Icon(Icons.search,size:20.0,),
                          suffixIcon: IconButton(onPressed: (){}, icon:const Icon(Icons.search,size: 20.0,))
                      ),

                    ),

                  ),
                  SizedBox(height: 10.0,),
                  //list of DOCTOR
                  Column(
                    children: [
                      FutureBuilder<List<DoctorData>>(
                        future: fetchDoctors(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator(); // Display a loading indicator while fetching data.
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            List<DoctorData> doctors = snapshot.data ?? [];

                            // Filter doctors based on city selection and search text
                            doctors = doctors.where((doctor) {
                              bool cityMatches = valueChoose == null || valueChoose!.isEmpty || doctor.city == valueChoose;
                              bool nameMatches = searchText.isEmpty ||
                                  doctor.speciality.any((s) => s.toLowerCase().contains(searchText.toLowerCase()));
                              return cityMatches && nameMatches;
                            }).toList();
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




//SEARCH BAR
class Custom_SearchBar extends StatefulWidget {
  const Custom_SearchBar({Key? key}) : super(key: key);

  @override
  State<Custom_SearchBar> createState() => _Custom_SearchBarState();
}

class _Custom_SearchBarState extends State<Custom_SearchBar> {
  TextEditingController search_name = TextEditingController();
  String searchText='';

  @override
  Widget build(BuildContext context) {
    return Container(
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
            hintText: "Search by Speciality",
            // prefixIcon:const Icon(Icons.search,size:20.0,),
            suffixIcon: IconButton(onPressed: (){}, icon:const Icon(Icons.search,size: 20.0,))
        ),

      ),

    );
  }
}


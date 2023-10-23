import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:medlink/views/patient/home.dart';


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
  String? valueChoose;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

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
    final List<String>? listItem = arguments?['list'] as List<String>?;
    final String? pemail = arguments?['pemail'] as String?;
    print(pemail);


    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    Future<List<DoctorData>> fetchDoctors() async {
      try {
        QuerySnapshot querySnapshot = await _firestore.collection('doctor').get();

        List<DoctorData> doctors = querySnapshot.docs.map((doc) {
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
            pemail: arguments?['pemail'],

          );
        }).toList();

        return doctors;
      } catch (e) {
        print('Error fetching doctors: $e');
        return [];
      }
    }



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
              color: Colors.black,
              fontSize: 22,
            ),
            value:valueChoose,
            onChanged: (newValue){
              setState(() {
                // valueChoose=newValue as String?;
                valueChoose=newValue;
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

                            // filter doctors based on city selection and search text
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


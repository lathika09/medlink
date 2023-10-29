import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medlink/constant/image_string.dart';
import 'package:medlink/views/chats/chat_screen.dart';
import 'package:medlink/views/patient/login.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'databaseconn/specialitywise.dart';
import 'package:intl/intl.dart';


class HomePage extends StatefulWidget {
  HomePage({Key? key,required this.pemail }) : super(key: key);
final String? pemail;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
//patient self
  Map<String, dynamic> patientData = {};
  Future<void> fetchPatientData() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection("patients").where("email", isEqualTo: widget.pemail!).get();
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          patientData = snapshot.docs.first.data() as Map<String, dynamic>;
          print(patientData['name']);
          print("PRINT THIS : ${patientData['id']}");
        });
      }
    } catch (e) {
      print("Error fetching doctor data: $e");
    }
  }





//doctor list
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
        String pemail =(patientData['email'] is String) ? patientData['email'] : '';
        //  availability map in doc
        Map<String, dynamic> doctorAvailability = {
          'weekday': weekdays,
          'time': time,
        };

        return DoctorData(
          route: 'doc_details',
          id:id,
          name: name,
          speciality: speciality,
          qualification: qualification,
          hospital: hospital,
          address: address,
          experience: experience,
          description: description,
          availability: doctorAvailability,
          email:email,
          city: city,
          pemail:pemail,
        );
      }).toList();

      return doctors;
    } catch (e) {
      print('Error fetching doctors: $e');
      return [];
    }
  }

// Fetch appointment data from Firestore LISTVIEW
  Future<List<AppointmentData>> getAppointments() async {
    try{
      final query = await FirebaseFirestore.instance
          .collection('patients')
          .where('email', isEqualTo: widget.pemail)
          .get();
      if (query.docs.isEmpty) {
        return [];
      }
      final patientId = query.docs.first.id;

      QuerySnapshot appointmentsQuery = await FirebaseFirestore.instance
          .collection('patients')
          .doc(patientId)
          .collection('appointments')
          .get();
      final appointmentsId=appointmentsQuery.docs.first.id;

      List<AppointmentData> appointments=appointmentsQuery.docs.map((doc){
        Map<String, dynamic> appointData = doc.data() as Map<String, dynamic>;

        String doc_name = (appointData['doctor_name'] is String) ? appointData['doctor_name'] : '';
        String pat_name = (appointData['patient_name'] is String) ? appointData['patient_name'] : '';
        String schedule_time = (appointData['schedule_time'] is String) ? appointData['schedule_time'] : '';
        String status = (appointData['status'] is String) ? appointData['status'] : '';
        Timestamp? appointment_date = (appointData['appointment_date'] is Timestamp) ? appointData['appointment_date'] : null;
        String formattedDate = '';
        // String pemail =(patientData['email'] is String) ? patientData['email'] : '';

        if (appointment_date != null) {
          DateTime dateTime = appointment_date.toDate();
          formattedDate = DateFormat('EEEE, dd/MM/yyyy').format(dateTime);
        }

        return AppointmentData(
          id:appointmentsId,
          doc_name:doc_name,
          pat_name:pat_name,
          schedule_time:schedule_time,
          status:status,
          appointment_date:formattedDate,
        );


      }).toList();//map

      // return appointments;

      List<AppointmentData> validAppointments = appointments
          .where((appointment) =>
      appointment.status == "Request" ||
          appointment.status == "Confirm" ||
          appointment.status == "Cancel")
          .toList();

      //  cancelled appointments
      for (final doc in appointmentsQuery.docs) {
        Map<String, dynamic> appointData = doc.data() as Map<String, dynamic>;
        String status = (appointData['status'] is String) ? appointData['status'] : '';
        print("gjhk : $status");

        if (status == "Cancel") {
          // for 1 min can chnge it later
          const int delayMilliseconds = 1 * 60 * 1000;

          Future.delayed(Duration(milliseconds: delayMilliseconds), () async {
            print("Deleting appointment with ID ${doc.id}");

            // delete from the patient's subcollection
            await doc.reference.delete();

            // delete from the appointments
            final appointmentCollection = FirebaseFirestore.instance.collection('appointments');
            await appointmentCollection.doc(doc.id).delete();

            // delete doc from the doctor's subcollection by doctor name
            final doctorName = doc['doctor_name'] as String;
            final doctorQuery = FirebaseFirestore.instance.collection('doctor').where('name', isEqualTo: doctorName);
            final doctorSnapshot = await doctorQuery.get();
            for (final doctorDoc in doctorSnapshot.docs) {
              final doctorRef = doctorDoc.reference.collection('appointments').doc(doc.id);
              await doctorRef.delete();
              print("Deleted from doctor's subcollection");
            }

            print("Deleted appointment with ID ${doc.id}");

            setState(() {
              appointments.removeWhere((appointment) => appointment.id == doc.id);
            });
          });
        }
      }
      return validAppointments;
    }//try
    catch (e) {
      print('Error fetching doctors: $e');
      return [];
    }
  }

  //delete if time passed
  Future<void> deletePastAppointments() async {
    final now = DateTime.now();
    //Appointment collection
    final collection = FirebaseFirestore.instance.collection('appointments');
    final querySnapshot = await collection.get();

    for (final doc in querySnapshot.docs) {
      final appointmentDate = doc['appointment_date'] as Timestamp;
      final scheduleTime = doc['schedule_time'] as String;
      final patientName = doc['patient_name'] as String;
      final doctorName = doc['doctor_name'] as String;

      final appointmentDateTime = appointmentDate.toDate();
      final scheduleTimeParts = scheduleTime.split(' ');//it is string 09:00 pm so we get 09:00 from this
      final time=scheduleTimeParts[0];
      print("Datetime now :${DateTime.now()}");
      final appointmentDateTimeWithTime = DateTime(
        appointmentDateTime.year,
        appointmentDateTime.month,
        appointmentDateTime.day,
        int.parse(time.split(':')[0]), //09
        int.parse(time.split(':')[1]), //00
      );

      if (appointmentDateTimeWithTime.isBefore(now)) {
        // delete after this time
        const int delayMilliseconds = 1 * 60 * 1000;
        await Future.delayed(Duration(milliseconds: delayMilliseconds));

        // patient and doctor collections to find matching documents
        final patientQuery = FirebaseFirestore.instance.collection('patients').where('name', isEqualTo: patientName);
        final patientSnapshot = await patientQuery.get();

        final doctorQuery = FirebaseFirestore.instance.collection('doctor').where('name', isEqualTo: doctorName);
        final doctorSnapshot = await doctorQuery.get();

        // delete the document from appoint collection
        await doc.reference.delete();

        // dlete the document from the patient subcollection
        for (final patientDoc in patientSnapshot.docs) {
          final patientRef = patientDoc.reference.collection('appointments').doc(doc.id);
          await patientRef.delete();
        }

        // delete the document from the doctor subcollection
        for (final doctorDoc in doctorSnapshot.docs) {
          final doctorRef = doctorDoc.reference.collection('appointments').doc(doc.id);
          await doctorRef.delete();
        }
      }
    }
    getAppointments();
  }


  //DROP CITY LIST
  Future<List<String>> getUniqueCities() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('doctor').get();
      List<String> cities = [];

      querySnapshot.docs.forEach((doc) {
        Map<String, dynamic> doctorData = doc.data() as Map<String, dynamic>;
        String? city = doctorData['city'] as String?;
        if (city != null && city.isNotEmpty && !cities.contains(city)) {
          cities.add(city);
        }
      });
      print(cities);
      return cities;
    } catch (e) {
      print('Error fetching unique cities: $e');
      return [];
    }
  }
  List<String> listItem = [];
  Future<void> fetchCities() async {
    List<String> cities = await getUniqueCities();
    setState(() {
      print(listItem);
      listItem = cities;
      print("AFTER : ${listItem}");
    });
  }

  @override
  void initState() {
    super.initState();
    fetchPatientData();
    fetchCities();
    deletePastAppointments();
  }

  final color1 = Colors.tealAccent.shade400;
  final color2 = Colors.tealAccent.shade700;
  final ratio = 0.5;
  get mixedColor => Color.lerp(color1, color2, ratio);

  String? valueChoose;

  TextEditingController search_name = TextEditingController();
  String searchText='';

  List<Map<String,dynamic>> medCat=[
    {
      'icon':FontAwesomeIcons.userDoctor,
      'category':'General',
    },
    {
      'icon':FontAwesomeIcons.heartPulse,
      'category':'Cardiology',
    },
    {
      'icon':FontAwesomeIcons.hand,
      'category':'Dermatologist',
    },
    {
      'icon':FontAwesomeIcons.teeth,
      'category':'Dentist',
    },
    {
      'icon':FontAwesomeIcons.bone,
      'category':'Orthopedic',
    },
    {
      'icon': FontAwesomeIcons.personFalling,
      'category':'Gastroenterologist',
    },
  ];
  Future<void> refreshData() async {
    try {
      List<DoctorData> doctors = await fetchDoctors();
      List<AppointmentData> appointments = await getAppointments();
      setState(() {
        doctors = doctors;
        appointments = appointments;
      });
    } catch (e) {
      print('Error refreshing data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    print("homepage");
    String pemail =(patientData['email'] is String) ? patientData['email'] : '';
    return Scaffold(
      drawer:NavBar(user_name: patientData['name'],user_email: patientData['email'],),//widget.pemail can also be used here

      appBar:AppBar(
        backgroundColor:Colors.blueAccent.shade700,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title:Center(
          child: Text(appname,
            style: TextStyle(
                fontSize: 30, // fontSize:17* MediaQuery.textScaleFactorOf(context),
                color: Colors.white,
                fontWeight: FontWeight.bold),
          ),
        ),
        elevation: 24.0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh,size: 30,color: Colors.white,),
            onPressed: () {
              refreshData();
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => NotificationPage()),
              // );
            },
          ),
        ],
      ),
      body:SafeArea(
        child: SingleChildScrollView(
          // physics: AlwaysScrollableScrollPhysics(),
          child:Container(
            child:Column(
              children: [
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color:Colors.greenAccent.shade200,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        spreadRadius: 3,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),

                  padding: EdgeInsets.symmetric(vertical:10,horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(child: Icon(Icons.location_on,size: 28,color: Colors.black,)),
                      Container(
                        // width:260,
                        width: MediaQuery.of(context).size.width/2,
                        height:40,
                        padding: EdgeInsets.all(3.0),
                        child: DropdownButton(
                          elevation: 0,
                          menuMaxHeight: 300,
                          hint: Text("Select City "),
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
                              valueChoose=newValue as String;;
                            });
                          },


                          items: listItem.map((valueItem){
                            return DropdownMenuItem(

                                value:valueItem,
                                child:Text(valueItem)
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(width: 20,),
                      IconButton(
                          onPressed: (){
                            Navigator.pushNamed(
                              context,
                              'docsearch', // The route name for ProfileSetting
                              arguments: {
                                'list':listItem,
                                'val':valueChoose,
                                'pemail':widget.pemail,
                              },
                            );
                      }, icon: Icon(Icons.search,size: 28,color: Colors.black,))
                    ],
                  ),
                ),

                ImageSlider(),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10.0,horizontal: 15.0),
                  child: Column(

                    children: [
                      Row(

                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Category",
                            style: TextStyle(
                                fontSize:24,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 10,),
                      SizedBox(
                        height: MediaQuery.of(context).size.height/9,
                        child: ListView(
                          // physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          children: List<Widget>.generate(medCat.length, (index) {
                            return GestureDetector(
                              child: Card(
                                elevation: 5,
                                margin: EdgeInsets.only(right: 20.0),
                                color:  Colors.blue.shade50,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 15.0,vertical: 10.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      FaIcon(
                                        medCat[index]['icon'],
                                        color: Colors.indigo.shade900,
                                        size:27,
                                      ),

                                      const SizedBox(height: 8,),
                                      Text(medCat[index]['category'],
                                        style: TextStyle(
                                            fontSize: 16,
                                            color:Colors.indigo.shade900,
                                            fontWeight: FontWeight.bold),
                                      ),
                                  ],
                                ),),
                              ),
                              onTap: (){
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) =>SpecialityList(pemail:pemail,category:medCat[index]['category'])),
                                );
                              },
                            );
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 25,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Appointment ",
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 8,),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [
                          FutureBuilder<List<AppointmentData>>(
                            future: getAppointments(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                List<AppointmentData> appointments = snapshot.data ?? [];

                                if (appointments.isEmpty) {
                                  return Container(
                                    padding: EdgeInsets.symmetric(vertical: 10.0,horizontal: 15.0),
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color:Colors.greenAccent.shade200,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.3),
                                            spreadRadius: 3,
                                            blurRadius: 5,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                    child:Text('No appointments scheduled.',style: TextStyle(color: Colors.black,fontSize: 19,fontWeight: FontWeight.bold,),
                                    )
                                  );
                                }

                                return ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),//by adding this scroll is listview working properly
                                  shrinkWrap: true,
                                  itemCount: appointments.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      margin: EdgeInsets.symmetric(vertical: 8),
                                      child: appointments[index],
                                    );
                                  },
                                );
                              }
                            },
                          ),
                        ],
                      ),

                      SizedBox(height: 25,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Top Doctor",
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      // SizedBox(height: ,),
                      //doctor card
                      Column(
                        children: [
                          FutureBuilder<List<DoctorData>>(
                            future: fetchDoctors(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                List<DoctorData> doctors = snapshot.data ?? [];

                                return ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: doctors.length,
                                  itemBuilder: (context, index) {
                                    final experienceString = doctors[index].experience;
                                    final yearsOfExperience = int.tryParse(experienceString.split(' ')[0]) ?? 0;

                                    if (yearsOfExperience > 10) {
                                      return doctors[index];
                                    } else {
                                      // If the doctor's experience is not greater than 10 years, return an empty     .
                                      return Container();
                                    }
                                  },
                                );
                              }
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(height: 10,),
              ],

            ),

          ),

        ),
      ) ,
    );
  }
}




//DOCTOR CARD
class DoctorData extends StatefulWidget {
  DoctorData({
    Key? key,
    required this.route,
    required this.id,
    required this.name,
    required this.speciality,
    required this.qualification,
    required this.hospital,
    required this.address,
    required this.experience,
    required this.description,
    required this.availability,
    required this.email,
    required this.city,
    required this.pemail
  }) : super(key: key);

  final String route;
  final String id;
  final String name;
  final List<String> speciality;
  final String qualification;
  final String hospital;
  final String address;
  final String experience;
  final String description;
  final Map<String, dynamic> availability;
  final String email;
  final String city;
  final String pemail;


  @override
  _DoctorDataState createState() => _DoctorDataState();
}

class _DoctorDataState extends State<DoctorData> {
  final color1 = Colors.white;
  final color2 = Colors.greenAccent.shade100;
  final ratio = 0.5;
  get mixednewColor => Color.lerp(color1, color2, ratio);

  //chat collection
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



  //DOC IMAGE
  String? _profileImageUrl;

  Future<String?> getProfileImageUrl(String userEmail) async {
    try {
      final Reference storageReference =
      FirebaseStorage.instance.ref().child('prof_images/$userEmail.jpg');

      final String downloadURL = await storageReference.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print('Error getting profile image URL: $e');
      return null;
    }
  }
  Future<void> loadProfileImage() async {
    final imageUrl = await getProfileImageUrl(widget.email);
    if (imageUrl != null) {
      setState(() {
        _profileImageUrl = imageUrl;
      });
    }
    print("PROFILE");
  }

  @override
  void initState() {
    super.initState();
    loadProfileImage();
    fetchPatientData();
    fetchDoctorData();

  }

  @override
  Widget build(BuildContext context) {
    String specialtiesString = widget.speciality.join(', ');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 13),
      // height: 210,
      child: GestureDetector(
        child: Card(
          elevation: 5,
          color: mixednewColor,
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
                          height: 80.0,
                          width: 80.0,
                          color:Colors.transparent,
                          child:CircleAvatar(
                            radius: 60,
                            backgroundImage: _profileImageUrl != null
                                ? NetworkImage(_profileImageUrl!)
                                :NetworkImage("https://st4.depositphotos.com/19795498/22606/v/450/depositphotos_226060300-stock-illustration-medical-icon-man-doctor-with.jpg"),
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
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width:
                                      MediaQuery.of(context).size.width *
                                          0.4,
                                      child: Text(
                                        widget.name,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        softWrap: true,
                                      ),
                                    ),
                                    SizedBox(
                                      width:
                                      MediaQuery.of(context).size.width *
                                          0.46,
                                      child: Text(
                                        specialtiesString,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.normal,
                                        ),
                                        softWrap: true,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    MaterialButton(
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
                                userId: patientData['id'], Name: doctorData['name'],
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
                      color: Colors.blueAccent.shade700,
                      minWidth: MediaQuery.of(context).size.width/6,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent.shade700,
                      ),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          'booking_Page',
                          arguments: {
                            'name': widget.name,
                            'speciality': specialtiesString,
                            'qualification': widget.qualification,
                            'hospital': widget.hospital,
                            'address': widget.address,
                            'experience': widget.experience,
                            'description': widget.description,
                            'email': widget.email,
                            'pemail':widget.pemail,

                          },
                        );
                      },
                      child: Text(
                        "Book Appointment",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          Navigator.pushNamed(
            context,
            'doc_details',
            arguments: {
              'name': widget.name,
              'speciality': specialtiesString,
              'qualification': widget.qualification,
              'hospital': widget.hospital,
              'address': widget.address,
              'experience': widget.experience,
              'description': widget.description,
              'email': widget.email,
              'availability':widget.availability,
              'pemail':widget.pemail,
              // 'patient':
            },
          );
        },
      ),
    );
  }
}

// APPOINTMENT CARD

class AppointmentData extends StatefulWidget {
  const AppointmentData({Key? key,required this.id,required this.doc_name,required this.pat_name,required this.schedule_time,required this.status,required this.appointment_date,}) : super(key: key);
  final String id;
  final String doc_name;
  final String pat_name;
  final String schedule_time;
  final String status;
  final String appointment_date;


  @override
  State<AppointmentData> createState() => _AppointmentDataState();
}

class _AppointmentDataState extends State<AppointmentData> {
//DOC IMAGE
  String? _profileImageUrl;
  Future<void> loadProfileImage(String userEmail) async {
    try {
      final Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('prof_images/$userEmail.jpg');

      final String downloadURL = await storageReference.getDownloadURL();
      setState(() {
        _profileImageUrl = downloadURL;
      });
    } catch (e) {
      print('Error getting profile image URL: $e');
      setState(() {
        _profileImageUrl = null;
      });
    }
    print("PROFILE: $_profileImageUrl");
  }


  Map<String, dynamic> docData = {};
  String? demail;
  String? specialitiesString = '';

  Future<void> fetchDocData() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection("doctor").where("name", isEqualTo: widget.doc_name).get();
      print("snapshot : ${snapshot.docs.first.data()}");
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          final docData = snapshot.docs.first.data() as Map<String, dynamic>;
          final demail = docData['email'];
          final List<String> speciality = (docData['speciality'] is List) ? List<String>.from(docData['speciality']) : [];

          if (demail != null) {
            loadProfileImage(demail);
          }
          print("DOCDATA : $demail");
          specialitiesString = speciality.join(', ');
        });
      }
    } catch (e) {
      print("Error fetching doctor data: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDocData();
    print("DOCDATA : ${demail}");//remove later
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return  Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color:Colors.greenAccent.shade200,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3), // Shadow color
            spreadRadius: 3, // Spread radius
            blurRadius: 5, // Blur radius
            offset: Offset(0, 2), // Offset of the shadow
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    // backgroundImage: NetworkImage("https://st4.depositphotos.com/19795498/22606/v/450/depositphotos_226060300-stock-illustration-medical-icon-man-doctor-with.jpg"),
                    backgroundImage: _profileImageUrl != null
                        ? NetworkImage(_profileImageUrl!)
                        :NetworkImage("https://st4.depositphotos.com/19795498/22606/v/450/depositphotos_226060300-stock-illustration-medical-icon-man-doctor-with.jpg"),
                  ),
                  const SizedBox(width:10,),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:[
                      Text(widget.doc_name,style: TextStyle(color: Colors.black,fontSize: 19,fontWeight: FontWeight.bold,),),
                      SizedBox(height: 2,),
                      SizedBox(
                        width: MediaQuery.of(context).size.width/1.6,
                        child: Text(specialitiesString ?? 'Loading...',style: TextStyle(color: Colors.black54,fontSize: 15,fontWeight: FontWeight.bold,),
                          softWrap: true,
                        ),
                      )
                    ],
                  ),
                ],
              ),
              SizedBox(height: 25,),
              //Schedule details
              Container(
                decoration: BoxDecoration(
                  color:Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],),
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_month_sharp,color: Colors.black,size: 16,),
                    SizedBox(width: 4,),
                    Text(
                      widget.appointment_date,
                      style: const TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width:15,),
                    Icon(Icons.access_alarm_rounded,color: Colors.black,size: 16,),
                    SizedBox(width: 4,),
                    Flexible(child: Text(widget.schedule_time,style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.bold),),
                    ),
                  ],
                ),

              ),
              SizedBox(height: 25,),
              //ACTION BUTTON
              Center(
                child:Container(
                  padding: EdgeInsets.symmetric(vertical: 10,horizontal: 25),

                  decoration: BoxDecoration(
                    color:Colors.blueAccent,

                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],),
                  child: Text(
                            widget.status =="Request"
                            ? 'Request send'
                                : widget.status == "Cancel"
                                ? 'Appointment is Cancelled choose another date '
                                :widget.status == "Confirm"
                                ? 'Appointment is Confirmed'
                                : 'Status : ${widget.status}',
                    style: TextStyle(color: Colors.white,fontSize: 19,fontWeight: FontWeight.bold),),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class NavBar extends StatefulWidget {
  const NavBar({Key? key,required this.user_name,required this.user_email}) : super(key: key);
  final String? user_name;
  final String? user_email;

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children:[
          UserAccountsDrawerHeader(
            accountName:  Text(widget.user_name!,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,),
            ),
            accountEmail: Text(widget.user_email!,
              style: TextStyle(
                fontSize: 16,),
            ),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(child: Image.asset(prof),),
            ),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              image: DecorationImage(image:AssetImage(bg_nav),
                  fit: BoxFit.cover),
            ),
          ),
          ListTile(
            leading: Icon(Icons.history_edu,color:Colors.blueAccent.shade700,size:26),
            title: Text("My Records",
              style: TextStyle(
                fontSize: 19,),
            ),
            onTap: ()=>print("my records"),
          ),
          ListTile(
            leading: Icon(Icons.notifications_active_sharp,color:Colors.blueAccent.shade700,size:26),
            title: Text("Notifications",
              style: TextStyle(
                fontSize: 19,),
            ),
            onTap: ()=>print("notification"),
          ),
          ListTile(
            leading: Icon(Icons.app_shortcut_rounded,color:Colors.blueAccent.shade700,size:26),
            title: Text("About App",
              style: TextStyle(
                fontSize: 19,),
            ),
            onTap: ()=>print("About App"),
          ),
          ListTile(
            leading: Icon(Icons.support_agent,color:Colors.blueAccent.shade700,size:26),
            title: Text("Help and Support",
              style: TextStyle(
                fontSize: 19,),
            ),
            onTap: ()=>print("Help and Support"),
          ),
          ListTile(
            leading: Icon(Icons.logout,color:Colors.blueAccent.shade700,size:26),
            title: Text("Logout",
              style: TextStyle(
                fontSize: 19,),
            ),
            onTap: () async {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
    );
  }
}




//SLIDE CARAUSEL SLIDER
class ImageSlider extends StatefulWidget {
  const ImageSlider({Key? key}) : super(key: key);
  @override
  State<ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  final myitems=[
    Image.asset(slide1),Image.asset(slide2),Image.asset(slide3),Image.asset(slide5),Image.asset(slide6),
  ];

  int myCurrentIndex=0;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2),
      child: Column(
        children: [
          CarouselSlider(
              items: myitems,
              options: CarouselOptions(
                autoPlay: true,
                height: 200,
                autoPlayCurve: Curves.fastOutSlowIn,
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                autoPlayInterval: const Duration(seconds: 2),
                enlargeCenterPage: true,
                aspectRatio: 2.0,
                onPageChanged: (index,reason){
                  setState(() {
                    myCurrentIndex=index;
                  });
                },

              ),
          ),
          AnimatedSmoothIndicator(
            activeIndex: myCurrentIndex,
            count: myitems.length,
            effect:WormEffect(
              dotHeight: 8,
              dotWidth: 8,
              spacing: 10,
              activeDotColor: Colors.blue.shade700,
              dotColor: Colors.grey.shade200,
              paintStyle: PaintingStyle.fill,
          ),
        )
        ],
      ),
    );
  }
}



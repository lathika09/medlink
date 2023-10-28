import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medlink/views/patient/doctor_details.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({Key? key}) : super(key: key);
  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  List<int> doctorWeekdays = [];
  List<String> availableTimes = [];
  String? selectedHour;

  CalendarFormat _format=CalendarFormat.month;
  DateTime _focusDay=DateTime.now();
  DateTime _currentDay=DateTime.now();
  int? _currentIndex;
  bool _isWeekend=false;
  bool _dateSelected=false;
  bool _timeSelected=false;
  bool _isToday = false;


  Map<String, dynamic> patientData = {};
  Future<void> fetchPatientData(String pemail) async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection("patients").where("email", isEqualTo: pemail).get();
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


  Map<String, dynamic> doctorInfo = {};
  Future<void> fetchDoctorInfo(String email) async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection("doctor").where("email", isEqualTo: email).get();
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          doctorInfo = snapshot.docs.first.data() as Map<String, dynamic>;
          print(doctorInfo['name']);
        });
      }
    } catch (e) {
      print("Error fetching doctor data: $e");
    }
  }


  // Function to fetch the doctor's weekday array
  Future<void> fetchDoctorWeekdays(String email) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("doctor")
          .where("email", isEqualTo: email)
          .get();
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          // doctor = snapshot.docs.first.data() as Map<String, dynamic>;
          doctorWeekdays = List<int>.from(snapshot.docs.first["availability"]["weekday"] ?? []);
          availableTimes = List<String>.from(snapshot.docs.first["availability"]["time"] ?? []);
        });
      }
    } catch (e) {
      print("Error fetching doctor's weekday array: $e");
    }
  }


  Map<String, dynamic> selfData = {};
  Future<void> fetchSelfData() async {
    try {
      Map<String, dynamic> selfData = {};
      final Map<String, dynamic> args =
      ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      final String? pemail = args['pemail'] as String?;
      final snapshot = await FirebaseFirestore.instance.collection("patients").where("email", isEqualTo: pemail).get();
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          selfData = snapshot.docs.first.data() as Map<String, dynamic>;
          print(selfData['name']);
          print("PRINT THIS : ${selfData['id']}");
        });
      }
    } catch (e) {
      print("Error fetching doctor data: $e");
    }
  }

  Future<void> addPatientToDoctorSubcollection() async {
    try {
      final Map<String, dynamic> args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      final String? pemail = args['pemail'] as String?;
      final String? email = args['email'] as String?;

      // Step 1: Retrieve the doctor's document ID using their email
      final doctorQuery = await FirebaseFirestore.instance
          .collection('doctor') // Replace with your doctor's collection name
          .where('email', isEqualTo: email)
          .get();

      if (doctorQuery.docs.isEmpty) {
        print('Doctor not found with email: $email');
        return;
      }

      final doctorDocument = doctorQuery.docs.first;
      final doctorId = doctorDocument.id;

      // Step 2: Create a reference to the "patients" subcollection within the doctor's document
      final doctorPatientsCollection = FirebaseFirestore.instance.collection('doctor/$doctorId/patients');

      // Step 3: Check if the patient already exists in the subcollection
      final existingPatientQuery = await doctorPatientsCollection.doc(pemail).get();

      if (existingPatientQuery.exists) {
        print('Patient already exists in the doctor\'s subcollection.');
        return; // Skip adding the patient again
      }

      // Step 4: Fetch patient data
      final snapshot = await FirebaseFirestore.instance.collection("patients").where("email", isEqualTo: pemail!).get();
      if (snapshot.docs.isNotEmpty) {
        final selfData = snapshot.docs.first.data() as Map<String, dynamic>;


        final now = DateTime.now();
        final formattedDateTime = DateFormat('yyyy-MM-dd').format(now);

        // Add any patient-specific data you need here
        final patientData = {
          'email': pemail,
          'patientId': selfData['id'],
          'name': selfData['name'],
          'createdAt':formattedDateTime,
          // Add more fields if needed
        };

        // Step 5: Add the patient to the doctor's subcollection
        await doctorPatientsCollection.doc(pemail).set(patientData);

        // Step 6: Add the patient document ID as a field in the patient's document
        await doctorPatientsCollection.doc(pemail).update({
          'id': pemail, // Use the email as the ID, or you can use another unique identifier
          // Add any other fields you need
        });

        print('Patient added to doctor\'s subcollection.');
      } else {
        print('Patient data not found for email: $pemail');
      }
    } catch (e) {
      print('Error adding patient to doctor subcollection: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchSelfData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Map<String, dynamic> args =
    ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final String? pemail = args['pemail'] as String?;
    final String? email = args['email'] as String?;
    fetchPatientData(pemail!);
    fetchDoctorInfo(email!);
    fetchDoctorWeekdays(email);

  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final String? pemail = args['pemail'] as String?;
    final String? email = args['email'] as String?;

    return Scaffold(
      appBar: CustomAppBar(
        appTitle: "Appointment",
        icon: FaIcon(Icons.arrow_back_ios),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                _tableCalendar(),
                Padding(padding: EdgeInsets.symmetric(vertical: 25,horizontal: 10),
                  child: Center(
                    child: Text("Select Appointment Time",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          _isWeekend ?SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 30,horizontal: 10),
              alignment: Alignment.center,
              child: Text("Weekend is not available,please select another date",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),

              ),
            ),
          ):SliverGrid(
              delegate:SliverChildBuilderDelegate((context, index){
                print("INDEX ISS :$index");
                if (index < availableTimes.length) {
                  String hour = availableTimes[index];
                  return InkWell(
                    splashColor: Colors.transparent,
                    onTap: () {
                      setState(() {
                        _currentIndex = index;
                        selectedHour = availableTimes[index];
                        print("SELECTED : $selectedHour");
                        // _time=_currentIndex;
                        _timeSelected = true;
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _currentIndex == index ? Colors.white : Colors.black,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        color: _currentIndex == index ? Colors.blueAccent.shade700 : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "${hour}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _currentIndex == index ? Colors.white : null,
                        ),
                      ),
                    ),
                  );

                } else {
                  return Container();
                }
              },
                childCount: availableTimes.length,
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1.5,
              ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10,vertical: 80),
              child: Button(
                width : double.infinity,
                title:"Make Appointment",
                onPressed:(){
                  storeAppointmentDetails();
                  addPatientToDoctorSubcollection();
                  showModalBottomSheet(context: context, builder: ((context) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 20,),
                        Expanded(
                          flex: 3,
                          child: Lottie.asset("assets/success.json"),
                        ),
                        Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          child: Text(
                            "Successfully Booked",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Spacer(),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                          child: Button(
                              width: double.infinity,
                              title: "Click here.",
                              disable: false,
                              onPressed: () {
                                // Navigator.pushReplacement(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) => MainPage(pemail: pemail!),
                                //   ),
                                // );
                                Navigator.pop(context);

                              }
                          ),
                        ),
                      ],
                    );
                  }

                  )
                  );
                },
                disable :_timeSelected && _dateSelected && !_isToday ? false : true,
              ),
            ),
          )
        ],
      ),

    );
  }

  //CALENDAR TABLE
  Widget _tableCalendar(){


    return TableCalendar(
      focusedDay: _focusDay,
      firstDay: DateTime.now(),
      lastDay: DateTime(2023,12,31),
      calendarFormat: _format,
      currentDay: _currentDay,
      rowHeight: 48,
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Colors.blueAccent.shade700,
          shape: BoxShape.circle,
        )
      ),
      availableCalendarFormats: const{
        CalendarFormat.month:"Month",
      },
      onFormatChanged:(format){
        setState(() {
          _format=format;
        });
      },
      onDaySelected: (selectedDay,focusedDay){
        setState(() {
          _currentDay=selectedDay;
          _focusDay=focusedDay;
          _dateSelected=true;
          // check if selected day is today
          final now = DateTime.now();
          _isToday = selectedDay.year == now.year &&
              selectedDay.month == now.month &&
              selectedDay.day == now.day;

          if(doctorWeekdays.contains(selectedDay.weekday)){
            _isWeekend=true;
            _timeSelected=false;
            _currentIndex=null;
          }
          else{
            _isWeekend=false;
            print("SELECTED : $selectedHour");
          }
        });
      },
    );
  }
  final CollectionReference appointmentsCollection = FirebaseFirestore.instance.collection('appointments');

  //reference to doctor appointments subcollection
  final CollectionReference doctorAppointmentsCollection =
  FirebaseFirestore.instance.collection('doctor').doc('email').collection('appointments');


//reference to patient appointments subcollection
  final CollectionReference patientAppointmentsCollection =
  FirebaseFirestore.instance.collection('patients').doc('pemail').collection('appointments');

  void storeAppointmentDetails() async {
    if (!_dateSelected || !_timeSelected) {// not selected then
      return;
    }
    Map<String, dynamic> appointmentData = {
      'appointment_date': _currentDay,
      'schedule_time':selectedHour,
      'doctor_name': doctorInfo['name'],
      'patient_name': patientData['name'],
      'status': "Request",
    };

    try {
      DocumentReference appointmentDocRef = await appointmentsCollection.add(appointmentData);
      final doctorQuerySnapshot = await FirebaseFirestore.instance
          .collection("doctor")
          .where("email", isEqualTo: doctorInfo['email'])
          .get();

      if (doctorQuerySnapshot.docs.isNotEmpty) {
        final doctorDoc = doctorQuerySnapshot.docs.first;
        await doctorDoc.reference.collection("appointments").doc(appointmentDocRef.id).set(appointmentData);
      } else {
        print("No doctor document found with email: ${doctorInfo['email']}");
      }
      // await patientAppointmentsCollection.add(appointmentData);
      final patientQuerySnapshot = await FirebaseFirestore.instance
          .collection("patients")
          .where("email", isEqualTo: patientData['email'])
          .get();

      if (patientQuerySnapshot.docs.isNotEmpty) {
        final patientDoc = patientQuerySnapshot.docs.first;
        await patientDoc.reference.collection("appointments").doc(appointmentDocRef.id).set(appointmentData);
      } else {
        print("No patient document found with email: ${patientData['email']}");
      }
    } catch (e) {
      print("Error adding appointment: $e");
    }
  }

}

class Button extends StatelessWidget {
  const Button({Key? key,required this.width,required this.title,required this.disable,required this.onPressed,}) : super(key: key);

  final double width;
  final String title;
  final bool disable;
  final Function() onPressed;


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent.shade700,
          foregroundColor: Colors.white,
        ),
        onPressed:disable ? null : onPressed,
        child: Text(title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
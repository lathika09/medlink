import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medlink/views/patient/doctor_details.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:lottie/lottie.dart';

import 'MainPage.dart';

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

  @override
  void initState() {
    super.initState();
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
    //final String? email = args['email'] as String?;

    final Map<String, dynamic> availability = args['availability'] ?? {
      'weekday': '',  // Default value for 'weekday'
      'time': '',      // Default value for 'time'
    };
    // List<dynamic> weekdays =availability['weekday'] is List ? List<dynamic>.from(availability['weekday']) : [];
    // List<dynamic> time =availability['time'] is List ? List<dynamic>.from(availability['time']) : [];


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
                //int hour = index + 9; // Calculate the hour (e.g., 9 AM, 10 AM, ...)
                //       bool isAvailable = availability['time'] == hour && (!availability['weekday'].contains(selectedDay.weekday));
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
                  // Return an empty container for slots beyond the available times
                  return Container();
                }
              },
                // Set the childCount to the number of available times
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

  //reference to the doctor appointments subcollection
  final CollectionReference doctorAppointmentsCollection =
  FirebaseFirestore.instance.collection('doctor').doc('email').collection('appointments');


//reference to the patient appointments subcollection
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
// Navigator.push(context,MaterialPageRoute(builder: (context)=>AppointmentBooked()));
// showModalBottomSheet(context: context, builder: ((context){
//   return Column(
//     mainAxisAlignment: MainAxisAlignment.center,
//     children: [
//       SizedBox(height: 20,),
//       Expanded(
//         flex: 3,
//         child: Lottie.asset("assets/success.json"),
//       ),
//       Container(
//         width: double.infinity,
//         alignment: Alignment.center,
//         child: Text("Successfully Booked",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
//       ),
//       Spacer(),
//       Padding(padding: EdgeInsets.symmetric(horizontal: 10,vertical: 15),
//         child: Button(
//             width: double.infinity,
//             title: "Back to Home.",
//             disable: false,
//             onPressed: ()=>Navigator.of(context).pushNamed('main')),
//       ),
//     ],
//   );
//
// }));








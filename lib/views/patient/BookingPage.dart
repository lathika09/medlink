import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medlink/constant/image_string.dart';
import 'package:medlink/views/patient/doctor_details.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:lottie/lottie.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({Key? key}) : super(key: key);

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  List<int> doctorWeekdays = [];

  CalendarFormat _format=CalendarFormat.month;
  DateTime _focusDay=DateTime.now();
  DateTime _currentDay=DateTime.now();
  int? _currentIndex;
  bool _isWeekend=false;
  bool _dateSelected=false;
  bool _timeSelected=false;
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
          doctorWeekdays = List<int>.from(snapshot.docs.first["availability"]["weekday"] ?? []);
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
    final String? pemail = args?['pemail'] as String?;
    final String? email = args?['email'] as String?;
    fetchPatientData(pemail!);
    fetchDoctorInfo(email!);
    fetchDoctorWeekdays(email!);

  }



  @override
  Widget build(BuildContext context) {

    final Map<String, dynamic> args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final String? pemail = args?['pemail'] as String?;
    final String? email = args?['email'] as String?;

    final Map<String, dynamic> availability = args['availability'] ?? {
      'weekday': [],  // Default value for 'weekday'
      'time': 0,      // Default value for 'time'
    };
    List<dynamic> weekdays = availability['weekday'] ?? [];
    int time = availability['time'] ?? 0;

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

                //int hour = index + 9; // Calculate the hour (e.g., 9 AM, 10 AM, ...)
                //       bool isAvailable = availability['time'] == hour && (!availability['weekday'].contains(selectedDay.weekday));
                return InkWell(
                  splashColor: Colors.transparent,
                  onTap: (){
                    setState(() {
                      _currentIndex=index;
                      _timeSelected=true;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _currentIndex == index ? Colors.white : Colors.black,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      color: _currentIndex==index ? Colors.blueAccent.shade700 : null,
                    ),
                    alignment: Alignment.center,
                    child: Text("${index+9}:00 ${index+9 > 11 ?'PM':'AM'}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _currentIndex==index ? Colors.white:null,
                      ),
                    ),
                  ),
                );
                },
                childCount: 8,
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

                  storeAppointmentDetails();
                },
                disable :_timeSelected && _dateSelected ? false: true,
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
          if(selectedDay.weekday==6 || selectedDay.weekday==7){
            _isWeekend=true;
            _timeSelected=false;
            _currentIndex=null;
          }
          else{
            _isWeekend=false;
          }
        });
      },
    );
  }
  final CollectionReference appointmentsCollection = FirebaseFirestore.instance.collection('appointments');

  // Create a reference to the doctor's appointments subcollection
  final CollectionReference doctorAppointmentsCollection =
  FirebaseFirestore.instance.collection('doctor').doc('email').collection('appointments');

// Create a reference to the patient's appointments subcollection
  final CollectionReference patientAppointmentsCollection =
  FirebaseFirestore.instance.collection('patients').doc('pemail').collection('appointments');

// Inside your _BookingPageState class

  void storeAppointmentDetails() async {
    // Check if the required fields are selected
    if (!_dateSelected || !_timeSelected) {// Handle the case where date and time are not selected.
      return;
    }

    // Create an appointment object with the relevant data
    Map<String, dynamic> appointmentData = {
      'appointment_time': _currentDay.toUtc(),
      'doctor_name': doctorInfo['name'],
      'patient_name': patientData['name'],
      'status': "upcoming",
    };

    try {
      // Add the appointment data to Firestore
      await appointmentsCollection.add(appointmentData);
      await doctorAppointmentsCollection.add(appointmentData);
      await patientAppointmentsCollection.add(appointmentData);


      // Show a success message or navigate to a success screen
      // (You can customize this part based on your application logic)
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
                  title: "Back to Home.",
                  disable: false,
                  onPressed: () => Navigator.of(context).pushNamed('main')),
            ),
          ],
        );
      }));
    } catch (e) {
      // Handle any errors that occur during Firestore data addition
      print("Error adding appointment: $e");
      // You can display an error message or take appropriate action here.
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
        onPressed: disable ? null : onPressed,
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








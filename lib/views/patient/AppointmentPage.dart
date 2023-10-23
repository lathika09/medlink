import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({Key? key,required this.email}) : super(key: key);
  final String email;

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

enum FilterStatus {Request,Confirm,Cancel}

class _AppointmentPageState extends State<AppointmentPage> {
  FilterStatus status = FilterStatus.Request;
  Alignment _alignment = Alignment.centerLeft;

  // reference for appointment collection
  final CollectionReference appointmentCollection = FirebaseFirestore.instance.collection('appointments');


  List<dynamic> schedules = [];

  Future<void> deletePastAppointments() async {
    final now = DateTime.now();
    final collection = FirebaseFirestore.instance.collection('appointments');

    final querySnapshot = await collection.get();

    for (final doc in querySnapshot.docs) {
      final appointmentDate = doc['appointment_date'] as Timestamp;
      final scheduleTime = doc['schedule_time'] as String;
      final patientName = doc['patient_name'] as String;
      final doctorName = doc['doctor_name'] as String;

      final appointmentDateTime = appointmentDate.toDate();
      final scheduleTimeParts = scheduleTime.split(' ');
      final time=scheduleTimeParts[0];
      final appointmentDateTimeWithTime = DateTime(
        appointmentDateTime.year,
        appointmentDateTime.month,
        appointmentDateTime.day,
        int.parse(time.split(':')[0]),
        int.parse(time.split(':')[1]),
      );

      if (appointmentDateTimeWithTime.isBefore(now)) {
        // delay or delete after acording to this time
        const int delayMilliseconds = 1 * 60 * 1000;
        await Future.delayed(Duration(milliseconds: delayMilliseconds));

        // patient and doctor collections to find matching documents
        final patientQuery = FirebaseFirestore.instance.collection('patients').where('name', isEqualTo: patientName);
        final doctorQuery = FirebaseFirestore.instance.collection('doctor').where('name', isEqualTo: doctorName);

        final patientSnapshot = await patientQuery.get();
        final doctorSnapshot = await doctorQuery.get();

        // Delete the document from the appoint collection
        await doc.reference.delete();

        // Delete the document from the patient's subcollection
        for (final patientDoc in patientSnapshot.docs) {
          final patientRef = patientDoc.reference.collection('appointments').doc(doc.id);
          await patientRef.delete();
        }

        // Delete the document from the doctor's subcollection
        for (final doctorDoc in doctorSnapshot.docs) {
          final doctorRef = doctorDoc.reference.collection('appointments').doc(doc.id);
          await doctorRef.delete();
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    deletePastAppointments();
    getDoctorAppointmentsByEmail(widget.email);
  }

  Future<void> getDoctorAppointmentsByEmail(String doctorEmail) async {
    try {
      final doctorQuery = await FirebaseFirestore.instance
          .collection('doctor')
          .where('email', isEqualTo: doctorEmail)
          .get();

      if (doctorQuery.docs.isEmpty) {
        return;
      }
      final doctorDoc = doctorQuery.docs.first;
      final doctorId = doctorDoc.id;
      final doctorRef = FirebaseFirestore.instance.collection('doctor').doc(doctorId);
      final doctorAppointmentsRef = doctorRef.collection('appointments');
      final querySnapshot = await doctorAppointmentsRef.get();

      for (final doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String doctorName = data['doctor_name'];
        String patientName = data['patient_name'];
        Timestamp? appointment_date = (data['appointment_date'] is Timestamp) ? data['appointment_date'] : null;
        String schedule_time = data['schedule_time'];
        String status = data['status'];
        DateTime dateTime = appointment_date!.toDate();
        final String formattedDate = DateFormat('EEEE, dd/MM/yyyy').format(dateTime);


        FilterStatus filterStatus = FilterStatus.values
            .firstWhere((e) => e.toString() == 'FilterStatus.' + status,
            orElse: () => FilterStatus.Request);

        schedules.add({
          'doctor_name': doctorName,
          'patient_name': patientName,
          'date': formattedDate,
          'time':schedule_time,
          'status': filterStatus,
          'appointment_id': doc.id,
        });
      }

      setState(() {});
    } catch (e) {
      print('Error fetching doctor appointments: $e');
    }
  }

  final CollectionReference appointmentSCollection =
  FirebaseFirestore.instance.collection('appointments');

  Future<void> updateAppointmentStatus(
      String appointmentId, String patientName, String newStatus) async {
    try {
      final appointRef = appointmentSCollection.doc(appointmentId);
      await appointRef.update({'status': newStatus.toString()});

      // Update the patient's appointment subcollection
      final patientQuery = await FirebaseFirestore.instance
          .collection('patients')
          .where('name', isEqualTo: patientName)
          .get();
      if (patientQuery.docs.isNotEmpty) {
        final patientId = patientQuery.docs.first.id;
        final patientRef =
        FirebaseFirestore.instance.collection('patients').doc(patientId);
        final patientAppointmentRef =
        patientRef.collection('appointments').doc(appointmentId);
        final patientAppointmentDoc = await patientAppointmentRef.get();
        if (patientAppointmentDoc.exists) {
          await patientAppointmentRef.update({'status': newStatus.toString()});
        }
      }

      // Update the doctor's appointment subcollection
      final doctorQuery = await FirebaseFirestore.instance
          .collection('doctor')
          .where('email', isEqualTo: widget.email)
          .get();
      if (doctorQuery.docs.isNotEmpty) {
        final doctorId = doctorQuery.docs.first.id;
        final doctorRef =
        FirebaseFirestore.instance.collection('doctor').doc(doctorId);
        final doctorAppointmentRef =
        doctorRef.collection('appointments').doc(appointmentId);
        final doctorAppointmentDoc = await doctorAppointmentRef.get();
        if (doctorAppointmentDoc.exists) {
          await doctorAppointmentRef.update({'status': newStatus.toString()});
        }
      }
      schedules.clear();
      await getDoctorAppointmentsByEmail(widget.email);

    } catch (e) {
      print('Error updating appointment status: $e');
    }
  }



  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String? email = arguments?['email'] as String?;
    print(email);

    List<dynamic> filteredSchedules = schedules.where((var schedule) {
      return schedule['status'] == status;
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left: 20, top: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Appointment Schedule',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 25,
              ),
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (FilterStatus filterStatus in FilterStatus.values)
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  status = filterStatus;
                                  if (filterStatus.name =="Request") {
                                    _alignment = Alignment.centerLeft;
                                  } else if (filterStatus.name ==
                                      "Confirm") {
                                    _alignment = Alignment.center;
                                  } else if (filterStatus.name =="Cancel") {
                                    _alignment = Alignment.centerRight;
                                  }
                                });
                              },
                              child: Center(
                                child: Text(filterStatus.name),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  AnimatedAlign(
                    alignment: _alignment,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      width: 100,
                      height: 40,
                      decoration: BoxDecoration(
                          color: Colors.blueAccent.shade700,
                          borderRadius: BorderRadius.circular(20)),
                      child: Center(
                        child: Text(
                          status.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 25,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredSchedules.length,
                  itemBuilder: ((context, index) {
                    var _schedule = filteredSchedules[index];
                    bool isLastElement = filteredSchedules.length + 1 == index;

                    // Get the appointment status
                    FilterStatus appointmentStatus = _schedule['status'];
                    return Card(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      margin: !isLastElement
                          ? EdgeInsets.only(bottom: 20)
                          : EdgeInsets.zero,
                      child: Padding(
                        padding: EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.blue,
                                    backgroundImage:NetworkImage("https://static.thenounproject.com/png/5034901-200.png"),
                                ),
                                SizedBox(
                                  width: 25,
                                ),
                                Text(
                                  _schedule['patient_name'],
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),

                              ],
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    color: Colors.indigo,
                                    size: 16,
                                  ),
                                  SizedBox(
                                    width: 4,
                                  ),
                                  Text(
                                    _schedule['date'],
                                    style: const TextStyle(
                                        color: Colors.indigo,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Icon(
                                    Icons.access_alarm,
                                    color: Colors.indigo,
                                    size: 16,
                                  ),
                                  SizedBox(
                                    width: 4,
                                  ),
                                  Flexible(
                                    child: Text(
                                      _schedule['time'],
                                      style: TextStyle(
                                          color: Colors.indigo,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (appointmentStatus == FilterStatus.Request)
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: ()  {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text('Cancel Appointment'),
                                              content: Text('Are you sure you want to cancel this appointment?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    // Close the dialog
                                                    Navigator.of(context).pop();
                                                    },
                                                  child: Text('No'),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    // Close the dialog
                                                    Navigator.of(context).pop();
                                                    await updateAppointmentStatus(
                                                        _schedule['appointment_id'],
                                                        _schedule['patient_name'],
                                                        "Cancel");
                                                    },
                                                  child: Text('Yes'),
                                                ),
                                              ],
                                            );
                                            },
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      child: Text(
                                        'Cancel',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                if (appointmentStatus == FilterStatus.Request)
                                  SizedBox(width: 20),
                                if (appointmentStatus == FilterStatus.Request)
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: (){
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text('Confirm Appointment'),
                                              content: Text('Are you sure you want to confirm this appointment?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    // Close the dialog
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    // Close the dialog
                                                    Navigator.of(context).pop();

                                                    await updateAppointmentStatus(
                                                      _schedule['appointment_id'],
                                                      _schedule['patient_name'],
                                                      "Confirm",
                                                    );
                                                  },
                                                  child: Text('Confirm'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                      ),
                                      child: Text(
                                        'Confirm',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
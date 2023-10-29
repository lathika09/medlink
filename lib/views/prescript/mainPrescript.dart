import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:medlink/views/prescript/addPrescript.dart';

import 'editPrescript.dart';

class MainPrescript extends StatefulWidget {
  const MainPrescript({Key? key, required this.patientEmail,  required this.doctorId, required this.doctorEmail}) : super(key: key);
final String patientEmail;
final String doctorId;
final String doctorEmail;

  @override
  State<MainPrescript> createState() => _MainPrescriptState();
}

class _MainPrescriptState extends State<MainPrescript> {
  Map<String, dynamic> patientData = {};
  Future<void> fetchPatientData() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection("patients").where("email", isEqualTo: widget.patientEmail).get();
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
      final snapshot = await FirebaseFirestore.instance.collection("doctor").where("email", isEqualTo: widget.doctorEmail).get();
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
  @override
  void initState() {
    super.initState();
    fetchDoctorData();
    fetchPatientData();
    // doctorID = widget.doctorId;
  }
  Future<List<PrescriptionData>> fetchPrescriptionsForPatient(String doctorId,String patientEmail) async {
    try {
      // Reference the patient's subcollection of prescriptions
      CollectionReference patientPrescriptionsCollection = FirebaseFirestore.instance.collection('doctor/$doctorId/patients/$patientEmail/prescriptions');

      QuerySnapshot querySnapshot = await patientPrescriptionsCollection.get();

      List<PrescriptionData> prescriptions = querySnapshot.docs.map((doc) {
        Map<String, dynamic> prescriptionData = doc.data() as Map<String, dynamic>;

        // Access fields from the document with null checks
        String doctorId = (prescriptionData['doctorId'] is String) ? prescriptionData['doctorId'] : '';
        String doctorName = (prescriptionData['doctorName'] is String) ? prescriptionData['doctorName'] : '';

        String patientId = (prescriptionData['patientId'] is String) ? prescriptionData['patientId'] : '';
        String patientName = (prescriptionData['patientName'] is String) ? prescriptionData['patientName'] : '';
        String patientEmail = (prescriptionData['patientEmail'] is String) ? prescriptionData['patientEmail'] : '';

        Map<String, dynamic> medicines = (prescriptionData['medicines'] is Map) ? prescriptionData['medicines'] : {};
        String time = (prescriptionData['time'] is String) ? prescriptionData['time'] : '';

        // Add more fields as needed

        return PrescriptionData(
          doctorId: doctorId,
          doctorName: doctorName,
          patientId:patientId,
          patientName:patientName,
          patientEmail:patientEmail,
          medicines: medicines,

          time: time,
          // Add more fields here to match your PrescriptionData class.
        );
      }).toList();

      return prescriptions;
    } catch (e) {
      print('Error fetching prescriptions: $e');
      return []; // Return an empty list or handle the error as needed.
    }
  }





  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _usersStream =
    FirebaseFirestore.instance.collection('doctor/${widget.doctorId}/patients/${widget.patientEmail}/prescriptions').snapshots();
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent.shade700,
        onPressed: () {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => AddPrescript(patientEmail: widget.patientEmail, doctorId: widget.doctorId, doctorEmail: widget.doctorEmail)));
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
      ),
      appBar: AppBar(
        leading: IconButton(onPressed: (){}, icon:Icon(Icons.arrow_back,color: Colors.white,)),
        backgroundColor: Colors.blueAccent.shade700,//Color.fromARGB(255, 0, 11, 133)
        title: Text('Prescription List ',style: TextStyle(color: Colors.white,fontSize: 24),),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              child: Column(
                children: [
                  if (doctorData['id'] != null)
                    FutureBuilder<List<PrescriptionData>>(
                      future: fetchPrescriptionsForPatient(widget.doctorId,widget.patientEmail),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return  Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          List<PrescriptionData> prescripts = snapshot.data ?? [];

                          return ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: prescripts.length,
                            itemBuilder: (context, index) {
                              return prescripts[index];
                            },

                          );
                        }
                      },
                    ),
                ],
              ),
            ),

          )),

    );
  }
}

class PrescriptionData extends StatefulWidget {
  const PrescriptionData({Key? key, required this.doctorId, required this.doctorName, required this.medicines, required this.time, required this.patientId, required this.patientName, required this.patientEmail}) : super(key: key);
final String doctorId;
final String doctorName;
final String patientId;
final String patientName;
final String patientEmail;
final  Map<String, dynamic> medicines;
final String time;
  @override
  State<PrescriptionData> createState() => _PrescriptionDataState();
}

class _PrescriptionDataState extends State<PrescriptionData> {

  Future<DocumentSnapshot> fetchPrescriptionDocumentForPatient(String doctorId,String patientEmail, String prescriptionId) async {
    try {
      // Reference the patient's subcollection of prescriptions and get the specific prescription document
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .doc('doctor/$doctorId/patients/$patientEmail/prescriptions/$prescriptionId')
          .get();

      if (documentSnapshot.exists) {
        return documentSnapshot; // Return the DocumentSnapshot if it exists.
      } else {
        throw Exception('Prescription document not found'); // Handle the case when the document doesn't exist.
      }
    } catch (e) {
      print('Error fetching prescription document: $e');
      throw e; // Re-throw the error or handle it as needed.
    }
  }

  // Map<String, dynamic> prescriptionDocument = {};
  // Future<void> fetchPrescribeData(String doctorId,String patientEmail, String prescriptionId) async {
  //   try {
  //     final snapshot = await  fetchPrescriptionDocumentForPatient(doctorId, patientEmail, prescriptionId);
  //     if (snapshot.exists) {
  //       setState(() {
  //         prescriptionDocument = snapshot.data() as Map<String, dynamic>;
  //         print(prescriptionDocument['patientName']);
  //         print("PRINT THIS : ${prescriptionDocument['id']}");
  //       });
  //     }
  //   } catch (e) {
  //     print("Error fetching doctor data: $e");
  //   }
  // }

//fetchPrescriptionDocumentForPatient(widget.doctorId, widget.patientEmail, widget.time),
  @override
  void initState() {
    super.initState();
    // fetchPrescribeData(widget.doctorId,widget.patientEmail,widget.time);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
      height: MediaQuery.of(context).size.height*0.16,
      child: GestureDetector(
        child: Card(
          elevation: 5,
          color: Colors.greenAccent,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                Flexible(
                  child: Padding(
                    padding:
                    EdgeInsets.symmetric(horizontal: 5, vertical: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width:MediaQuery.of(context).size.width*0.7,
                              padding: EdgeInsets.symmetric(horizontal: 7),
                              child: Text(
                                widget.time,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                                softWrap: true,
                              ),
                            ),

                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        onTap: () async {
          DocumentSnapshot? prescribeDocument = await fetchPrescriptionDocumentForPatient(widget.doctorId, widget.patientEmail, widget.time);
          setState(() {
            if (prescribeDocument != null) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => EditPrescript(
                    docid: prescribeDocument,
                    doctorId: widget.doctorId,
                    pemail: widget.patientEmail,
                  ),
                ),
              );
            } else {
              print("ERROR OCCURRED $prescribeDocument");
            }
          });
        },

      ),
    );
  }
}






// StreamBuilder(
// stream: _usersStream,
// builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
// if (snapshot.hasError) {
// return Text("something is wrong");
// }
// if (snapshot.connectionState == ConnectionState.waiting) {
// return Center(
// child: CircularProgressIndicator(),
// );
// }
// if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
// return Container(
// decoration: BoxDecoration(
// borderRadius: BorderRadius.circular(12),
// ),
// child: ListView.builder(
// itemCount: snapshot.data!.docs.length,
// itemBuilder: (_, index) {
// return GestureDetector(
// onTap: () {
// Navigator.pushReplacement(
// context,
// MaterialPageRoute(
// builder: (_) => EditPrescript(
// docid: snapshot.data!.docs[index],
// doctorId: widget.doctorId,
// pemail: widget.patientEmail,
// )),
// );
// },
// child: Column(
// children: [
// SizedBox(
// height: 4,
// ),
// Padding(
// padding: EdgeInsets.only(
// left: 3,
// right: 3,
// ),
// child: ListTile(
// shape: RoundedRectangleBorder(
// borderRadius: BorderRadius.circular(10),
// side: BorderSide(
// color: Colors.black,
// ),
// ),
// title: Text(
// snapshot.data!.docChanges[index].doc['time'],
// style: TextStyle(
// fontSize: 20,
// ),
// ),
// contentPadding: EdgeInsets.symmetric(
// vertical: 12,
// horizontal: 16,
// ),
// ),
// ),
// ],
// ),
// );
// },
// ),
// );
// }
// else{
// return CircularProgressIndicator();
// }
// },
// ),
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medlink/views/prescript/prescribed.dart';

import '../../constant/image_string.dart';
import 'mainPrescript.dart';

class EditPrescript extends StatefulWidget {
  const EditPrescript({Key? key, required this.docid, required this.doctorId, required this.pemail}) : super(key: key);
  final DocumentSnapshot docid;
  final String doctorId;
  final String pemail;
  @override
  State<EditPrescript> createState() => _EditPrescriptState();
}

class _EditPrescriptState extends State<EditPrescript> {
  TextEditingController pname = TextEditingController();
  TextEditingController docName = TextEditingController();
  TextEditingController did = TextEditingController();
  TextEditingController pid = TextEditingController();
  TextEditingController pemail = TextEditingController();
  TextEditingController diagnosis = TextEditingController();
  TextEditingController medicineNameController = TextEditingController();
  TextEditingController dosageController = TextEditingController();


  Map<String, dynamic> patientData = {};
  Future<void> fetchPatientData() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection("patients").where("email", isEqualTo: widget.pemail).get();
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          patientData = snapshot.docs.first.data() as Map<String, dynamic>;
          print(patientData['name']);
          pid.text=patientData['id']?? "";
          pname.text =patientData['name']?? "";
          pemail.text=patientData['email']?? "";

        });
      }
    } catch (e) {
      print("Error fetching doctor data: $e");
    }
  }


  Map<String, dynamic> doctorData = {};
  Future<void> fetchDoctorData() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection("doctor").where("id", isEqualTo: widget.doctorId).get();
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          doctorData = snapshot.docs.first.data() as Map<String, dynamic>;

          print(doctorData);

          did.text=doctorData['id']?? "";
          docName.text = doctorData["name"] ?? "";


        });
      }
    } catch (e) {
      print("Error fetching doctor data: $e");
    }
  }
  Map<String, dynamic> prescript = {};
  Future<void> fetchPrescriptrData(String doctorId,String pemail) async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('doctor/${doctorId}/patients/${pemail}/prescriptions').get();
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          prescript = snapshot.docs.first.data() as Map<String, dynamic>;

          print(prescript);
          diagnosis.text = prescript["diagnosis"] ?? "";
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
    fetchPrescriptrData(widget.doctorId,widget.pemail);

//     Map<String, dynamic> medicinesMap = widget.docid['medicines'];
//     List<String> medicineKeys = medicinesMap.keys.toList();
//
// // Create a list of TextEditingControllers for medicine keys
//     List<TextEditingController> medicineKeyControllers = [];
//     List<TextEditingController> medicineValueControllers = [];
//
//     for (String key in medicineKeys) {
//       TextEditingController keyController = TextEditingController(text: key);
//       medicineKeyControllers.add(keyController);
//
//       TextEditingController valueController = TextEditingController(text: medicinesMap[key]);
//       medicineValueControllers.add(valueController);
//     }
//
// // Now you can access the keys and values using these controllers
//     for (int i = 0; i < medicineKeyControllers.length; i++) {
//       TextEditingController keyController = medicineKeyControllers[i];
//       TextEditingController valueController = medicineValueControllers[i];
//
//       String medicineKey = keyController.text;
//       String medicineValue = valueController.text;
//
//       print("Medicine Key: $medicineKey");
//       print("Medicine Value: $medicineValue");
//     }

  }
  @override
  Widget build(BuildContext context) {


    Map<String, dynamic> medicinesMap = widget.docid['medicines'];
    List<TextEditingController> medicineNameControllers = [];
    List<TextEditingController> dosageControllers = [];

    medicinesMap.forEach((medicineName, dosage) {
      TextEditingController nameController = TextEditingController(text: medicineName);
      TextEditingController dosageController = TextEditingController(text: dosage);

      medicineNameControllers.add(nameController);
      dosageControllers.add(dosageController);
    });

    Map<String, String> medicines = {};

    for (int i = 0; i < medicineNameControllers.length; i++) {
      String medName = medicineNameControllers[i].text;
      String dose= dosageControllers[i].text;

      medicines[medName] = dose;
    }
    return
      Scaffold(
        appBar:AppBar(
          backgroundColor:Colors.blueAccent.shade700,
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
          leading: IconButton(
              onPressed: () async {
                // Navigator.pop(context);
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) =>MainPrescript(patientEmail: widget.pemail, doctorId: widget.doctorId, doctorEmail:doctorData['email']))
                );
                // await FirebaseAuth.instance.signOut();
              },
              icon: const Icon(
                Icons.arrow_back,
                size:20,
                color: Colors.white,)
          ),

          title:Text(appname,
            style: TextStyle(
                fontSize: 30,
                color: Colors.white,
                fontWeight: FontWeight.bold),
          ),
          elevation: 24.0,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.refresh,size: 30,color: Colors.blueAccent.shade700,),
              onPressed: () {
              },
            ),
          ],
        ),

        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(border: Border.all(),color: Colors.blue.shade100),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Patient Name :",
                        style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500,color: Colors.black87),
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: TextField(
                          style: TextStyle(fontSize: 18),
                          controller: pname,
                          maxLines: null,
                          // keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Patient Name',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                decoration: BoxDecoration(border: Border.all(),color: Colors.blue.shade100),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Doctor Name :",
                        style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500,color: Colors.black87),
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: TextField(
                          style: TextStyle(fontSize: 18),
                          controller: docName,
                          maxLines: null,
                          // keyboardType: TextInputType.number,
                          decoration: InputDecoration(

                            hintText: 'Doctor Name',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                decoration: BoxDecoration(border: Border.all(),color: Colors.blue.shade100),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Email :",
                        style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500,color: Colors.black87),
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: TextField(
                          style: TextStyle(fontSize: 18),
                          controller: pemail,
                          maxLines: null,
                          // keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Patient Email',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                decoration: BoxDecoration(border: Border.all(),color: Colors.blue.shade100),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Diagnosis :",
                        style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500,color: Colors.black87),
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: TextField(
                          controller: diagnosis,
                          style: TextStyle(fontSize: 18),
                          maxLines: null,
                          // keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Diagnosis',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 15,
              ),
              // Medicine input section
              Column(
                children: List.generate(medicineNameControllers.length, (index) {
                  return Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(border: Border.all(),color: Colors.blue.shade100),
                          child: TextField(
                            style: TextStyle(fontSize: 18),
                            controller: medicineNameControllers[index],
                            decoration: InputDecoration(hintText: 'Medicine Name'),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(border: Border.all(),color: Colors.blue.shade100),
                          child: TextField(
                            style: TextStyle(fontSize: 18),
                            controller: dosageControllers[index],
                            decoration: InputDecoration(hintText: 'Dosage'),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),

              SizedBox(height:25),
              // Save button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      // DateTime now = DateTime.now();
                      // String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
                      CollectionReference ref = FirebaseFirestore.instance.collection('doctor/${widget.doctorId}/patients/${widget.pemail}/prescriptions');
                      final  presc_data={
                        'patientId':pid.text,
                        'patientName': pname.text,
                        'patientEmail':pemail.text,
                        'doctorId':did.text,
                        'doctorName': docName.text,
                        'diagnosis':diagnosis.text,
                        'time':widget.docid.get("time"),
                        'medicines': medicines,};
                      await ref.doc(widget.docid.get("time")).set(presc_data, SetOptions(merge: true)).whenComplete(() {
                        Navigator.pushReplacement(
                          context, MaterialPageRoute(builder: (_) => MainPrescript(patientEmail: widget.pemail, doctorId: widget.doctorId, doctorEmail: doctorData['email'])),
                        );
                      });
                    },
                    child: Text('Save',style: TextStyle(fontSize: 20),),
                  ),
                  SizedBox(width: 10,),
                  ElevatedButton(
                      onPressed: () {
                    widget.docid.reference.delete().whenComplete(() {
                      Navigator.pushReplacement(
                          context, MaterialPageRoute(builder: (context) =>  MainPrescript(patientEmail: widget.pemail, doctorId: widget.doctorId, doctorEmail: doctorData['email'],)));
                    });
                  }, child: Text(
                    "Delete",
                    style: TextStyle(fontSize: 20),

                  ),),

                ],
              ),
              SizedBox(height: 20,),
              MaterialButton(
                elevation: 10,
                color: Colors.blueAccent.shade700,
                onPressed: () async {
                  CollectionReference ref = FirebaseFirestore.instance.collection('doctor/${widget.doctorId}/patients/${widget.pemail}/prescriptions');
                  final  presc_data={
                    'patientId':pid.text,
                    'patientName': pname.text,
                    'patientEmail':pemail.text,
                    'doctorId':did.text,
                    'doctorName': docName.text,
                    'diagnosis':diagnosis.text,
                    'time':widget.docid.get("time"),
                    'medicines': medicines,};
                  await ref.doc(widget.docid.get("time")).set(presc_data, SetOptions(merge: true)).whenComplete(() {
                    Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (_) => PrescribeReport(
                      docid: widget.docid, medicines: widget.docid['medicines'],
                    ),),
                    );
                  });
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (_) => PrescribeReport(
                  //       docid: widget.docid, medicines: widget.docid['medicines'],
                  //     ),
                  //   ),
                  // );
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Make Report",
                    style: TextStyle(
                      fontSize: 24,
                      color: Color.fromARGB(255, 251, 251, 251),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}

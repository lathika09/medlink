import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constant/image_string.dart';
import 'mainPrescript.dart';


class AddPrescript extends StatefulWidget {
  const AddPrescript({Key? key, required this.patientEmail, required this.doctorId, required this.doctorEmail}) : super(key: key);
  final String patientEmail;
  final String doctorId;
  final String doctorEmail;
  @override
  State<AddPrescript> createState() => _AddPrescriptState();
}

class _AddPrescriptState extends State<AddPrescript> {




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
      final snapshot = await FirebaseFirestore.instance.collection("patients").where("email", isEqualTo: widget.patientEmail).get();
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
      final snapshot = await FirebaseFirestore.instance.collection("doctor").where("email", isEqualTo: widget.doctorEmail).get();
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


  @override
  void initState() {
    super.initState();
    fetchDoctorData();
    fetchPatientData();

  }
  Map<String, String> medicines = {};
  @override
  Widget build(BuildContext context) {

    void addEmptyMedicineEntry() {
      setState(() {
        medicines[''] = '';
        print("ADD MEDICINE :$medicines");
      });
    }
    CollectionReference ref = FirebaseFirestore.instance.collection('doctor/${widget.doctorId}/patients/${widget.patientEmail}/prescriptions');
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
                  context, MaterialPageRoute(builder: (context) =>MainPrescript(patientEmail: widget.patientEmail, doctorId: widget.doctorId, doctorEmail: widget.doctorEmail))
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
              decoration: BoxDecoration(border: Border.all()),
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
                        controller: pname,
                        style: TextStyle(fontSize: 18),
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


            Container(
              decoration: BoxDecoration(border: Border.all()),
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
                        controller: docName,
                        maxLines: null,
                        style: TextStyle(fontSize: 18),
                        decoration: InputDecoration(
                          hintText: 'Doctor Name',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(border: Border.all()),
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
                        maxLines: null,
                        style: TextStyle(fontSize: 18),
                        decoration: InputDecoration(
                          hintText: 'Diagnosis',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Medicine input section
            Column(

              children:  medicines.entries.map((MapEntry<String, dynamic> entry) {
                print("ENTRY${diagnosis}");
                final medicineNameController = TextEditingController(text: entry.key);
                final dosageController = TextEditingController(text: entry.value);
                print("object:${medicineNameController}");
                return Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding:EdgeInsets.symmetric(horizontal:10),
                        decoration: BoxDecoration(border: Border.all()),
                        child: TextField(
                          textAlign:TextAlign.left,
                          controller: medicineNameController,
                          decoration: InputDecoration(
                            hintText: 'Medicine Name',
                          ),

                          onChanged: (value) {
                            setState(() {

                              // TextPosition cursorPosition = medicineNameController.selection.base;
                              // // print("CURRENT POS :${cursorPosition}");
                              // // int newPosition = cursorPosition.offset+1;
                              // medicineNameController.selection = TextSelection.collapsed(offset: cursorPosition.offset);
                              medicines.remove(entry.key);
                              medicines[value] = dosageController.text;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(border: Border.all()),
                        child: TextField(

                          // textDirection: TextDirection.LTR,
                          controller: dosageController,
                          decoration: InputDecoration(
                            hintText: 'Dosage',

                          ),
                          onChanged: (value) {
                            setState(() {
                              // int newPosition = value.length+1;
                              // TextSelection newSelection = TextSelection.collapsed(offset: newPosition);
                              // dosageController.selection = newSelection;

                              // medicines[entry.key] = value;
                              medicines[medicineNameController.text] = value;
                              print(value);

                            });
                          },

                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),

              ElevatedButton(
                onPressed: () {
                  setState(() {
                    medicines[''] = '';
                  });
                },
                child: Text('Add Medicine'),
              ),




            // Save button
            ElevatedButton(
              onPressed: () async {
                DateTime now = DateTime.now();
                String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
               final  presc_data={
                 'patientId':pid.text,
                 'patientName': pname.text,
                 'patientEmail':widget.patientEmail,
                 'doctorId':did.text,
                 'doctorName': docName.text,
                 'diagnosis':diagnosis.text,
                 'time':formattedDate,
                 'medicines': medicines,};
                await ref.doc(formattedDate).set(presc_data).whenComplete(() {
                  _showSuccessDialog(context,"Prescription Added");
                });
              },
              child: Text('Save Prescription'),
            ),
          ],
        ),
      ),
    );
  }
  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (_) => MainPrescript(patientEmail: widget.patientEmail, doctorId: widget.doctorId, doctorEmail: widget.doctorEmail,)));
              },
            ),
          ], 
        );
      },
    );
  }
}

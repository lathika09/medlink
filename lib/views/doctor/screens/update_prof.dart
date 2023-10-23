import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../constant/image_string.dart';

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({Key? key}) : super(key: key);
  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  String? _profileImageUrl;
  
  Map<String, int> dayNameToValue = {
    'Monday': 1,
    'Tuesday': 2,
    'Wednesday': 3,
    'Thursday': 4,
    'Friday': 5,
    'Saturday': 6,
    'Sunday': 7,
  };

  Map<int, String> dayValueToName = {
    1: 'Monday',
    2: 'Tuesday',
    3: 'Wednesday',
    4: 'Thursday',
    5: 'Friday',
    6: 'Saturday',
    7: 'Sunday',
  };
  List<int> selectedWeekdayIntegers = [];
  List<String> selectedWeekdays = [];

  List<MultiSelectItem<String>> weekdayItems = [
    MultiSelectItem<String>('Monday', 'Monday'),
    MultiSelectItem<String>('Tuesday', 'Tuesday'),
    MultiSelectItem<String>('Wednesday', 'Wednesday'),
    MultiSelectItem<String>('Thursday', 'Thursday'),
    MultiSelectItem<String>('Friday', 'Friday'),
    MultiSelectItem<String>('Saturday', 'Saturday'),
    MultiSelectItem<String>('Sunday', 'Sunday'),
  ];

  List<String> selectedSlot = [];
  List<MultiSelectItem<String>> timeItems = [
    MultiSelectItem<String>('7:00 AM', '7:00 AM'),
    MultiSelectItem<String>('8:00 AM', '8:00 AM'),
    MultiSelectItem<String>('9:00 AM', '9:00 AM'),
    MultiSelectItem<String>('10:00 AM', '10:00 AM'),
    MultiSelectItem<String>('11:00 AM', '11:00 AM'),
    MultiSelectItem<String>('12:00 PM', '12:00 PM'),
    MultiSelectItem<String>('13:00 PM', '13:00 PM'),
    MultiSelectItem<String>('14:00 PM', '14:00 PM'),
    MultiSelectItem<String>('15:00 PM', '15:00 PM'),
    MultiSelectItem<String>('16:00 PM', '16:00 PM'),
    MultiSelectItem<String>('17:00 PM', '17:00 PM'),
    MultiSelectItem<String>('18:00 PM', '18:00 PM'),
    MultiSelectItem<String>('19:00 PM', '19:00 PM'),
    MultiSelectItem<String>('20:00 PM', '20:00 PM'),
    MultiSelectItem<String>('21:00 PM', '21:00 PM'),
    MultiSelectItem<String>('22:30 PM', '22:30 PM'),
    // Add more time slots as needed
  ];

  final TextEditingController _name = TextEditingController();
  final TextEditingController _exp= TextEditingController();
  final TextEditingController _city= TextEditingController();
  final TextEditingController _spec= TextEditingController();
  final TextEditingController _qua= TextEditingController();
  final TextEditingController _bio= TextEditingController();
  final TextEditingController _add= TextEditingController();
  final TextEditingController _hos= TextEditingController();

  bool isEditing = false;
  Map<String, dynamic> doctorData = {};


// Fetch doctor data from Firestore based on the email
  Future<void> fetchDoctorData() async {
    final Map<String, dynamic>? arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String? email = arguments?['email'] as String?;

    try {
      final snapshot = await FirebaseFirestore.instance.collection("doctor").where("email", isEqualTo: email).get();
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          doctorData = snapshot.docs.first.data();//as Map<String, dynamic>
          final List<dynamic> time = (doctorData["availability"] != null && doctorData["availability"]["time"] != null)  ? List.from(doctorData["availability"]["time"]): <dynamic>[];
          final List<dynamic> weekdays = (doctorData["availability"] != null && doctorData["availability"]["weekday"] != null) ? List.from(doctorData["availability"]["weekday"]) : <dynamic>[];
          print(weekdays);
          // converting weekday integers to weekday strings
          selectedWeekdayIntegers = weekdays.cast<int>(); // cast the list to List<int>
          selectedWeekdays = weekdays.map((intVal) => dayValueToName[intVal] ?? '').toList();
          print(doctorData);

          // Set the text controllers with the fetched data
          _name.text = doctorData["name"] ?? "";
          _exp.text = doctorData["experience"] ?? "";
          _city.text = doctorData["city"] ?? "";
          _spec.text = (doctorData["speciality"] as List<dynamic>?)?.join(", ") ?? "";
          _qua.text = doctorData["qualification"] ?? "";
          _bio.text = doctorData["description"] ?? "";
          _add.text = doctorData["address"] ?? "";
          _hos.text = doctorData["hospital"] ?? "";

          selectedSlot=time.cast<String>();

        });
      }
    } catch (e) {
      print("Error fetching doctor data: $e");
    }
  }


  Future<void> uploadImageToFirebaseStorage(File imageFile, String Email) async {
    try {
      final Reference storageReference =
      FirebaseStorage.instance.ref().child('prof_images/$Email.jpg');

      final UploadTask uploadTask = storageReference.putFile(imageFile);

      await uploadTask.whenComplete(() async {
        final imageUrl = await storageReference.getDownloadURL();
        print('Image uploaded to Firebase Storage: $imageUrl');

        final querySnap =await FirebaseFirestore.instance.collection('doctor').where("email", isEqualTo: Email).get();
        // await FirebaseFirestore.instance.collection('doctor').doc(Email).update({
        //   'prof_image': imageUrl,
        // });

        if (querySnap.docs.isNotEmpty) {
          // Get the first document found
          final doctorDocument = querySnap.docs.first;

          // Update the document with the new data
          await doctorDocument.reference.update({
            'prof_image': imageUrl,
          });
        }
        else {
          print("No document found with email: $Email");
        }

        print('Image URL saved in Firestore.');
      });
    } catch (e) {
      print('Error uploading image to Firebase Storage: $e');
    }
  }
  Future<void> _onImagePickerButtonPressed() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      final Map<String, dynamic>? arguments =
      ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final String? email = arguments?['email'] as String?;

      if (email != null) {
        uploadImageToFirebaseStorage(imageFile, email);
        // final imageUrl = await getProfileImageUrl(email!);
        // if (imageUrl != null) {
        //   setState(() {
        //     _profileImageUrl = imageUrl;
        //   });
        // }
      }

    }
  }

  Future<void> loadProfileImage() async {
    final Map<String, dynamic>? arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String? email = arguments?['email'] as String?;
    print(email);
    final imageUrl = await getProfileImageUrl(email!);
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

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    fetchDoctorData();
    loadProfileImage();

  }
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

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String? email = arguments?['email'] as String?;
    print(email);
    Widget buttons;

    return Scaffold(
        appBar:AppBar(
          backgroundColor:Colors.blueAccent.shade700,
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
          title:Center(
            child: Text(appname,
              style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
          elevation: 24.0,
          actions: <Widget>[IconButton(
            icon: Icon(Icons.refresh,size: 30,color: Colors.white,),
            onPressed: () {
              // Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateProfile()),);
              loadProfileImage();
            },
          ),
          ],
        ),
        body:SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 22,),
              Center(
                child: Stack(
                  // alignment: AlignmentDirectional.topStart,
                  // fit: StackFit.expand,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: _profileImageUrl != null
                          ? NetworkImage(_profileImageUrl!)
                          :NetworkImage("https://www.pngitem.com/pimgs/m/421-4212266_transparent-default-avatar-png-default-avatar-images-png.png"), // Provide a default image

                    ),
                    Positioned(
                      child: IconButton(
                        onPressed:() async{
                          print("pressed");
                          _onImagePickerButtonPressed();
                          // loadProfileImage();
                        },
                        icon: Icon(Icons.add_a_photo),
                        iconSize: 30,
                        color: Colors.black,
                      ),
                      bottom: -1,
                      left: 80,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20,),
                Container(
                padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10
                ),
                child: Column(
                  children: [
                    //name
                    buildTextField("Name :",_name),
                    SizedBox(height: 15,),
                    //spec
                    buildTextField("Speciality :",_spec),
                    SizedBox(height: 15,),
                    //exp
                    buildTextField("Experience :",_exp),
                    SizedBox(height: 10,),
                    //hos
                    buildTextField("Hospital :",_hos),
                    SizedBox(height: 15,),
                    //city
                    buildTextField("City :",_city),
                    SizedBox(height: 15,),
                    //addr
                    buildTextField("Address :",_add),
                    SizedBox(height: 15,),
                    //qualification
                    buildTextField("Qualification :",_qua),
                    SizedBox(height: 15,),
                    //Time
                    // buildTextField("Available Time :",_time),
                    // SizedBox(height: 15,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Available Time :",
                          style:  TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        AbsorbPointer(
                          absorbing: !isEditing,//used to eanable editing
                          child: MultiSelectDialogField(
                            items: timeItems,

                            initialValue:selectedSlot,
                            listType: MultiSelectListType.CHIP,
                            onConfirm: (values) {
                              setState(() {
                                selectedSlot = values.toList();
                                // Convert selected weekday strings to integers
                                // selectedWeekdayIntegers = selectedSlot.map((weekday) => dayNameToValue[weekday]!).toList();

                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15,),
                    //week
                    // buildMultiSelectField("WeekDay :",selectedWeekdays),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "WeekDay :",
                          style:  TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        AbsorbPointer(
                          absorbing: !isEditing,
                          child: MultiSelectDialogField(
                            items: weekdayItems,

                            initialValue:selectedWeekdays,
                            listType: MultiSelectListType.CHIP,
                            onConfirm: (values) {
                              setState(() {
                                selectedWeekdays = values;
                                // Convert selected weekday strings to integers
                                selectedWeekdayIntegers = selectedWeekdays.map((weekday) => dayNameToValue[weekday]!).toList();

                              });
                            },

                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15,),
                    //bio
                    buildTextField("Bio :",_bio),
                    SizedBox(height: 30,),
                    buttons = isEditing ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        //SAVE BUUTTON
                        MaterialButton(
                          minWidth: MediaQuery.of(context).size.width/3,
                          height: 50,
                          onPressed:(){
                            onSaveButtonClick();
                          },
                          color: Colors.blue[600],
                          shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                  color:Colors.black
                              ),
                              borderRadius: BorderRadius.circular(50)
                          ),
                          child: const Text("Save",
                            style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Edit button
                        MaterialButton(
                          minWidth:MediaQuery.of(context).size.width/3,
                          height: 50,
                          onPressed:(){
                            onEditButtonClick();
                          },
                          color: Colors.blue[600],
                          shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                  color:Colors.black
                              ),
                              borderRadius: BorderRadius.circular(50)
                          ),
                          child: const Text("Edit",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),),
                        ),
                      ],
                    ),
                    SizedBox(height: 30,),
                  ],
                ),
              ),
            ],
          ),
        )
    );
  }
  // Edit button click handler
  void onEditButtonClick() {
    setState(() {
      isEditing = true; // Enable editing mode
    });
  }

  // Save button click handler
  void onSaveButtonClick() async {
    final Map<String, dynamic>? arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String? email = arguments?['email'] as String?;
    print("LATHIKA : ${selectedWeekdayIntegers}");

    // Update the Firestore document with new values
    final updatedData = {
      "name": _name.text,
      "speciality": _spec.text.split(',').map((e) => e.trim()).toList(),
      "experience": _exp.text,
      "hospital": _hos.text,
      "city": _city.text,
      "address": _add.text,
      "qualification": _qua.text,
      "availability": {
        "weekday": selectedWeekdayIntegers,
        "time":selectedSlot,
      },
      "description": _bio.text,
    };

    try {
      // find the document based on the doctor's email
      final querySnapshot = await FirebaseFirestore.instance
          .collection("doctor")
          .where("email", isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Get the first document found
        final doctorDoc = querySnapshot.docs.first;

        // Update the document with the new data
        await doctorDoc.reference.update(updatedData);

        // Disable editing mode after save
        setState(() {
          isEditing = false;
        });
      } else {
        print("No document found with email: $email");
      }
    } catch (e) {
      print("Error updating document: $e");
    }
  }
  // textStyles for both enabled and disabled states
  final enabledTextStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: Colors.black,
  );
  final disabledTextStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: Colors.black54,
  );


  Widget buildTextField(String label, TextEditingController controller) {
    final textStyle = isEditing ? enabledTextStyle : disabledTextStyle;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500,color: Colors.black87),
        ),
        const SizedBox(width:5),
        Flexible(
          child: TextField(
            style: textStyle,
            obscureText: false,
            controller:controller,
            enabled: isEditing,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 0,horizontal: 10),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0xFFBDBDBD),
                ),
              ),
              border:OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0xFFBDBDBD),
                ),
              ),
            ),
          ),
        ),
        // SizedBox(height:10),
      ],
    );
  }
}



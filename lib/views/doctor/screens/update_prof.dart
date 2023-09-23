import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  final TextEditingController _name = TextEditingController();
  final TextEditingController _exp= TextEditingController();
  final TextEditingController _city= TextEditingController();
  final TextEditingController _spec= TextEditingController();
  final TextEditingController _qua= TextEditingController();
  final TextEditingController _bio= TextEditingController();
  final TextEditingController _add= TextEditingController();
  final TextEditingController _hos= TextEditingController();
  final TextEditingController _time= TextEditingController();
  final TextEditingController _week= TextEditingController();

  bool isEditing = false;
  Map<String, dynamic> doctorData = {}; // Store the doctor's data


// Fetch doctor data from Firestore based on the email
  Future<void> fetchDoctorData() async {
    final Map<String, dynamic>? arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String? email = arguments?['email'] as String?;

    try {
      final snapshot = await FirebaseFirestore.instance.collection("doctor").where("email", isEqualTo: email).get();
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          doctorData = snapshot.docs.first.data() as Map<String, dynamic>;
          final int time = (doctorData["availability"] != null && doctorData["availability"]["time"] != null)  ? doctorData["availability"]["time"] as int : 0;
          final List<dynamic> weekdays = (doctorData["availability"] != null && doctorData["availability"]["weekday"] != null) ? List.from(doctorData["availability"]["weekday"]) : <dynamic>[];
          print(weekdays);
          // Convert weekday integers to weekday strings
          selectedWeekdayIntegers = weekdays.cast<int>(); // Cast the list to List<int>
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
          _time.text = time.toString();
          // _week.text = weekdays;
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

        // Now you can save this URL in your Firestore or wherever you store user data.
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
    final Map<String, dynamic>? arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String? email = arguments?['email'] as String?;
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
            child: Text("MediWise",
              style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
          elevation: 24.0,
          actions: <Widget>[IconButton(
            icon: Icon(Icons.edit,size: 30,color: Colors.white,),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateProfile()),);
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
                          loadProfileImage();
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
                    buildTextField("Available Time :",_time),
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
                            fontWeight: FontWeight.bold,),
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
        "time": int.parse(_time.text),// Store the selected weekdays as an integer array
      },
      "description": _bio.text,
    };

    try {
      // Query Firestore to find the document based on the doctor's email
      final querySnapshot = await FirebaseFirestore.instance
          .collection("doctor")
          .where("email", isEqualTo: email)
          .get();

      // Check if a document with the email exists
      if (querySnapshot.docs.isNotEmpty) {
        // Get the first document found (assuming there's only one matching email)
        final doctorDoc = querySnapshot.docs.first;

        // Update the document with the new data
        await doctorDoc.reference.update(updatedData);

        // Disable editing mode after saving
        setState(() {
          isEditing = false;
        });

        // Show a success message or navigate to another screen
      } else {
        // Handle the case where no document with the email is found
        print("No document found with email: $email");
      }
    } catch (e) {
      // Handle errors
      print("Error updating document: $e");
    }
  }
  // Define TextStyles for both enabled and disabled states
  final enabledTextStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: Colors.black,
  );
  final disabledTextStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: Colors.black54, // You can change the color for disabled state
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
            maxLines: null, // Allows for unlimited lines
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



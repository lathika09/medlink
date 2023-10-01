import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medlink/constant/image_string.dart';
import 'package:medlink/views/patient/NotificationPage.dart';
import 'package:medlink/views/patient/databaseconn/fetchDoc.dart';
import 'package:medlink/views/patient/login.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'databaseconn/specialitywise.dart';


class HomePage extends StatefulWidget {
  HomePage({Key? key,required this.pemail }) : super(key: key);
final String? pemail;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {


  Map<String, dynamic> patientData = {};
  Future<void> fetchPatientData() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection("patients").where("email", isEqualTo: widget.pemail!).get();
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<List<DoctorData>> fetchDoctors() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('doctor').get();

      List<DoctorData> doctors = querySnapshot.docs.map((doc) {
        Map<String, dynamic> doctorData = doc.data() as Map<String, dynamic>;

        // Access the availability field
        Map<String, dynamic> availability = doctorData['availability'] ?? {
          'weekday': [],
          'time': 0, // Assuming a default time of 0 if not specified
        };

        // Extract 'weekday' and 'time' from the availability map
        List<dynamic> weekdays = List<dynamic>.from(availability['weekday'] ?? []);
        int time = availability['time'] ?? 0;

        // Access fields from the document with null checks
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
        // Create the availability map here
        Map<String, dynamic> doctorAvailability = {
          'weekday': weekdays,
          'time': time,
        };

        return DoctorData(
          route: 'doc_details',
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
      return []; // Return an empty list or handle the error as needed.
    }
  }

// Fetch doctor data from Firestore based on the email


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
  }

  // Define the colors and ratio for blending
  final color1 = Colors.tealAccent.shade400;
  final color2 = Colors.tealAccent.shade700;
  // final color3 = Colors.greenAccent.shade400;
  final ratio = 0.5; // Adjust this ratio to control the mixture

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
  ];


  @override

  Widget build(BuildContext context) {
    print("homepage");
    String pemail =(patientData['email'] is String) ? patientData['email'] : '';
    return Scaffold(
      drawer:NavBar(user_name: patientData['name'],user_email: patientData['email'],),

      appBar:AppBar(
        backgroundColor:Colors.blueAccent.shade700,
        iconTheme: IconThemeData(
          color: Colors.white, // Change the color to your desired color
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
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.notifications,size: 30,color: Colors.white,),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationPage()),
              );
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
                        color: Colors.black.withOpacity(0.3), // Shadow color
                        spreadRadius: 3, // Spread radius
                        blurRadius: 5, // Blur radius
                        offset: Offset(0, 2), // Offset of the shadow
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
                        // decoration: BoxDecoration(border: Border.all(color:Colors.black,width: 1.0,),borderRadius: BorderRadius.circular(10.0)),
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
                        //'docsearch'
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
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 10,),
                      SizedBox(
                        height: 80,
                        child: ListView(
                          // physics: AlwaysScrollableScrollPhysics(),
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
                          Text("Appointment Today",
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 10,),
                      AppointmentData(pemail: pemail!),
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
                      SizedBox(height: 10,),
                      //doctor card
                      Column(
                        children: [
                          FutureBuilder<List<DoctorData>>(
                            future: fetchDoctors(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return CircularProgressIndicator(); // Display a loading indicator while fetching data.
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                List<DoctorData> doctors = snapshot.data ?? [];

                                return ListView.builder(
                                  // physics: AlwaysScrollableScrollPhysics(),
                                  physics: NeverScrollableScrollPhysics(),//by adding this scroll is working properly now as it has listview
                                  shrinkWrap: true,
                                  itemCount: doctors.length,
                                  itemBuilder: (context, index) {
                                    return doctors[index];
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
  // Define the colors and ratio for blending
  final color1 = Colors.white;
  final color2 = Colors.greenAccent.shade100;
  final ratio = 0.5;
  get mixednewColor => Color.lerp(color1, color2, ratio);

  Map<String, dynamic> patientData = {};
  Future<void> fetchDoctorData() async {
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
  }

  @override
  Widget build(BuildContext context) {
    String specialtiesString = widget.speciality.join(', ');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      height: 210,
      child: GestureDetector(
        child: Card(
          elevation: 5,
          color: mixednewColor,
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.only(
                        left: 10, right: 10, top: 15, bottom: 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Container(
                        height: 90.0,
                        width: 85.0,
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
                    onPressed: () {},
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

//APPOINTMENT CARD

class AppointmentData extends StatefulWidget {
  const AppointmentData({Key? key,required this.pemail}) : super(key: key);
final String pemail;
  @override
  State<AppointmentData> createState() => _AppointmentDataState();
}

class _AppointmentDataState extends State<AppointmentData> {


  @override
  Widget build(BuildContext context) {
    return Container(
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
                  const CircleAvatar(
                    backgroundImage: AssetImage(dc_prof),
                  ),
                  const SizedBox(width:10,),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:const [
                      Text("Dr Ajay Kumar",style: TextStyle(color: Colors.black,fontSize: 18,fontWeight: FontWeight.bold,),),
                      SizedBox(height: 2,),
                      Text("Dental",style: TextStyle(color: Colors.black54,fontSize: 16,fontWeight: FontWeight.bold,),)
                    ],
                  ),
                ],
              ),
              SizedBox(height: 25,),
              //Shedule details
              ScheduleData(),
              SizedBox(height: 25,),
              //ACTION BUTTON
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: ElevatedButton(
                    style:ElevatedButton.styleFrom(backgroundColor: Colors.redAccent,),
                    onPressed: (){},
                    child: Text("Cancel",style: TextStyle(color: Colors.white,fontSize: 17),),
                  ),
                  ),
                  SizedBox(width: 20,),
                  Expanded(child: ElevatedButton(
                    style:ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent,),
                    onPressed: (){},
                    child: Text("Completed",style: TextStyle(color: Colors.white,fontSize: 17),),
                  ),
                  ),
                ],
              )


            ],
          ),
        ),
      ),

    );
  }
}


class ScheduleData extends StatelessWidget {
  ScheduleData({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // color: Colors.blueAccent.shade100,
        color:Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2), // Shadow color
            spreadRadius: 2, // Spread radius
            blurRadius: 4, // Blur radius
            offset: Offset(0, 2), // Offset of the shadow
          ),
        ],

      ),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.calendar_month_sharp,color: Colors.black,size: 16,),
          SizedBox(width: 4,),
          Text(
            'Monday,11/28/2022',
            style: const TextStyle(color: Colors.black,fontSize: 15,fontWeight: FontWeight.bold),
          ),
          SizedBox(width:15,),
          Icon(Icons.access_alarm_rounded,color: Colors.black,size: 16,),
          SizedBox(width: 4,),
          Flexible(child: Text('2:00 PM',style: TextStyle(color: Colors.black,fontSize: 15,fontWeight: FontWeight.bold),),
          ),
        ],
      ),

    );
  }
}



//Navbar

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
                fontSize: 30, // Font size
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
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
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
    return Column(
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
    );
  }
}

//CUSTOM DROPDOWN


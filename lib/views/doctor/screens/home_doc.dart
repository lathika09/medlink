import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medlink/constant/image_string.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medlink/views/doctor/screens/profile.dart';
import '../../patient/NotificationPage.dart';

//${widget.userData['email']}
final usersCollection = FirebaseFirestore.instance.collection('doctor');
void fetchUserData(String userEmail) async {
  final snapshot = await usersCollection.where('email', isEqualTo: userEmail).get();
  if (snapshot.docs.isNotEmpty) {
    final userData = snapshot.docs.first.data();

  }
}

class HomePage_doc extends StatefulWidget {

  const HomePage_doc({Key? key}) : super(key: key);

  @override
  State<HomePage_doc> createState() => _HomePage_docState();
}

class _HomePage_docState extends State<HomePage_doc> {
  // Define the colors and ratio for blending
  final color1 = Colors.greenAccent.shade200;
  final color2 = Colors.white;
  final ratio = 0.7;
  get mixedColor => Color.lerp(color1, color2, ratio);



  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String? email = arguments?['email'] as String?;
    print(email);


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
            icon: Icon(Icons.notifications,size: 30,color: Colors.white,),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationPage()),);
              },
          ),
          ],
        ),
    body:SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child:Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(vertical: 30.0, horizontal: 50.0),
                decoration: BoxDecoration(
                  color:Colors.greenAccent.shade200,
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30.0),    // Bottom-left corner
                    bottomRight: Radius.circular(30.0), ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3), // Shadow color
                      spreadRadius: 3, // Spread radius
                      blurRadius: 5, // Blur radius
                      offset: Offset(0, 20), // Offset of the shadow
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16.0), // Adjust the radius as needed
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 10.0), // Adjust the blur values as needed
                        child: Image.asset(logo, width: MediaQuery.of(context).size.width / 2),
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Text("Welcome to ${appname}",style: TextStyle(
                        fontSize: 27,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(color: Colors.blueAccent, offset: Offset(1,1), blurRadius:2)]
                    ),

                    ),
                  ],
                ),
              )

            ),
            Container(
              width: MediaQuery.of(context).size.width,

              padding: EdgeInsets.symmetric(vertical: 30.0, horizontal: 25.0),
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 130,
                        height: 130,

                        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),

                        decoration: BoxDecoration(
                          color:Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.greenAccent.withOpacity(0.3), // Shadow color
                              spreadRadius: 3, // Spread radius
                              blurRadius: 5, // Blur radius
                              offset: Offset(0, 20), // Offset of the shadow
                            ),
                          ],
                        ),

                        child:GestureDetector(
                          child: Card(
                            color:Colors.greenAccent.shade200,
                            elevation: 2,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,

                              children: [
                                Container(
                                  width: 75,
                                  height: 75,
                                  padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 0.0),
                                  color:Colors.transparent,
                                  // child: Icon(FontAwesomeIcons.userDoctor,size: 50,color: Colors.black,),
                                  child: Icon(FontAwesomeIcons.userDoctor,size: 50,color: Colors.black,),

                                ),
                                Text("Patient details",softWrap:true,style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 16),),

                              ],
                            ),
                          ),
                          onTap: (){
                            Navigator.pushNamed(
                              context,
                              'doc_profile', // The route name for ProfileSetting
                              arguments: {
                                'email': email, // Pass the doctor's profile data as an argument
                              },
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 30,),
                      Container(
                        width: 130,
                        height: 130,

                        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),

                        decoration: BoxDecoration(
                          color:Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.greenAccent.withOpacity(0.3), // Shadow color
                              spreadRadius: 3, // Spread radius
                              blurRadius: 5, // Blur radius
                              offset: Offset(0, 20), // Offset of the shadow
                            ),
                          ],
                        ),

                        child:GestureDetector(
                          child: Card(
                            color:Colors.greenAccent.shade200,
                            elevation: 2,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,

                              children: [
                                Container(
                                  width: 75,
                                  height: 75,
                                  padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 0.0),
                                  color:Colors.transparent,
                                  // child: Icon(FontAwesomeIcons.userDoctor,size: 50,color: Colors.black,),
                                  child: Icon(FontAwesomeIcons.userDoctor,size: 50,color: Colors.black,),

                                ),
                                Text("Appointments",maxLines:1,style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 16),),

                              ],
                            ),
                          ),
                          onTap: (){
                            Navigator.pushNamed(
                              context,
                              'appointment_stats', // The route name for ProfileSetting
                              arguments: {
                                'email': email, // Pass the doctor's profile data as an argument
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30,),

                  // SizedBox(height: 30,),

                  Container(
                    width: 130,
                    height: 130,

                    padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),

                    decoration: BoxDecoration(
                      color:Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.greenAccent.withOpacity(0.3), // Shadow color
                          spreadRadius: 3, // Spread radius
                          blurRadius: 5, // Blur radius
                          offset: Offset(0, 20), // Offset of the shadow
                        ),
                      ],
                    ),

                    child:GestureDetector(
                      child: Card(
                        color:Colors.greenAccent.shade200,
                        elevation: 2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,

                          children: [
                            Container(
                              width: 75,
                              height: 75,
                              padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 0.0),
                              color:Colors.transparent,
                              // child: Icon(FontAwesomeIcons.userDoctor,size: 50,color: Colors.black,),
                              child: Icon(FontAwesomeIcons.imagePortrait,size: 50,color: Colors.blueAccent.shade700,),

                            ),
                            Text("Profile",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 16),),

                          ],
                        ),
                      ),
                      onTap: (){
                        Navigator.pushNamed(
                          context,
                          'update_prof', // The route name for ProfileSetting
                          arguments: {
                            'email': email, // Pass the doctor's profile data as an argument
                          },
                        );
                      },
                    ),
                  ),

                ],
              ),
            )
          ],
        ),

      ),
    ),
    );
  }
}



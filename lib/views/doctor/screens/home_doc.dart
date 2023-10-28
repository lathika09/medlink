import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medlink/constant/image_string.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medlink/views/doctor/login_doc.dart';
import 'package:medlink/views/doctor/screens/profile.dart';
import 'package:medlink/views/patient/AppointmentPage.dart';
import '../../chats/main_screen.dart';
import '../../patient/NotificationPage.dart';
import 'main_chat_screen_doc.dart';

class HomePage_doc extends StatefulWidget {
  const HomePage_doc({Key? key,required this.email}) : super(key: key);
  final String email;

  @override
  State<HomePage_doc> createState() => _HomePage_docState();
}

class _HomePage_docState extends State<HomePage_doc> {
  final color1 = Colors.greenAccent.shade200;
  final color2 = Colors.white;
  final ratio = 0.7;
  get mixedColor => Color.lerp(color1, color2, ratio);


  //await FirebaseAuth.instance.signOut();

  @override
  void initState() {
    super.initState();
    // await FirebaseAuth.instance.signOut();
    // updateDoctorFCMToken(widget.pemail);
  }

  @override
  Widget build(BuildContext context) {
    // final Map<String, dynamic>? arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    // final String? email = arguments?['email'] as String?;

    return Scaffold(
        appBar:AppBar(
          backgroundColor:Colors.blueAccent.shade700,
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
          leading: IconButton(
              onPressed: (){showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Logout Confirmation"),
                    content: Text("Are you sure you want to log out?"),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () async {
                          // User confirmed, log out and navigate to login page
                          Navigator.of(context).pop(); // Close the dialog
                          // Perform logout logic here
                          // You can use Navigator to navigate to the login page
                          Navigator.pushReplacement( context,
                              MaterialPageRoute(builder: (context) => LoginPage_Doc()),
                          );
                          await FirebaseAuth.instance.signOut();
                        },
                        child: Text("Yes"),
                      ),
                      TextButton(
                        onPressed: () {
                          // User canceled, simply close the dialog
                          Navigator.of(context).pop();
                        },
                        child: Text("No"),
                      ),
                    ],
                  );
                },
              );
              },
            icon: Icon(
              Icons.logout,
              size: 20,
            ),
          ),
          title:Center(
            child: Text(
            appname,
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
                      color: Colors.black.withOpacity(0.3),
                      spreadRadius: 3,
                      blurRadius: 5,
                      offset: Offset(0, 20),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 10.0),
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
                        // width: 130,
                        // height: 130,
                        width:MediaQuery.of(context).size.width/3,
                        height: MediaQuery.of(context).size.height/6,
                        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),

                        decoration: BoxDecoration(
                          color:Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.greenAccent.withOpacity(0.3),
                              spreadRadius: 3,
                              blurRadius: 5,
                              offset: Offset(0, 20),
                            ),
                          ],),
                        child:GestureDetector(
                          child: Card(
                            color:Colors.greenAccent.shade200,
                            elevation: 2,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  // width: 75,
                                  // height: 75,
                                  padding: EdgeInsets.symmetric(vertical: 5.0,),
                                  color:Colors.transparent,
                                  child: Icon(Icons.person,size: 50,color: Colors.black,),
                                ),
                                Text("Patients",softWrap:true,style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 16),),
                              ],),
                          ),
                          onTap: (){

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>PatientListPage(dEmail: widget.email!,),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 30,),
                      Container(
                        // width: 130,
                        // height: 130,
                        width:MediaQuery.of(context).size.width/3,
                        height: MediaQuery.of(context).size.height/6,
                        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                        decoration: BoxDecoration(
                          color:Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.greenAccent.withOpacity(0.3),
                              spreadRadius: 3,
                              blurRadius: 5,
                              offset: Offset(0, 20),
                            ),
                          ],),
                        child:GestureDetector(
                          child: Card(
                            color:Colors.greenAccent.shade200,
                            elevation: 2,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  // width: 75,
                                  // height: 75,
                                  padding: EdgeInsets.symmetric(vertical: 5.0,),
                                  color:Colors.transparent,
                                  child: Icon(FontAwesomeIcons.bookMedical ,size: 40,color: Colors.black,),
                                ),
                                Text("Schedules",maxLines:1,style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 16),),
                              ],),
                          ),
                          onTap: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>AppointmentPage(email: widget.email)),
                            );
                          },
                        ),
                      ),
                    ],),
                  SizedBox(height: 30,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        // width: 130,
                        // height: 130,
                        width:MediaQuery.of(context).size.width/3,
                        height: MediaQuery.of(context).size.height/6,
                        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                        decoration: BoxDecoration(
                          color:Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.greenAccent.withOpacity(0.3),
                              spreadRadius: 3,
                              blurRadius: 5,
                              offset: Offset(0, 20),
                            ),
                          ],),
                        child:GestureDetector(
                          child: Card(
                            color:Colors.greenAccent.shade200,
                            elevation: 2,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  // width: 75,
                                  // height: same,
                                  padding: EdgeInsets.symmetric(vertical: 5.0,),
                                  color:Colors.transparent,
                                  child: Icon(Icons.message,size: 50,color: Colors.black,),
                                ),
                                Text("Chats",softWrap:true,style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 16),),
                              ],),
                          ),
                          onTap: (){
                            if (widget.email != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => MainChatScreenDoc(email: widget.email)),
                              );
                            }
                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //     builder: (context) =>MainChatScreenDoc(email: widget.email),
                            //     )
                            // );
                          },
                        ),
                      ),
                      SizedBox(width: 30,),
                      Container(
                        // width: 130,
                        // height: 130,
                        width:MediaQuery.of(context).size.width/3,
                        height: MediaQuery.of(context).size.height/6,

                        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),

                        decoration: BoxDecoration(
                          color:Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.greenAccent.withOpacity(0.3),
                              spreadRadius: 3,
                              blurRadius: 5,
                              offset: Offset(0, 20),
                            ),
                          ],),
                        child:GestureDetector(
                          child: Card(
                            color:Colors.greenAccent.shade200,
                            elevation: 2,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  // width: 75,
                                  // height: 75,
                                  padding: EdgeInsets.symmetric(vertical: 5.0,),
                                  color:Colors.transparent,
                                  child: Icon(FontAwesomeIcons.imagePortrait,size: 50,color: Colors.black,),
                                ),
                                Text("Profile",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 16),),
                              ],),
                          ),
                          onTap: (){
                            Navigator.pushNamed(
                              context,
                              'update_prof',
                              arguments: {
                                'email': widget.email,
                              },
                            );
                          },
                        ),
                      ),
                    ],),
                ],),
            )
          ],),
      ),
    ),
    );
  }
}



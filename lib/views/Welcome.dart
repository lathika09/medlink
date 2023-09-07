import 'package:flutter/material.dart';
import 'package:medlink/constant/image_string.dart';
import 'package:medlink/views/doctor/login_doc.dart';
import 'package:medlink/views/patient/MainPage.dart';
import 'package:medlink/views/patient/home.dart';
import 'package:medlink/views/patient/login.dart';
import 'package:medlink/views/splash/splash_screen.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Container(
            color:Colors.white,
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.symmetric(horizontal: 30,vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Expanded(
                  flex: 0,
                  child: Column(
                    children: [
                      Text("Welcome !!!",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 40,
                      ),),
                      SizedBox(
                        height:10,
                      ),
                      Text("To get started choose the User type",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                      ),
                      ),],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    //margin: const EdgeInsets.symmetric(vertical: 40),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    decoration: const BoxDecoration(
                      image: DecorationImage(image: AssetImage(wel_img),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        MaterialButton(
                            minWidth:double.infinity,
                            height: 50,
                            onPressed:(){
                              Navigator.push(context,MaterialPageRoute(builder: (context)=>MainPage()));//FOR PATIENTS
                            },
                          color: Colors.blue[600],
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              color:Colors.black
                            ),
                            borderRadius: BorderRadius.circular(50)
                          ),
                          child: const Text("PATIENT",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),),
                        ),
                        const SizedBox(height:15),
                        MaterialButton(
                          minWidth:double.infinity,
                          height: 50,
                          onPressed:(){
                            Navigator.push(context,MaterialPageRoute(builder: (context)=>LoginPage_Doc()));//FOR  DOCTOR BUTTON GO TO HOMEPAGE
                          },
                          color: Colors.blue[600],
                          shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                  color:Colors.black
                              ),
                              borderRadius: BorderRadius.circular(50)
                          ),
                          child: const Text("DOCTOR",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),),
                        ),
                       

                      ],
                    ),
                  ),
                )

              ],
            ),

          ),
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/get_utils/get_utils.dart';
import 'package:medlink/views/patient/home.dart';
//import 'package:medlink/constant/image_string.dart';
import 'package:medlink/views/patient/login.dart';

import '../splash/splash_controller.dart';

//import '../splash/splash_screen.dart';

class SignupPage extends StatelessWidget {
  TextEditingController _name = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _phn = TextEditingController();
  TextEditingController _pswd = TextEditingController();
  TextEditingController _conpswd = TextEditingController();

  bool validateEmail(String email) {
    return GetUtils.isEmail(email); // Using GetUtils to validate email
  }

  bool validatePhoneNumber(String phoneNumber) {
    return GetUtils.isPhoneNumber(phoneNumber); // Using GetUtils to validate phone number
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,

        // brightness:Brightness.light,
        backgroundColor:Colors.white,
        // title: const Text("MediWise",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 26,color:Colors.white),),
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
            },
          icon: Icon(Icons.arrow_back_ios,size: 25,color: Colors.black,),
          
        ),
      ),
      body: SingleChildScrollView(
        child:Container(

          // decoration: const BoxDecoration(
          //   image: DecorationImage(
          //     image: AssetImage(bg),
          //     fit: BoxFit.cover,
          //   ),
          // ),
          padding: EdgeInsets.symmetric(horizontal: 40,vertical:0),
          height: MediaQuery.of(context).size.height-60,
          width: double.infinity,
          child: Column(

            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text("Sign up",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30),),
              Padding(

                padding: EdgeInsets.symmetric(vertical:10),
                child: Column(
                  children: [
                    Column(
                      crossAxisAlignment:CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Name",
                          style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: Colors.black87),
                        ),
                        SizedBox(height:3),
                        TextField(
                          obscureText: false,
                          controller:_name,

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
                              )
                          ),
                        ),
                        SizedBox(height:10),
                      ],
                    ),
                    Column(
                      crossAxisAlignment:CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Email",
                          style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: Colors.black87),
                        ),
                        SizedBox(height:3),
                        TextField(
                          obscureText: false,

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
                              )
                          ),
                          controller:_email,
                        ),
                        SizedBox(height:10),
                      ],
                    ),
                    Column(
                      crossAxisAlignment:CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Phone No.",
                          style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: Colors.black87),
                        ),
                        const SizedBox(height:3),
                        TextField(
                          obscureText: false,
                          controller:_phn,
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
                              )
                          ),
                        ),
                        SizedBox(height:10),
                      ],
                    ),
                    Column(
                      crossAxisAlignment:CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Password",
                          style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: Colors.black87),
                        ),
                        const SizedBox(height:3),
                        TextField(
                          obscureText: true,
                          controller:_pswd,
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
                              )
                          ),
                        ),
                        SizedBox(height:10),
                      ],
                    ),
                    Column(
                      crossAxisAlignment:CrossAxisAlignment.start,
                      children: [
                        const Text(
                          " Confirm Password",
                          style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: Colors.black87),
                        ),
                        const SizedBox(height:3),
                        TextField(

                          obscureText: true,
                          controller: _conpswd,
                          decoration: InputDecoration(
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
                              )
                          ),
                        ),
                        SizedBox(height:10),
                      ],
                    ),

                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(top:5,left: 3),
                child: MaterialButton(
                  minWidth:MediaQuery.of(context).size.width/2,
                  height: 50,
                  onPressed:()async{
                    if (!SplashScreenController.find.animate.value) {

                      FirebaseAuth.instance.createUserWithEmailAndPassword(email: _email.text, password: _pswd.text).then((value) {
                        print("account created");
                        Navigator.push(context,MaterialPageRoute(builder: (context)=>HomePage()));
                      }).onError((error, stackTrace) {
                        print("error ${error.toString()}");
                      });
                    }

                    if (_name.text.isEmpty) {
                      _showErrorDialog(context, "Please enter your name.");
                    } else if (!validateEmail(_email.text)) {
                      _showErrorDialog(context, "Invalid email format.");
                    } else if (!validatePhoneNumber(_phn.text)) {
                      _showErrorDialog(context, "Invalid phone number format.");
                    } else if (_pswd.text.isEmpty || _conpswd.text.isEmpty) {
                      _showErrorDialog(context, "Please enter a password and confirm it.");
                    } else if (_pswd.text != _conpswd.text) {
                      _showErrorDialog(context, "Passwords do not match.");
                    } else {
                      try {
                        final authResult = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                          email: _email.text,
                          password: _pswd.text,
                        );
                        print("Account created");
                        _showSuccessDialog(context, "Account created successfully!");

                      } catch (error) {
                        print("Error: ${error.toString()}");

                        String errorMessage = "Error creating account: ${error.toString()}";

                        if (error is FirebaseAuthException) {
                          if (error.code == "email-already-in-use") {
                            errorMessage = "This email is already registered.";
                          } else {
                            errorMessage = "Error: ${error.code} - ${error.message}";
                          }
                        }

                        _showErrorDialog(context, errorMessage);
                      }
                    }


                  },
                  color: Colors.blue[600],
                  shape: RoundedRectangleBorder(
                      side: const BorderSide(
                          color:Colors.black
                      ),
                      borderRadius: BorderRadius.circular(50)
                  ),
                  child: const Text("Create Account",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  const Text("Alreday have an account? ",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 15),),
                  //Text("Sign up",style: TextStyle(fontWeight: FontWeight.w600,fontSize: 18),),
                  TextButton(
                    onPressed: (){
                      Navigator.push(context,MaterialPageRoute(builder: (context)=>LoginPage()));
                    },
                    child: const Text("Login",style: TextStyle(fontWeight: FontWeight.w600,fontSize: 18),
                    ),
                  )
                ],
              ),


            ],
          ),
        ),
      ),
    );
  }
  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
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
                Navigator.of(context).pop();// Close the dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

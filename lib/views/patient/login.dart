import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medlink/constant/image_string.dart';
import 'package:medlink/views/patient/home.dart';
import 'package:medlink/views/patient/signup.dart';

import '../Welcome.dart';
import '../splash/splash_screen.dart';

class LoginPage extends StatelessWidget {
  TextEditingController login_email = TextEditingController();
  TextEditingController login_pswd = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        // brightness:Brightness.light,

        backgroundColor: Colors.white,
        leading: IconButton(
            onPressed: (){Navigator.pop(context);},
            icon: const Icon(
              Icons.arrow_back_ios,
              size:20,
              color: Colors.black,)
        ),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [

            Expanded(child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  children: [
                    const SizedBox(height: 20,),

                    const Text("Login",
                    style: TextStyle(fontWeight: FontWeight.bold,fontSize: 33),
                    ),
                    const SizedBox(height:8,),
                    Text("Login to your account",
                      style: TextStyle(fontSize: 16, color: Colors.grey[800],),
                    ),
                  ],
                ),
                Padding(padding:EdgeInsets.symmetric(horizontal: 40,vertical: 10),
                child: Column(
                  children: [
                    const SizedBox(height:8,),
                  Column(
                  crossAxisAlignment:CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Email",
                      style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: Colors.black87),
                    ),
                    SizedBox(height:5),
                    TextField(
                      controller: login_email,
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
                          ),
                        prefixIcon: Icon(
                          Icons.email,
                          color: Color(0xFFBDBDBD), // Adjust the color as needed
                        ),
                      ),
                    ),
                    const SizedBox(height:10),
                  ],
                ),
                    Column(
                      crossAxisAlignment:CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Password",
                          style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: Colors.black87),
                        ),
                        SizedBox(height:5),
                        PasswordTextField(controller: login_pswd),
                        //SizedBox(height:10),
                        TextButton(
                          onPressed: () {
                            _showForgotPasswordDialog(context);
                          },
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                        ),

                      ],
                    ),
                  ],
                ),
                ),
                Padding(padding: EdgeInsets.symmetric(horizontal: 40,vertical: 5),
                child: Container(
                  padding: EdgeInsets.only(left: 3),

                  child: MaterialButton(
                    minWidth:MediaQuery.of(context).size.width/2,
                    height: 50,
                    onPressed:(){
                      FirebaseAuth.instance
                          .signInWithEmailAndPassword(
                      email: login_email.text,
                      password: login_pswd.text,
                      )
                          .then((value) {


                      Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                      );
                      }).catchError((error) {
                      print("Error: ${error.toString()}");
                      _showErrorDialog(context, error.toString());

                      });

                    },
                    color: Colors.blue[600],
                    shape: RoundedRectangleBorder(
                        side: const BorderSide(
                            color:Colors.black
                        ),
                        borderRadius: BorderRadius.circular(50)
                    ),
                    child: const Text("LOGIN",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),),
                  ),

                ),),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    const Text("Don't have an account? ",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 15),),
                    //Text("Sign up",style: TextStyle(fontWeight: FontWeight.w600,fontSize: 18),),
                    TextButton(
                        onPressed: (){
                          Navigator.push(context,MaterialPageRoute(builder: (context)=>SignupPage()));
                          },
                        child: const Text("Sign up",style: TextStyle(fontWeight: FontWeight.w600,fontSize: 18),
                        ),
                    )
                  ],
                ),
                Container(
                  padding: EdgeInsets.only(top: 80),
                  height: 200,
                  decoration: const BoxDecoration(
                    image: DecorationImage(image: AssetImage(login_pg),
                    fit: BoxFit.fitHeight,)
                  ),
                ),
              ],
            ))
          ],
        ),
      ),
    );

  }
  void _showForgotPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Forgot Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Enter your email to receive a password reset link:'),
              SizedBox(height: 10),
              TextField(
                controller: TextEditingController(),
                decoration: InputDecoration(
                  hintText: 'Email',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
                child: Text('Reset Password'),
                onPressed: () async {
                  try {
                    await FirebaseAuth.instance.sendPasswordResetEmail(
                      email: login_email.text,
                    );
                    _showSuccessDialog(context, 'Password reset instructions sent to ${login_email.text}');
                    Navigator.of(context).pop();
                  } catch (error) {
                    print("Error sending reset instructions: ${error.toString()}");
                    _showErrorDialog(context, 'Error sending reset instructions: ${error.toString()}');
                  }
                },
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, dynamic error) {
    String errorMessage = 'An error occurred. Please enter credentials.';

    if (error is FirebaseException) {
      switch (error.code) {
        case 'invalid-email':
          errorMessage = 'Invalid email address. Please enter a valid email.';
          break;
        case 'user-not-found':
          errorMessage = 'User not found. Please check your email and try again.';
          break;
        case 'wrong-password':
          errorMessage = 'Wrong password. Please try again.';
          break;
        case 'user-disabled':
          errorMessage = 'Your account has been disabled. Please contact support.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many login attempts. Please try again later.';
          break;
        case 'email-already-in-use':
          errorMessage = 'Email address is already in use. Please use a different email.';
          break;
        case 'weak-password':
          errorMessage = 'Weak password. Please use a stronger password.';
          break;

      }

    } else if (error.toString().contains('required_email')) {
      errorMessage = 'Email field is required. Please enter your email.';
    } else if (error.toString().contains('required_password')) {
      errorMessage = 'Password field is required. Please enter your password.';
    }



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

//WE WILL BE CREATING WIDGET FOR password
class PasswordTextField extends StatefulWidget {
  final TextEditingController controller;

  PasswordTextField({required this.controller});

  @override
  _PasswordTextFieldState createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _isObscured = true; // Initially, the password is obscured

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: _isObscured,
      controller: widget.controller,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFFBDBDBD),
          ),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFFBDBDBD),
          ),
        ),
        prefixIcon: Icon(
          Icons.password,
          color: Color(0xFFBDBDBD),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isObscured ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _isObscured = !_isObscured;
            });
          },
        ),
      ),
    );
  }
}

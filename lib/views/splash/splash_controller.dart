import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medlink/views/Welcome.dart';
import 'package:medlink/views/splash/splash_screen.dart';

class SplashScreenController extends GetxController{
  static SplashScreenController get find=>Get.find();

  RxBool animate=false.obs;
  Future startAnimation() async {
    if (animate.value) {
      return; // Animation already started, no need to proceed
    }
    await Future.delayed(Duration(milliseconds: 500));
    animate.value=true;
    await Future.delayed(Duration(milliseconds: 5000));
    // Get.to(const WelcomePage());
    Get.to(() =>WelcomePage());
    //Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=>SplashScreen()));

  }
}
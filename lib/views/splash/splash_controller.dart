import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medlink/views/Welcome.dart';
import 'package:medlink/views/splash/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';



class SplashScreenController extends GetxController {
  static SplashScreenController get find => Get.find();

  RxBool animate = false.obs;

  Future startAnimation() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenWelcome = prefs.getBool('hasSeenWelcome') ?? false;

    if (hasSeenWelcome) {
      // User has seen the welcome page before, navigate directly to MainPage
      Get.offAll(() => WelcomePage());
    } else {
      if (animate.value) {
        return; // Animation already started, no need to proceed
      }
      await Future.delayed(Duration(milliseconds: 500));
      animate.value = true;
      await Future.delayed(Duration(milliseconds: 5000));

      // Set a flag to indicate that the user has seen the welcome page
      prefs.setBool('hasSeenWelcome', true);

      // Show the WelcomePage
      Get.offAll(() => WelcomePage());
    }
  }
}

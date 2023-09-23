import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medlink/views/Welcome.dart';
import 'package:medlink/views/splash/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medlink/main.dart';


class SplashScreenController extends GetxController {
  static SplashScreenController get find => Get.find();

  RxBool animate = false.obs;
  bool hasShownSplash = false;

  Future startAnimation() async {
    if (animate.value) {
      return; // Animation already started, no need to proceed
    }
    await Future.delayed(Duration(milliseconds: 100));
    animate.value=true;
    await Future.delayed(Duration(milliseconds: 3500));
    // Get.to(const WelcomePage());
    Get.offAndToNamed('welcome');
    }
  }


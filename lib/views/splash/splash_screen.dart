import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medlink/constant/image_string.dart';
import 'package:medlink/views/Welcome.dart';
import 'package:medlink/views/splash/splash_controller.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({Key? key}) : super(key: key);

  final splashScreenController=Get.put(SplashScreenController());
  
  @override
  Widget build(BuildContext context) {

    splashScreenController.startAnimation();
    return Scaffold(
      body:Stack(
        children: [
          Obx(
          ()=> AnimatedPositioned(
            duration: const Duration(milliseconds: 1600),
            top:splashScreenController.animate.value ? 0:-30,
            left: splashScreenController.animate.value ? 0:-30,
            child:AnimatedOpacity(
              duration: const Duration(milliseconds: 2000),
              opacity: splashScreenController.animate.value ? 1 : 0,
              child:Image.asset(SplashAbove,width:MediaQuery.of(context).size.width ),
            ),
            ),
          ),
          Obx(
                ()=> AnimatedPositioned(
                  duration:const Duration(milliseconds: 2600),
                  top: 160,
                  left:splashScreenController.animate.value ? 0:-30,
                  child:AnimatedOpacity(
                    duration: const Duration(milliseconds: 3400),
                    opacity: splashScreenController.animate.value ? 1 : 0,
                    child: Image.asset(SplashMiddle,width:MediaQuery.of(context).size.width )
              ),
            ),
          ),
          Obx(
                ()=> AnimatedPositioned(duration:const Duration(milliseconds: 2000),
                bottom: 210,
                left:80,
                child:AnimatedOpacity(
                  duration: const Duration(milliseconds: 2400),
                  opacity: splashScreenController.animate.value ? 1 : 0,
                  child: Text(appname,style: TextStyle(
                      fontSize: 45,
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      shadows: [Shadow(color: Colors.blueAccent, offset: Offset(1,1), blurRadius:2)]
                  ),
                ),
              ),
            ),
          ),
          Obx(
                ()=> AnimatedPositioned(duration:const Duration(milliseconds: 1600),
                bottom:0,
                left: splashScreenController.animate.value ? 0:-30,
                child:AnimatedOpacity(
                  duration: const Duration(milliseconds: 2000),
                  opacity: splashScreenController.animate.value ? 1 : 0,
                  child:Image.asset(Splashbelow)
                ),
            ),
          ),
        ],
      ),

    );
  }


}

import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:medlink/views/Welcome.dart';
import 'package:medlink/views/doctor/screens/profile.dart';
import 'package:medlink/views/doctor/screens/update_prof.dart';
import 'package:medlink/views/patient/BookingPage.dart';
import 'package:medlink/views/patient/databaseconn/fetchDoc.dart';
import 'package:medlink/views/patient/doctor_details.dart';
import 'package:medlink/views/splash/splash_screen.dart';
import 'package:flutter/services.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((value) {
    _initializeFirebase();
    runApp(MyApp());
  });
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent.shade700),
        focusColor: Colors.blueAccent.shade700,
        useMaterial3: true,
      ),
      routes: {
        'doc_details':(context)=>const DocDetails(),
        "booking_Page":(context)=>const BookingPage(),
        'doc_profile':(context)=>const ProfileSetting(),
        'update_prof':(context)=>const UpdateProfile(),
        'welcome':(context)=>const WelcomePage(),
        'docsearch':(context)=>const DoctorList(),
      },
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}


_initializeFirebase() async {
  await Firebase.initializeApp();

  var result = await FlutterNotificationChannel.registerNotificationChannel(
      description: 'For Showing Message Notification',
      id: 'chats',
      importance: NotificationImportance.IMPORTANCE_HIGH,
      name: 'Chats');
  log('\nNotification Channel Result: $result');
}



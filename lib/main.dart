import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:medlink/views/Welcome.dart';
import 'package:medlink/views/doctor/screens/home_doc.dart';
import 'package:medlink/views/doctor/screens/profile.dart';
import 'package:medlink/views/doctor/screens/update_prof.dart';
import 'package:medlink/views/patient/AppointmentPage.dart';
import 'package:medlink/views/patient/BookingPage.dart';
import 'package:medlink/views/patient/MainPage.dart';
import 'package:medlink/views/patient/databaseconn/fetchDoc.dart';
import 'package:medlink/views/patient/databaseconn/specialitywise.dart';
import 'package:medlink/views/patient/doctor_details.dart';
import 'package:medlink/views/splash/splash_screen.dart';
import 'package:flutter/services.dart';





Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  );

  // Step 3
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((value) {
    runApp(MyApp());
  });
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
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
        "main":(context)=>const MainPage(),
        'doc_details':(context)=>const DocDetails(),
        "booking_Page":(context)=>const BookingPage(),
        'doc_profile':(context)=>const ProfileSetting(),
        'doc_home':(context)=>const HomePage_doc(),
        'update_prof':(context)=>const UpdateProfile(),
        'welcome':(context)=>const WelcomePage(),

        'docsearch':(context)=>const DoctorList(),
        'appointment_stats':(context)=>const AppointmentPage(),
      },
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}


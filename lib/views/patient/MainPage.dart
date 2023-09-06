
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:medlink/constant/image_string.dart';
import 'package:medlink/views/patient/AppointmentPage.dart';
// import 'package:medlink/constant/image_string.dart';
import 'package:medlink/views/patient/NotificationPage.dart';
import 'package:medlink/views/patient/home.dart';
// import 'package:medlink/views/patient/login.dart';
import 'package:medlink/main.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);


  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentPage=0;
  final PageController _page=PageController();

  // Define the colors and ratio for blending
  final color1 = Colors.tealAccent.shade400;
  final color2 = Colors.tealAccent.shade700;
  // final color3 = Colors.greenAccent.shade400;
  final ratio = 0.5; // Adjust this ratio to control the mixture

  get mixedColor => Color.lerp(color1, color2, ratio);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller:_page,
        onPageChanged: ((value){
          setState(() {
            currentPage=value;
          });
        }),
        children:const <Widget> [
          HomePage(),
          AppointmentPage(),
        ],
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
        child: BottomNavigationBar(
          elevation: 15,
          backgroundColor:Colors.blueAccent.shade700,
            currentIndex:currentPage,
            onTap:(page){
              setState(() {
                currentPage=page;
                _page.animateToPage(page, duration:const Duration(milliseconds: 500), curve:Curves.easeInOut,);
              });
            },
            items:const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  icon: Icon(Icons.home,),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.book_sharp),
                label: "Appointment",
              ),
            ],
          selectedLabelStyle: TextStyle(color: Colors.white,fontSize: 15),
          unselectedLabelStyle: TextStyle(color: Colors.blue.shade100,fontSize: 13),
          selectedItemColor: Colors.white,
          unselectedIconTheme: IconThemeData(
            color: Colors.blue.shade100,
            size: 24,
          ),
          unselectedItemColor: Colors.blue.shade100,
         selectedIconTheme: IconThemeData(
           color: Colors.white,
             size: 28,
         ),
        ),
      ),
    );
  }
}





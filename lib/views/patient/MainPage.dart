
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:medlink/constant/image_string.dart';
import 'package:medlink/views/patient/NotificationPage.dart';
import 'package:medlink/views/patient/home.dart';
// import 'package:medlink/views/patient/login.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentPage=0;
  final PageController _page=PageController();

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
          NotificationPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentPage,
          onTap: (page){
            setState(() {
              currentPage=page;
              _page.animateToPage(page, duration:const Duration(milliseconds: 500), curve:Curves.easeInOut,);
            });
          },
          items:const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book_sharp),
              label: "Appointment",
            ),
          ]),
    );
  }
}

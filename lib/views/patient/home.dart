import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:medlink/constant/image_string.dart';
import 'package:medlink/views/patient/NotificationPage.dart';
import 'package:medlink/views/patient/login.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? valueChoose;
  List listItem=[
    "Mumbai","Delhi","Pune","Chennai"
  ];
  TextEditingController search_name = TextEditingController();
  String searchText='';
  
  @override

  Widget build(BuildContext context) {
    return Scaffold(
      drawer:NavBar(),

      appBar:AppBar(
        title:Center(
          child: Text("MediWise",
            style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold),
          ),
        ),
        elevation: 24.0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.notifications,size: 30,color: Colors.blueAccent.shade700,),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationPage()),
              );
            },
          ),
        ],


      ),
      body:SafeArea(
        child: SingleChildScrollView(
          child:Container(

            child:Column(
              children: [
                Container(
                  // height: 50,

                  padding: EdgeInsets.symmetric(vertical:10,horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(child: Icon(Icons.location_on,size: 28,)),
                      SizedBox(width: 20,),
                      Container(
                        width:260,
                        // width: MediaQuery.of(context).size.width/2,
                        // decoration: BoxDecoration(border: Border.all(color:Colors.black,width: 1.0,),borderRadius: BorderRadius.circular(10.0)),
                        height:40,
                        padding: EdgeInsets.all(3.0),
                        child: DropdownButton(
                          elevation: 0,
                          hint: Text("Select City "),
                          dropdownColor: Colors.white,
                          icon: Icon(Icons.arrow_drop_down),
                          iconSize: 26,
                          isExpanded: true,
                          style:TextStyle(
                            color: Colors.black,
                            fontSize: 22,
                          ),
                          value:valueChoose,
                          onChanged: (newValue){
                            setState(() {
                              valueChoose=newValue as String;;
                            });
                          },
                          items: listItem.map((valueItem){
                            return DropdownMenuItem(
                                value:valueItem,
                                child:Text(valueItem)
                            );
                          }).toList(),
                        ),
                      ),






                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 2.0,horizontal: 20.0),
                  child:  TextField(

                    style:const TextStyle(fontSize: 19.0,fontWeight: FontWeight.w600,color: Colors.black),
                    controller: search_name,
                    onChanged: (value){
                      setState(() {
                        searchText=value;

                      });
                    },
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 5.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide:const BorderSide(width: 0.8),
                      ),
                      hintText: "   Search by Speciality",
                      // prefixIcon:const Icon(Icons.search,size:20.0,),
                      suffixIcon: IconButton(onPressed: (){}, icon:const Icon(Icons.search,size: 20.0,))
                    ),

                  ),

                ),
                ImageSlider(),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10.0,horizontal: 15.0),
                  child: Column(

                    children: [
                      Row(

                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Category",
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

            ),
          ),
        ),
      ) ,
    );
  }
}


//DROPDOWN
class CityDropdown extends StatefulWidget {
  const CityDropdown({Key? key}) : super(key: key);


  @override
  State<CityDropdown> createState() => _CityDropdownState();
}

class _CityDropdownState extends State<CityDropdown> {
  String? valueChoose;
  List listItem=[
    "Mumbai","Delhi","Pune","Chennai"
  ];

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      hint: Text("Select City "),
      dropdownColor: Colors.blueAccent.shade700,
      icon: Icon(Icons.arrow_drop_down),
      iconSize: 30,
      isExpanded: true,
      style:TextStyle(
        color: Colors.black,
        fontSize: 24,
      ),
      value:valueChoose,
    onChanged: (newValue){
        setState(() {
          valueChoose=newValue as String;;
        });
    },
        items: listItem.map((valueItem){
          return DropdownMenuItem(
              value:valueItem,
              child:Text(valueItem)
          );
        }).toList(),
    );
  }
}


//Navbar
class NavBar extends StatelessWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children:[
          UserAccountsDrawerHeader(
            accountName: const Text("Lathika Kotian",
                style: TextStyle(
                  fontSize: 30, // Font size
                  fontWeight: FontWeight.bold,),
            ),
            accountEmail: const Text("lathikakotian03@gmail.com",
              style: TextStyle(
                fontSize: 16,),
            ),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(child: Image.asset(prof),),
            ),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              image: DecorationImage(image:AssetImage(bg_nav),
              fit: BoxFit.cover),
            ),
          ),
          ListTile(
            leading: Icon(Icons.history_edu,color:Colors.blueAccent.shade700,size:26),
            title: Text("My Records",
              style: TextStyle(
                fontSize: 19,),
            ),
            onTap: ()=>print("my records"),
          ),
          ListTile(
            leading: Icon(Icons.notifications_active_sharp,color:Colors.blueAccent.shade700,size:26),
            title: Text("Notifications",
              style: TextStyle(
                fontSize: 19,),
            ),
            onTap: ()=>print("notification"),
          ),
          ListTile(
            leading: Icon(Icons.app_shortcut_rounded,color:Colors.blueAccent.shade700,size:26),
            title: Text("About App",
              style: TextStyle(
                fontSize: 19,),
            ),
            onTap: ()=>print("About App"),
          ),
          ListTile(
            leading: Icon(Icons.support_agent,color:Colors.blueAccent.shade700,size:26),
            title: Text("Help and Support",
              style: TextStyle(
                fontSize: 19,),
            ),
            onTap: ()=>print("Help and Support"),
          ),
          ListTile(
            leading: Icon(Icons.logout,color:Colors.blueAccent.shade700,size:26),
            title: Text("Logout",
              style: TextStyle(
                fontSize: 19,),
            ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
          ),
        ],
      ),
    );
  }
}



//SLIDE CARAUSEL SLIDER
class ImageSlider extends StatefulWidget {
  const ImageSlider({Key? key}) : super(key: key);
  @override
  State<ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  final myitems=[
    Image.asset(slide1),Image.asset(slide2),Image.asset(slide3),Image.asset(slide5),Image.asset(slide6),
  ];

  int myCurrentIndex=0;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
            items: myitems,
            options: CarouselOptions(
              autoPlay: true,
              height: 200,
              autoPlayCurve: Curves.fastOutSlowIn,
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              autoPlayInterval: const Duration(seconds: 2),
              enlargeCenterPage: true,
              aspectRatio: 2.0,
              onPageChanged: (index,reason){
                setState(() {
                  myCurrentIndex=index;
                });
              },

            ),
        ),
        AnimatedSmoothIndicator(
          activeIndex: myCurrentIndex,
          count: myitems.length,
          effect:WormEffect(
            dotHeight: 8,
            dotWidth: 8,
            spacing: 10,
            activeDotColor: Colors.blue.shade700,
            dotColor: Colors.grey.shade200,
            paintStyle: PaintingStyle.fill,
        ),
      )
      ],
    );
  }
}


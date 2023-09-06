import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medlink/constant/image_string.dart';
import 'package:medlink/views/patient/MainPage.dart';
import 'package:medlink/views/patient/NotificationPage.dart';
import 'package:medlink/views/patient/login.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Define the colors and ratio for blending
  final color1 = Colors.tealAccent.shade400;
  final color2 = Colors.tealAccent.shade700;
  // final color3 = Colors.greenAccent.shade400;
  final ratio = 0.5; // Adjust this ratio to control the mixture

  get mixedColor => Color.lerp(color1, color2, ratio);

  String? valueChoose;
  List listItem=[
    "Mumbai","Delhi","Pune","Chennai"
  ];
  TextEditingController search_name = TextEditingController();
  String searchText='';

  List<Map<String,dynamic>> medCat=[
    {
      'icon':FontAwesomeIcons.userDoctor,
      'category':'General',
    },
    {
      'icon':FontAwesomeIcons.heartPulse,
      'category':'Cardiology',
    },
    {
      'icon':FontAwesomeIcons.hand,
      'category':'Dermatology',
    },
    {
      'icon':FontAwesomeIcons.teeth,
      'category':'Dental',
    },
  ];


  @override

  Widget build(BuildContext context) {
    return Scaffold(
      drawer:NavBar(),

      appBar:AppBar(
        backgroundColor:Colors.blueAccent.shade700,
        iconTheme: IconThemeData(
          color: Colors.white, // Change the color to your desired color
        ),
        title:Center(
          child: Text("MediWise",
            style: TextStyle(
                fontSize: 30,
                color: Colors.white,
                fontWeight: FontWeight.bold),
          ),
        ),
        elevation: 24.0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.notifications,size: 30,color: Colors.white,),
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
                      SizedBox(height: 10,),
                      SizedBox(
                        height: 80,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: List<Widget>.generate(medCat.length, (index) {
                            return Card(
                              elevation: 5,
                              margin: EdgeInsets.only(right: 20.0),
                              // color: Colors.blueAccent.shade700,
                              // color:  Colors.tealAccent.shade100,
                              color:  Colors.blue.shade50,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 15.0,vertical: 10.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    FaIcon(
                                      medCat[index]['icon'],
                                      color: Colors.indigo.shade900,
                                      size:27,
                                    ),

                                    const SizedBox(height: 8,),
                                    Text(medCat[index]['category'],
                                      style: TextStyle(
                                          fontSize: 16,
                                          color:Colors.indigo.shade900,
                                          fontWeight: FontWeight.bold),
                                    ),

                                ],
                              ),),
                            );
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 25,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Appointment Today",
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 10,),
                      AppointmentData(),
                      SizedBox(height: 25,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Top Doctor",
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 10,),
                      //doctor card
                      Column(
                        children:List.generate(10,(index){
                          return DoctorData(
                            route: 'doc_details',
                          );
                        }),
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

//DOCTOR CARD
class DoctorData extends StatelessWidget {
  const DoctorData({Key? key,required this.route}) : super(key: key);
  final String route;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
      height: 150,
      child: GestureDetector(
        child: Card(
          elevation: 5,
          color: Colors.white,
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.only(left: 10,right: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),//or 15.0
                  child: Container(
                    height: 90.0,
                    width: 85.0,
                    color: Color(0xffFF0E58),
                    child: Image.asset(dc_prof,fit: BoxFit.fill,),
                  ),
                ),
              ),
              Flexible(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10,vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Dr Vijay Sharma",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,),),
                      Text("Dental",style: TextStyle(fontSize: 14,fontWeight: FontWeight.normal,),),
                      Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.star_border,color: Colors.yellow,size: 16,),
                          Spacer(),
                          Text('4.5'),
                          Spacer(flex: 1,),
                          Text('Reviews'),
                          Spacer(flex: 1,),
                          Text('(20)'),
                          Spacer(flex: 7,),
                        ],
                      ),
                    ],
                  ),
              ),
              ),
            ],
          ),
        ),
        onTap: (){
          Navigator.of(context).pushNamed(route);
        },
      ),
    );
  }
}


//APPOINTMENT CARD

class AppointmentData extends StatefulWidget {
  const AppointmentData({Key? key}) : super(key: key);

  @override
  State<AppointmentData> createState() => _AppointmentDataState();
}

class _AppointmentDataState extends State<AppointmentData> {
// Define the colors and ratio for blending
  final color1 = Colors.teal.shade50;
  final color2 = Colors.tealAccent.shade100;
  // final color3 = Colors.greenAccent.shade400;
  final ratio = 0.5;

  get mixednewColor => Color.lerp(color1, color2, ratio);


  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color:mixednewColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3), // Shadow color
            spreadRadius: 3, // Spread radius
            blurRadius: 5, // Blur radius
            offset: Offset(0, 2), // Offset of the shadow
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    backgroundImage: AssetImage(dc_prof),
                  ),
                  const SizedBox(width:10,),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:const [
                      Text("Dr Ajay Kumar",style: TextStyle(color: Colors.black,fontSize: 18,fontWeight: FontWeight.bold,),),
                      SizedBox(height: 2,),
                      Text("Dental",style: TextStyle(color: Colors.black54,fontSize: 16,fontWeight: FontWeight.bold,),)
                    ],
                  ),
                ],
              ),
              SizedBox(height: 25,),
              //Shedule details
              ScheduleData(),
              SizedBox(height: 25,),
              //ACTION BUTTON
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: ElevatedButton(
                    style:ElevatedButton.styleFrom(backgroundColor: Colors.redAccent,),
                    onPressed: (){},
                    child: Text("Cancel",style: TextStyle(color: Colors.white,fontSize: 17),),
                  ),
                  ),
                  SizedBox(width: 20,),
                  Expanded(child: ElevatedButton(
                    style:ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent,),
                    onPressed: (){},
                    child: Text("Completed",style: TextStyle(color: Colors.white,fontSize: 17),),
                  ),
                  ),
                ],
              )


            ],
          ),
        ),
      ),

    );
  }
}


class ScheduleData extends StatelessWidget {
  ScheduleData({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // color: Colors.blueAccent.shade100,
        color:Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2), // Shadow color
            spreadRadius: 2, // Spread radius
            blurRadius: 4, // Blur radius
            offset: Offset(0, 2), // Offset of the shadow
          ),
        ],

      ),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.calendar_month_sharp,color: Colors.black,size: 16,),
          SizedBox(width: 4,),
          Text(
            'Monday,11/28/2022',
            style: const TextStyle(color: Colors.black,fontSize: 15,fontWeight: FontWeight.bold),
          ),
          SizedBox(width:15,),
          Icon(Icons.access_alarm_rounded,color: Colors.black,size: 16,),
          SizedBox(width: 4,),
          Flexible(child: Text('2:00 PM',style: TextStyle(color: Colors.black,fontSize: 15,fontWeight: FontWeight.bold),),
          ),
        ],
      ),

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


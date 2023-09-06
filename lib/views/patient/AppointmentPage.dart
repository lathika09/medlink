import 'package:flutter/material.dart';
import 'package:medlink/constant/image_string.dart';
import 'package:medlink/views/patient/home.dart';

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({Key? key}) : super(key: key);

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}
enum FilterStatus {upcoming,complete,cancel}
class _AppointmentPageState extends State<AppointmentPage> {
  FilterStatus status=FilterStatus.upcoming;
  Alignment _alignment=Alignment.centerLeft;

  // Define the colors and ratio for blending
  final color1 = Colors.teal.shade50;
  final color2 = Colors.tealAccent.shade100;
  // final color3 = Colors.greenAccent.shade400;
  final ratio = 0.5;

  get mixednewColor => Color.lerp(color1, color2, ratio);


  List<dynamic> schedules=[
    {
      "doctor_name":"Richard Tan",
      "doctor_profile":dc_prof,
      "category":"Dental",
      "status": FilterStatus.upcoming,
    }, {
      "doctor_name":"Richard Tan",
      "doctor_profile":dc_prof,
      "category":"Dental",
      "status":FilterStatus.complete,
    }, {
      "doctor_name":"Richard Tan",
      "doctor_profile":dc_prof,
      "category":"Dental",
      "status": FilterStatus.complete,
    }, {
      "doctor_name":"Richard Tan",
      "doctor_profile":dc_prof,
      "category":"General",
      "status": FilterStatus.cancel,
    },
  ];
  @override
  Widget build(BuildContext context) {

    List<dynamic> filteredSchedules=schedules.where((var schedule){
      // switch(schedule['status']){
      //   case 'upcoming':
      //     schedule['status']=FilterStatus.upcoming;
      //     break;
      //     case 'complete':
      //       schedule['status']=FilterStatus.complete;
      //       break;
      //       case 'cancel':
      //         schedule['status']=FilterStatus.cancel;
      //         break;
      // }
      return schedule['status']==status;
    }).toList();

    return SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left:20,top: 20,right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Appointment Schedule',textAlign: TextAlign.center,style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
              SizedBox(height: 25,),
              Stack(
                children: [
                  Container(
                    width:double.infinity,
                    height:40,
                    decoration:BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (FilterStatus filterStatus in FilterStatus.values)
                          Expanded(child: GestureDetector(
                            onTap: (){
                              setState(() {
                                if (filterStatus==FilterStatus.upcoming){
                                  status=FilterStatus.upcoming;
                                  _alignment=Alignment.centerLeft;
                                }
                                else if (filterStatus==FilterStatus.complete){
                                  status=FilterStatus.complete;
                                  _alignment=Alignment.center;
                                }
                                else if (filterStatus==FilterStatus.cancel){
                                  status=FilterStatus.cancel;
                                  _alignment=Alignment.centerRight;
                                }
                              });
                            },
                            child: Center(
                              child: Text(filterStatus.name),
                            ),
                          ),
                          ),
                      ],
                    ),
                  ),
                  AnimatedAlign(
                    alignment: _alignment,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      width: 100,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.shade700,
                        borderRadius: BorderRadius.circular(20)
                      ),
                      child: Center(
                        child: Text(status.name,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,),),
                      ),
                    ),
                  ),

                ],
              ),
              SizedBox(height: 25,),
              Expanded(
                  child:ListView.builder(
                    itemCount: filteredSchedules.length,
                      itemBuilder: ((context,index){
                        var _schedule=filteredSchedules[index];
                        bool isLastElement=filteredSchedules.length + 1==index;
                        return Card(

                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Colors.grey,),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          margin: !isLastElement ? EdgeInsets.only(bottom: 20):EdgeInsets.zero,
                          child: Padding(
                              padding: EdgeInsets.all(15),
                            child:Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: AssetImage(_schedule['doctor_profile']),
                                    ),
                                    SizedBox(width: 25,),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(_schedule['doctor_name'],style: TextStyle(color: Colors.black,fontWeight: FontWeight.w800,),),
                                        SizedBox(height: 5,),
                                        Text(_schedule['category'],style: TextStyle(color: Colors.grey.shade700,fontSize:14,fontWeight: FontWeight.w800,),),
                                      ],),
                                  ],),
                                SizedBox(height:15,),
                                ScheduleData(),
                                SizedBox(height: 15,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                        child: OutlinedButton(
                                            onPressed: (){},
                                          style:OutlinedButton.styleFrom(
                                            backgroundColor: Colors.greenAccent,
                                          ),
                                            child:Text(
                                              'Cancel',
                                              style: TextStyle(color: Colors.black),

                                            ),
                                        ),
                                    ),
                                    SizedBox(width: 20,),
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: (){},
                                        style:OutlinedButton.styleFrom(
                                          backgroundColor: Colors.greenAccent,
                                        ),
                                        child:Text(
                                          'Reschedule',
                                          style: TextStyle(color: Colors.black),

                                        ),
                                      ),
                                    ),

                                  ],
                                ),


                            ],
                          ) ,

                        ),
                        );
                  }))
              ),

            ],
          ),
        ),
    );
  }
}

//Schedule
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
          Icon(Icons.calendar_month_sharp,color: Colors.indigo,size: 16,),
          SizedBox(width: 4,),
          Text(
            'Monday,11/28/2022',
            style: const TextStyle(color: Colors.indigo,fontSize: 15,fontWeight: FontWeight.bold),
          ),
          SizedBox(width:15,),
          Icon(Icons.access_alarm_rounded,color: Colors.indigo,size: 16,),
          SizedBox(width: 4,),
          Flexible(child: Text('2:00 PM',style: TextStyle(color: Colors.indigo,fontSize: 15,fontWeight: FontWeight.bold),),
          ),
        ],
      ),

    );
  }
}

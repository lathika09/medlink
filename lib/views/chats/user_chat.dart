import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:medlink/constant/date_utils.dart';
import 'package:medlink/views/chats/chat_screen.dart';
import 'model/message.dart';


class UserCard extends StatefulWidget {
  const UserCard({Key? key,required this.chatId,required this.doctorId,required this.patientId,required this.doctorName, required this.usermail}) : super(key: key);
  final String chatId;
  final String doctorId;
  final String patientId;
  final String doctorName;
  final String usermail;

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {

  Message? _message;
  String msg="start chats";

  Map<String, dynamic> patientData = {};
  Future<void> fetchPatientData() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection("patients").where("email", isEqualTo: widget.usermail).get();
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          patientData = snapshot.docs.first.data() as Map<String, dynamic>;
          print(patientData['name']);
        });
      }
    } catch (e) {
      print("Error fetching doctor data: $e");
    }
  }
  Map<String, dynamic> doctorData = {};
  Future<void> fetchDoctorData() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection("doctor").where("email", isEqualTo: widget.usermail).get();
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          doctorData = snapshot.docs.first.data() as Map<String, dynamic>;
          print(doctorData['name']);
          print("PRINT THIS : ${doctorData['id']}");
        });
      }
    } catch (e) {
      print("Error fetching doctor data: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPatientData();
    fetchDoctorData();


  }
  Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(String chatId) {
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }
  @override
  Widget build(BuildContext context) {
    String? userId = patientData["id"] ?? doctorData["id"];


    return (widget.chatId != null && widget.doctorId != null && widget.patientId != null && userId != null)
        ? Card(
      margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04, vertical: 4),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                chat_id: widget.chatId,
                doc_id: widget.doctorId,
                pat_id: widget.patientId,
                userId: userId,
                Name: widget.doctorName,
              ),
            ),
          );
        },
        child: StreamBuilder(
            stream: getLastMessage(widget.chatId),
            builder: (context,snapshot){
              final data=snapshot.data?.docs;
              final list=data?.map((e) => Message.fromJson(e.data())).toList()??[];
              if (list.isNotEmpty){
                _message=list[0];

              }
          return ListTile(
            leading: CircleAvatar(child: Icon(Icons.person),),
            title: Text(widget.doctorName, style: TextStyle(color: Colors.black, fontSize: 18),),
            subtitle: Text(
              _message!=null
                  ? _message!.type==Type.image ? "Image"
                  :_message!.message : "Start Conversation",
              maxLines: 1,),
            trailing:
              _message==null
              ? null
                  :_message!.read.isEmpty && _message!.senderId!=widget.usermail
              ?Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                  color: Colors.greenAccent.shade400,
                  borderRadius: BorderRadius.circular(10),
                ),
              )
                  : Text(
                MyDateUtil.getLastMessageTime(context: context, time: _message!.sent),
                style: TextStyle(color: Colors.black54),)
            // Text("12:00 PM", style: TextStyle(color: Colors.black54),),
          );
            }
        )
      ),
    )
        : Container();
  }
}


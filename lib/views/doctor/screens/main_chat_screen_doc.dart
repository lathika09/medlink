import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../constant/image_string.dart';
import '../../chats/user_chat.dart';
import 'home_doc.dart';

class MainChatScreenDoc extends StatefulWidget {
  MainChatScreenDoc({Key? key, required this.email}) : super(key: key);
  final String email;
  @override
  State<MainChatScreenDoc> createState() => _MainChatScreenDocState();
}

class _MainChatScreenDocState extends State<MainChatScreenDoc> {


  Future<String> getPatientName(String patientId) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    try {
      DocumentSnapshot patientSnapshot = await _firestore
          .collection('patients')
          .doc(patientId)
          .get();

      if (patientSnapshot.exists) {
        return patientSnapshot.get('name') as String;
      } else {
        return '';
      }
    } catch (e) {
      print('Error fetching patient name: $e');
      return '';
    }
  }


  Future<List<UserCard>> fetchChatsForDoctor(String doctorId) async {
    final FirebaseFirestore _firestore= FirebaseFirestore.instance;

    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('chats')
          .where('participants.doctorId', isEqualTo: doctorId)
          .get();

      List<UserCard> chats = [];

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> chatData = doc.data() as Map<String, dynamic>;

        String chatId = doc.id;
        String patientId = chatData['participants']['patientId'] ?? '';
        String pName = await getPatientName(patientId);


        chats.add(UserCard(
          chatId: chatId,
          doctorId: doctorId,
          patientId: patientId,
          doctorName: pName,
          usermail: widget.email,

        ));
      }

      return chats;
    } catch (e) {
      print('Error fetching chats for doctor: $e');
      return [];
    }
  }

  Map<String, dynamic> doctorData = {};
  Future<void> fetchDoctorData() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection("doctor").where("email", isEqualTo: widget.email).get();
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
    fetchDoctorData();
    // fetchUserData();
    // updateDoctorFCMToken(widget.email);


  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=>FocusScope.of(context).unfocus(),
      child: Scaffold(
          appBar: AppBar(
            backgroundColor:Colors.blueAccent.shade700,
            iconTheme: IconThemeData(
              color: Colors.white,
            ),

            title:Center(
              child: Text(appname,
                style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
            elevation: 24.0,
            actions: <Widget>[IconButton(
          icon: Icon(Icons.refresh,size: 30,color: Colors.blueAccent.shade700,),
        onPressed: () {
          // Navigator.push(context, MaterialPageRoute(builder: (context) => UpdateProfile()),);
        },
      ),]

          ),
          body: doctorData['id'] != null
              ? Column(
            children: [
              FutureBuilder<List<UserCard>>(
                future: fetchChatsForDoctor(doctorData['id']),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    List<UserCard> userCards = snapshot.data ?? [];
                    return ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: userCards.length,
                      itemBuilder: (context, index) {
                        return userCards[index];
                      },
                    );
                  }
                },
              ),
            ],
          )
              : Container(),
      ),
    );
  }
}

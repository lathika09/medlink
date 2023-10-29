import 'dart:developer';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medlink/views/chats/api.dart';
import 'package:medlink/views/chats/model/message.dart';
import '../../constant/date_utils.dart';
import 'message_card.dart';


class ChatScreen extends StatefulWidget {
  final String chat_id;
  final String doc_id;
  final String pat_id;
  final String userId;
  final String Name;

  ChatScreen({Key? key,required this.chat_id,required this.doc_id,required this.pat_id, required this.userId, required this.Name}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  String? _profileImageUrl;
  String? lastActiveString;

  //PATIENT INFO STORED
  Map<String, dynamic> patientData = {};
  Future<void> fetchPatientData() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection("patients").where("id", isEqualTo: widget.pat_id).get();
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

  //DOCTOR INFO
  Map<String, dynamic> doctorData = {};
  Future<void> fetchDoctorData() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection("doctor").where("id", isEqualTo: widget.doc_id).get();
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

  Map<String, dynamic> receiverData = {};
  Future<void> fetchUserData(String userId,String pat_id,String docId) async {
    try {
      print("object   userid : $userId");
      String collectionName = userId == pat_id ? 'doctor' : 'patients';
      String receiverId = userId == pat_id ? docId : pat_id;
      // final snapshotDoc= await FirebaseFirestore.instance.collection("doctor").where("id", isEqualTo: widget.userId).get();
      final snapshotPat= await FirebaseFirestore.instance.collection(collectionName).where("id", isEqualTo: receiverId).get();

      if (snapshotPat.docs.isNotEmpty) {
        setState(() {
          receiverData = snapshotPat.docs.first.data() as Map<String, dynamic>;
        });
      }
      print("hiiiiii${receiverData['name']}");
    } catch (e) {
      print("Error fetching doctor data: $e");
    }
  }


  // Send MESSAGE AND STORE IN FIRESTORE
  Future<void> sendMessage(String chatRoomId, String senderId,String toId, String message,Type type) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    //OBJECT
    final Message messageData = Message(
      toId: toId,
      message: message,
      read: '',
      type: type,
      senderId: senderId,
      sent: time,
    );

    final ref = FirebaseFirestore.instance.collection('chats/$chatRoomId/messages/');

    try {

      // String newtoId= senderId == widget.pat_id ?  widget.doc_id:widget.pat_id;
      await ref.doc(time).set(messageData.toJson()).then((value) =>APIs.sendPushNotification(chatRoomId,senderId,widget.pat_id,widget.doc_id,type == Type.text ? message : 'Image'));
    }
    catch (e) {
      print('Error sending message: $e');
    }
    // String collectionName = senderId == widget.pat_id ?'patients' : 'doctor' ;
    //
    // final ref1 = FirebaseFirestore.instance.collection(collectionName);
    //
    // try {
    //   await ref1.doc(senderId).update(
    //       {
    //         'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
    //       })
    //   ;
    // }
    // catch (e) {
    //   print('Error last_active: $e');
    // }
  }

  // ALL MSG DISPLAY
  Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(String chatId) {
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  //SEND IMG
  Future<void> sendChatImage(String chatId, String senderId,String toId, File file) async {
    final ext = file.path.split('.').last;
    final ref = FirebaseStorage.instance.ref().child(
        'images/$chatId/${DateTime.now().millisecondsSinceEpoch}.$ext');
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatId,senderId,toId, imageUrl,Type.image);
  }


  Future<void> loadProfileImage() async {
    final DocumentSnapshot dataDoc= await APIs.getReceiverInfo(widget.userId, widget.pat_id,widget.doc_id, );

    final imageUrl = await APIs.getProfileImageUrl(dataDoc['email']!);
    if (imageUrl != null) {
      setState(() {
        _profileImageUrl = imageUrl;
        print("PROFILE found");
      });
    }
    print("PROFILE not found ");
  }

  Future<void> callLastActiveString(String userId,String docId,String patId) async {

    final lastActivecall=await APIs.getLastActiveString(widget.userId, widget.doc_id, widget.pat_id,);
    if (lastActivecall != null) {
      setState(() {
        lastActiveString =lastActivecall;
        print("lastActivecalled");
      });
    }
    print("lastActivecall not ");
  }

  Future<void> updateActiveStatus(bool isOnline,String userId,String patientId,String doc_id) async {
    String collectionName = userId == patientId ? 'patients' : 'doctor';
    // final DocumentSnapshot dataDoc= await APIs.getUserInfo(userId, patientId);
    print("In update active");

    FirebaseFirestore.instance.collection(collectionName).doc(userId).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': await APIs.getSelfPushToken(userId,patientId),
    });
  }

  List<Message> list = [];
  final textController=TextEditingController();


  @override
  void initState() {
    super.initState();
    fetchPatientData();
    fetchDoctorData();
    loadProfileImage();
    fetchUserData(widget.userId,widget.pat_id,widget.doc_id);
    print("vhxgbxjhbkxjhx");
    APIs.updateFirebaseMessagingToken(widget.userId, widget.pat_id);
    // APIs.getPushToken(widget.userId, widget.pat_id);

    // callLastActiveString(widget.userId,widget.doc_id,widget.pat_id);
    print("STATUS OF ONLINE OR NOT ");

    SystemChannels.lifecycle.setMessageHandler((message) async {
      print('Message: $message');

      if (widget.userId.isNotEmpty) {
        if (message.toString().contains('resume')) {
          await updateActiveStatus(true,widget.userId,widget.pat_id,widget.doc_id);
        }
        if (message.toString().contains('pause')) {
          await updateActiveStatus(false,widget.userId,widget.pat_id,widget.doc_id);
        }
      }
      // else{
      //   updateActiveStatus(false,personalId!,widget.patientId,widget.doctorId);
      // }

      return Future.value(message);

    });

  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }



  bool  _isUploading=false;
  @override
  Widget build(BuildContext context) {
    print("hiiiguiii${receiverData['last_active']}");
    return GestureDetector(
      onTap: ()=>FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: InkWell(
                onTap: (){},
                child:Container(
                  color: Colors.blueAccent.shade700,
                  padding: EdgeInsets.symmetric(vertical: 4,horizontal: 0),
                  child: Row(
                    children: [
                      IconButton(
                          onPressed: (){
                            Navigator.pop(context);
                            // Navigator.pushReplacement( context,
                            //   MaterialPageRoute(builder: (context) =>MainChatScreenDoc(email: widget.email),),
                            // );
                          },
                          icon: const Icon(Icons.arrow_back,color: Colors.white,)),
                      CircleAvatar(
                        radius: MediaQuery.of(context).size.width*0.09,
                        child: _profileImageUrl != null
                          ? ClipOval(
                        child: Image.network(
                          _profileImageUrl!,
                        ),
                      )
                          : Icon(
                        Icons.person,
                      ),),
                      SizedBox(width: 10,),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.Name,style: TextStyle(fontSize: 16,color: Colors.white,fontWeight: FontWeight.w500),),
                          SizedBox(height: 2,),

                          // Text("Last seen not available",style: TextStyle(fontSize: 13,color: Colors.grey.shade300,),),
                          Text(

                            receiverData['last_active'] !=null  ? receiverData['is_online']
                                  ? 'Online'
                                  : MyDateUtil.getLastActiveTime(
                                  context: context,
                                  lastActive: receiverData['last_active'])
                                      : "Last seen not available ",
                            style: const TextStyle(
                                fontSize: 13, color: Color.fromARGB(255, 234, 245, 255)),
                              ),

                        ],
                      )
                    ],
                  ),

                ),
              ),
            ),
            backgroundColor: Color.fromARGB(255, 234, 248, 255),
            body:Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                    // stream: null,
                    stream: getAllMessages(widget.chat_id),
                    builder: (context,snapshot){
                      switch (snapshot.connectionState){
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          // return const Center(child: CircularProgressIndicator(),);
                          return SizedBox();
                        case ConnectionState.active:
                        case ConnectionState.done:
                        final data=snapshot.data?.docs;
                          list=data?.map((e) => Message.fromJson(e.data())).toList()??[];
                          if(list.isNotEmpty){
                            return ListView.builder(
                              reverse: true,
                                itemCount:list.length,
                                physics:BouncingScrollPhysics(),
                                padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.01),
                                itemBuilder: (context,index){
                                  return MessageCard(message:list[index], userId: widget.userId, chatId: widget.chat_id,);
                                });
                          }
                          else{
                            return const Center(
                              child: Text("Say Hii 👋 ",style: TextStyle(fontSize: 20),),
                            );
                          }

                      }


                    }, ),
                ),

                if (_isUploading)
                  const Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                          padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                          child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ),

                //INPUT BOX
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal:MediaQuery.of(context).size.width*0.025,vertical: MediaQuery.of(context).size.height*0.01),
                  child: Row(
                    children: [
                      Expanded(
                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          child: Row(
                            children: [
                              SizedBox(width:MediaQuery.of(context).size.width*0.05),

//textfild
                              Expanded(
                                  child: TextField(
                                    controller:textController,
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null,
                                    decoration: InputDecoration(
                                        hintText: "Type Something...",
                                        hintStyle: TextStyle(color: Colors.blueAccent),
                                        border:InputBorder.none
                                    ),
                                  )
                              ),

                              //img gallery
                              IconButton(onPressed: () async {
                                final ImagePicker picker = ImagePicker();

                                final List<XFile> images = await picker.pickMultiImage(imageQuality: 70);

                                // sending image one
                                for (var i in images) {
                                  log('Image Path: ${i.path}');
                                  setState(() => _isUploading = true);

                                  if (widget.userId == widget.pat_id){
                                    await sendChatImage(
                                        widget.chat_id,widget.userId,widget.doc_id, File(i.path));
                                  }
                                  else{
                                    await sendChatImage(
                                        widget.chat_id,widget.userId,widget.pat_id, File(i.path));
                                  }
                                  setState(() => _isUploading = false);
                                }
                              },
                                  icon:Icon(Icons.image,color: Colors.blueAccent.shade400,)),

                              //camera
                              IconButton(onPressed: () async {
                                final ImagePicker picker = ImagePicker();

                                // Pick image
                                final XFile? image = await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
                                if (image != null) {
                                  log('Image Path: ${image.path}');
                                  setState(() => _isUploading = true);
                                  
                                  if (widget.userId == widget.pat_id){
                                    await sendChatImage(
                                        widget.chat_id,widget.userId,widget.doc_id, File(image.path));
                                  }
                                  else{
                                    await sendChatImage(
                                        widget.chat_id,widget.userId,widget.pat_id, File(image.path));
                                  }

                                  setState(() => _isUploading = false);
                                }
                              },
                                  icon:Icon(Icons.camera_alt,color: Colors.blueAccent.shade400,)),
                              SizedBox(width: MediaQuery.of(context).size.width*0.02,),
                            ],
                          ),
                        ),
                      ),

                      //send msg
                      MaterialButton(
                        onPressed: (){
                          if (textController.text.isNotEmpty) {
                            if (widget.userId == widget.pat_id){
                              sendMessage(widget.chat_id, widget.userId, widget.doc_id, textController.text,Type.text);
                              textController.text="";
                            }
                            else{
                              sendMessage(widget.chat_id, widget.userId, widget.pat_id, textController.text,Type.text);
                              textController.text="";
                            }


                          }

                        },
                        minWidth:0,
                        padding: EdgeInsets.only(top: 10,bottom: 10,right: 5,left: 10),
                        shape: CircleBorder(),
                        color: Colors.greenAccent.shade700,
                        child: Icon(Icons.send,color: Colors.white,size: 28,),
                      )
                    ],
                  ),
                ),
              ],
            )
        ),
      ),
    );
  }
}


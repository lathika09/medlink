import 'package:flutter/material.dart';
import 'package:medlink/views/chats/api.dart';
import 'package:medlink/views/chats/user_chat.dart';

class MainChatScreen extends StatefulWidget {
  const MainChatScreen({Key? key}) : super(key: key);

  @override
  State<MainChatScreen> createState() => _MainChatScreenState();
}

class _MainChatScreenState extends State<MainChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:Colors.blueAccent.shade700,
        iconTheme: IconThemeData(
          color: Colors.white, // Change the color to your desired color
        ),
        leading: IconButton(
            onPressed: (){Navigator.pop(context);},
            icon: const Icon(
              Icons.arrow_back,
              size:20,
              color: Colors.white,)
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
            icon: Icon(Icons.search,size: 30,color: Colors.white,),
            onPressed: () {},
          ),
        ],
      ),
      body:StreamBuilder(
          stream: APIs.firestore.collection("doctor").snapshots(),
          builder: (context,snapshot){
        return ListView.builder(
            itemCount: 10,
            physics:BouncingScrollPhysics(),
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.01)
            ,
            itemBuilder: (context,index){
              return UserCard();
            });
      })
    );
  }
}

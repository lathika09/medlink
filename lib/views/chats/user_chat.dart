import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserCard extends StatefulWidget {
  const UserCard({Key? key}) : super(key: key);

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.04,vertical: 4),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: (){},
        child: const ListTile(
          leading: CircleAvatar(child: Icon(Icons.person),),
          title: Text("User",style: TextStyle(color: Colors.black,fontSize: 18),),
          subtitle: Text("Last user message",maxLines: 1,),
          trailing: Text("12:00 PM",style: TextStyle(color: Colors.black54),),
        ),
      ),
    );
  }
}

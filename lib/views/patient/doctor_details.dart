import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medlink/constant/image_string.dart';


class DocDetails extends StatefulWidget {
  const DocDetails({Key? key}) : super(key: key);

  @override
  State<DocDetails> createState() => _DocDetailsState();
}

class _DocDetailsState extends State<DocDetails> {
  bool isFav=false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        appTitle: "Doctor Details",
        icon: FaIcon(Icons.arrow_back_ios),
        actions: [
          IconButton(
              onPressed: (){
                setState(() {
                  isFav=!isFav;
                });
              },
              icon: FaIcon(
                  isFav ? Icons.favorite_rounded: Icons.favorite_outline,
                color: Colors.red,
              ),),
        ],

      ),
      body: SafeArea(child: Column(
        children: [
          AboutDoctor(),
        ],
      )),
    );
  }
}

//ABOUT DOCTOR
class AboutDoctor extends StatelessWidget {
  const AboutDoctor({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        children: [
          SizedBox(height: 10,),
          CircleAvatar(
            radius: 65.0,
            backgroundImage: AssetImage(dc_prof),
            backgroundColor: Colors.white,
          ),
          SizedBox(height: 30,),
          Text("Dr Vijay Sharma",style: TextStyle(color: Colors.black,fontSize: 24.0,fontWeight: FontWeight.bold),),

        ],
      ),
    );
  }
}



//CUSTOM APP BAR
class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  CustomAppBar({Key? key,this.appTitle,this.route,this.icon,this.actions}) : super(key: key);

  @override

  Size get preferredSize=>const Size.fromHeight(60);
  final String? appTitle;
  final String? route;
  final FaIcon?icon;
  final List<Widget>? actions;

  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: true,
      backgroundColor: Colors.white,
      elevation:2,
      title: Text(widget.appTitle!,style: TextStyle(fontSize: 20,color: Colors.black),),
      leading: widget.icon!=null ? Container(
        margin: const EdgeInsets.symmetric(horizontal: 10,vertical: 10,),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.blueAccent.shade700,
        ),
        child: IconButton(
          onPressed: (){
            if(widget.route!=null){
              Navigator.of(context).pushNamed(widget.route!);
            }
            else{
              Navigator.of(context).pop();
            }
          },
          icon: widget.icon!,
          iconSize: 16,
          color: Colors.white,
        ),
      )
          : null,
      actions: widget.actions ?? null,

    );
  }
}


import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DocDetails extends StatefulWidget {
  const DocDetails({Key? key}) : super(key: key);
  @override
  State<DocDetails> createState() => _DocDetailsState();
}

class _DocDetailsState extends State<DocDetails> {
  bool isFav=false;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
    ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
final String email=args['email'];
    final String pemail=args['pemail'];

    final String description = args['description'];


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
      body: SafeArea(child: SingleChildScrollView(
        child: Container(
          color: Colors.blue.shade50,
          child: Column(
            children: [
              AboutDoctor(),
              SizedBox(height: 8,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0,vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text("About Doctor",style: TextStyle(fontWeight: FontWeight.w600,fontSize: 20,)),
                    SizedBox(height: 10,),
                    Text(description,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                        height: 1.2,
                      ),
                      softWrap: true,
                      textAlign: TextAlign.justify,
                    ),

                  ],
                ),
              ),

              Padding(padding: EdgeInsets.all(15),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent.shade700,
                    ),
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed(
                        "booking_Page",
                        arguments: {
                          'email':email,
                          'pemail':pemail,
                        },
                      );

                    },
                    child: Text(
                      "Book Appointment",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  )

              ),
            ],
          ),
        ),
      )),
    );
  }
}

//ABOUT DOCTOR
class AboutDoctor extends StatefulWidget {
  const AboutDoctor({Key? key}) : super(key: key);

  @override
  State<AboutDoctor> createState() => _AboutDoctorState();
}

class _AboutDoctorState extends State<AboutDoctor> {

  //DOC IMAGE
  String? _profileImageUrl;
  Future<String?> getProfileImageUrl(String userEmail) async {
    try {
      final Reference storageReference =
      FirebaseStorage.instance.ref().child('prof_images/$userEmail.jpg');

      final String downloadURL = await storageReference.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print('Error getting profile image URL: $e');
      return null;
    }
  }
  Future<void> loadProfileImage() async {
    final Map<String, dynamic> args =
    ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;

    // final String email = args['email'];

    final imageUrl = await getProfileImageUrl(args['email']);
    if (imageUrl != null) {
      setState(() {

        _profileImageUrl = imageUrl;
        print("LATHIKA : ${_profileImageUrl} and ${args['email']}");
      });
    }
    print("PROFILE");
  }

  @override
  void initState() {
    super.initState();
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadProfileImage();

  }


  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
    ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;

    final String name = args['name'];
    final String speciality = args['speciality'];
    final String qualification = args['qualification'];
    final String hospital = args['hospital'];
    final String address = args['address'];
    final String experience = args['experience'];
    // final String email = args['email'];
    // final Map<String, dynamic> availability = args['availability'];
    // List<int> weekdays = availability['weekday'] ?? [];
    // List<String> time = availability['time'] ?? [];

    return Container(
      width: double.infinity,
      child: Column(
        children: [
          SizedBox(height: 10,),
          CircleAvatar(
            radius: 60,
            backgroundImage: _profileImageUrl != null
                ? NetworkImage(_profileImageUrl!)
                :NetworkImage("https://www.pngitem.com/pimgs/m/421-4212266_transparent-default-avatar-png-default-avatar-images-png.png"), // Provide a default image

          ),
          SizedBox(height: 12,),
          Text(name,style: TextStyle(color: Colors.black,fontSize: 26.0,fontWeight: FontWeight.bold),),
          SizedBox(height: 3,),
          SizedBox(
            width: MediaQuery.of(context).size.width*0.75,
            child: Text(
              speciality,
              style: TextStyle(color: Colors.grey.shade800,fontSize: 20),
              softWrap: true,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 3,),
          Container(
            padding: EdgeInsets.symmetric(vertical: 15,horizontal: 12),
            margin: EdgeInsets.symmetric(vertical: 10,horizontal: 15),

            decoration: BoxDecoration(
              color: Colors.white,
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(FontAwesomeIcons.bookMedical,color: Colors.blueAccent.shade700,size: 18,),
                    DoctorInfo(data: "Qualification : ", info:qualification)
                  ],),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(FontAwesomeIcons.hospital,color: Colors.blueAccent.shade700,size: 18,),
                    DoctorInfo(data: "Hospital : ", info:hospital)
                  ],),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(FontAwesomeIcons.mapLocation,color: Colors.blueAccent.shade700,size: 18,),
                    DoctorInfo(data: "Location : ", info: address)
                  ],),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(FontAwesomeIcons.briefcaseMedical,color: Colors.blueAccent.shade700,size: 18,),
                    DoctorInfo(data: "Experience : ", info: experience),
                  ],),
              ],),
          ),




        ],
      ),
    );
  }
}


//
class DoctorInfo extends StatelessWidget {
  DoctorInfo({Key? key,required this.data,required this.info}) : super(key: key);
  final String data;
  final String info;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(data,
            style: TextStyle(color: Colors.black87,fontSize: 16,fontWeight: FontWeight.w600),
            softWrap: true,
            textAlign: TextAlign.left,
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width*0.4,//0.47
          child: Text(info,
            style: TextStyle(color: Colors.black87,fontSize: 16,fontWeight: FontWeight.w600),
            softWrap: true,
            textAlign: TextAlign.left,
          ),
        ),
      ],
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
      backgroundColor: Colors.blueAccent.shade700,
      elevation:2,
      title: Text(widget.appTitle!,style: TextStyle(fontSize: 24,color: Colors.white,fontWeight: FontWeight.bold),),
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


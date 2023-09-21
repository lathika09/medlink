import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get/get_utils/src/get_utils/get_utils.dart';
import 'package:medlink/views/doctor/login_doc.dart';
import 'package:medlink/views/patient/home.dart';
//import 'package:medlink/constant/image_string.dart';
import 'package:medlink/views/patient/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DocRepository extends GetxController{
  static DocRepository get instance=>Get.find();
  final db=FirebaseFirestore.instance;
  Future getDocDetails(String email)async{
    final snapshot=await db.collection("doctor").where("email",isEqualTo: email).get();
    final doctorData=snapshot.docs.first.data();
    return doctorData;
  }

}
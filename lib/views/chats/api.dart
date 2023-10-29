import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';

class APIs {

  static FirebaseAuth auth = FirebaseAuth.instance;

  static Future<String?> getProfileImageUrl(String userEmail) async {
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

  static Future<String?> getLastActiveString(String userId, String docId, String patientId) async {
    try {
      String collectionName = userId == patientId ? 'doctor' : 'patients';
      String receiverId = userId == patientId ? docId : patientId;

      var snap= await FirebaseFirestore.instance
          .collection(collectionName)
          .where('id', isEqualTo: receiverId)
          .get();

      if (snap.docs.isNotEmpty) {
        String lastActiveString = snap.docs[0]['last_active'] as String;
        return lastActiveString;
      } else {
        return null;
      }
    } catch (e) {

      print('Error retrieving last active timestamp: $e');
      return null;
    }
  }


//Future<DocumentSnapshot<Map<String, dynamic>>>
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfolist(String userId, String patientId,String docId) {

    String collectionName = userId == patientId ? 'doctor' : 'patients';
    String receiverId = userId == patientId ? 'docId' : 'patientId';

    return FirebaseFirestore.instance
        .collection(collectionName)
        .where('id', isEqualTo: receiverId)
        .snapshots();
  }

  static Future<DocumentSnapshot<Map<String, dynamic>>> getReceiverInfo(String userId, String patientId,String docId) async {
    String collectionName = userId == patientId ? 'doctor' : 'patients';
    String receiverId = userId == patientId ? docId : patientId;
    try {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(receiverId)
          .get();

      return documentSnapshot;
    } catch (e) {
      print('Error getting user info: $e');
      throw e;
    }

  }


  static Future<DocumentSnapshot<Map<String, dynamic>>> getUserInfo(String userId, String patientId) async {
    String collectionName = userId == patientId ? 'patients':'doctor' ;
    try {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(userId)
          .get();

      return documentSnapshot;
    } catch (e) {
      print('Error getting user info: $e');
      throw e;
    }

  }

// for accessing Firebase Messaging (Push Notification)
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

// Function to get and update firebase essaging tken for a specific user by email
  static Future<void> updateFirebaseMessagingToken(String userId, String patientId) async {
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    // Get the Firebase Messaging token
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    String collectionName = userId == patientId ? 'patients' : 'doctor';
    print("push token : ${fcmToken}");
    if (fcmToken != null) {
      await FirebaseFirestore.instance
          .collection(collectionName)
          .where('id', isEqualTo: userId)
          .get()
          .then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          final userDoc = querySnapshot.docs.first;

          // Update the FCM token field in the user document
          userDoc.reference.update({'push_token': fcmToken}).then((_) {
            print('FCM Token updated for user with id $userId');
          }).catchError((error) {
            print('Error updating FCM token: $error');
          });
        } else {
          print('User with id $userId not found');
        }
      }).catchError((error) {
        print('Error querying user: $error');
      });
    } else {
      print('Failed to get FCM token');
    }
  }



  // Function to retrieve the push token for a specific user
 static Future<String> getPushToken(String userId,String patientId,String docId) async {
   String collectionName = userId == patientId ? 'doctor' : 'patients';
   String receiverId = userId == patientId ? docId : patientId;
    var userDoc = await FirebaseFirestore.instance
        .collection(collectionName)
        .where('id', isEqualTo: receiverId)
        .get();

    if (userDoc.docs.isNotEmpty) {
      return userDoc.docs.first.data()['push_token'];
    } else {
      return '';
    }
  }
  static Future<String> getSelfPushToken(String userId,String patientId) async {
   String collectionName = userId == patientId ?  'patients':'doctor' ;
    var userDoc = await FirebaseFirestore.instance
        .collection(collectionName)
        .where('id', isEqualTo: userId)
        .get();

    if (userDoc.docs.isNotEmpty) {
      return userDoc.docs.first.data()['push_token'];
    } else {
      return '';
    }
  }


  // Function to retrieve the name of a specific user
 static Future<String> getUserName(String userId,String patientId) async {
    String collectionName = userId == patientId ?  'patients':'doctor';
    var userDoc = await FirebaseFirestore.instance
        .collection(collectionName)
        .where('id', isEqualTo: userId)
        .get();

    if (userDoc.docs.isNotEmpty) {
      return userDoc.docs.first.data()['name'];
    } else {
      return '';
    }
  }
// for sending push notification
  static Future<void> sendPushNotification(
      String chatId,String userId,String patientId,String docId,String msg) async {
    try {

      String toPushToken = await APIs.getPushToken(userId,patientId,docId);
print("push TOKEN : ${toPushToken}");

      String fromName = await APIs.getUserName(userId,patientId);
      final body = {
        "to": toPushToken,
        "notification": {
          "title": fromName,
          "body": msg,
          "android_channel_id": "chats"
        },
      };
      print("BODY : ${body}");

      var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
            'key=AAAAy9xXtIc:APA91bEhA8pdBJrX9lAl7GMvp8eUcooVfnokiathTx7m1z-0U7vJ6jwWDXj-pkCS_3E7MMXmTmH3Bpt-MFJgGjuspKUnMtkxj1tPnGiLnntYnTg6DFY9EOCNzLeiIKGTAP6EgUCsAbeQ'
          },
          body: jsonEncode(body));
      log('Response status: ${res.statusCode}');
      log('Response body: ${res.body}');
    }
    catch (e) {
      log('\nsendPushNotificationE: $e');
    }
  }
  // for accessing firebase storage
  static FirebaseStorage storage = FirebaseStorage.instance;

  static Future<String?> getDocIdByEmail(String email) async {
    CollectionReference patients = FirebaseFirestore.instance.collection('patients');

    QuerySnapshot querySnapshot = await patients.where('email', isEqualTo: email).get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.id;
    } else {
      return null;

    }
  }
}









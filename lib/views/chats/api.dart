import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';

class APIs {


 static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(String userId, String patientId) {
    // Define the collection to query based on the condition
    String collectionName = userId == patientId ? 'doctor' : 'patients';

    return FirebaseFirestore.instance
        .collection(collectionName)
        .where('id', isEqualTo: userId)
        .snapshots();
  }
//messaging
//   static FirebaseMessaging fMessaging = FirebaseMessaging.instance;
//
//   static  Future<void> getFirebaseMessagingToken() async{
//     await fMessaging.requestPermission();
//     await fMessaging.getToken().then((t){
//       if (t!=null){
//
//       }
//     });
//
//   }
//

// for accessing Firebase Messaging (Push Notification)
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

// Function to get and update Firebase Messaging Token for a specific user by email
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
 static Future<String> getPushToken(String userId,String patientId) async {
   String collectionName = userId == patientId ? 'doctor' : 'patients';
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
    String collectionName = userId == patientId ?  'patients':'doctor';    var userDoc = await FirebaseFirestore.instance
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
      String chatId,String userId,String patientId,String msg) async {
    try {
      // Retrieve the push token of the 'toId' (patientId)
      String toPushToken = await getPushToken(userId,patientId);

      // Retrieve the name of 'userId'
      String fromName = await getUserName(userId,patientId);

      final body = {
        "to": toPushToken,
        "notification": {
          "title": fromName, //our name should be send
          "body": msg,
          "android_channel_id": "chats"
        },
  // "data": {
  //   "some_data": "User ID: ${userId}",
  // },
      };

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
      //String? docId = await getDocIdByEmail('johndoe@example.com');
    }
  }
}






//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:http/http.dart';
//
// import '../models/chat_user.dart';
// import '../models/message.dart';
//
// class APIs {
//   // for authentication
//   static FirebaseAuth auth = FirebaseAuth.instance;
//
//   // for accessing cloud firestore database
//   static FirebaseFirestore firestore = FirebaseFirestore.instance;
//
//   // for accessing firebase storage
//   static FirebaseStorage storage = FirebaseStorage.instance;
//
//   // for storing self information
//   static ChatUser me = ChatUser(
//       id: user.uid,
//       name: user.displayName.toString(),
//       email: user.email.toString(),
//       about: "Hey, I'm using We Chat!",
//       image: user.photoURL.toString(),
//       createdAt: '',
//       isOnline: false,
//       lastActive: '',
//       pushToken: '');
//
//   // to return current user
//   static User get user => auth.currentUser!;
//
//   // for accessing firebase messaging (Push Notification)
//   static FirebaseMessaging fMessaging = FirebaseMessaging.instance;
//
//   // for getting firebase messaging token
//   static Future<void> getFirebaseMessagingToken() async {
//     await fMessaging.requestPermission();
//
//     await fMessaging.getToken().then((t) {
//       if (t != null) {
//         me.pushToken = t;
//         log('Push Token: $t');
//       }
//     });
//
//     // for handling foreground messages
//     // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//     //   log('Got a message whilst in the foreground!');
//     //   log('Message data: ${message.data}');
//
//     //   if (message.notification != null) {
//     //     log('Message also contained a notification: ${message.notification}');
//     //   }
//     // });
//   }
//
//   // for sending push notification
//   static Future<void> sendPushNotification(
//       ChatUser chatUser, String msg) async {
//     try {
//       final body = {
//         "to": chatUser.pushToken,
//         "notification": {
//           "title": me.name, //our name should be send
//           "body": msg,
//           "android_channel_id": "chats"
//         },
//         // "data": {
//         //   "some_data": "User ID: ${me.id}",
//         // },
//       };
//
//       var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
//           headers: {
//             HttpHeaders.contentTypeHeader: 'application/json',
//             HttpHeaders.authorizationHeader:
//             'key=AAAAQ0Bf7ZA:APA91bGd5IN5v43yedFDo86WiSuyTERjmlr4tyekbw_YW6JrdLFblZcbHdgjDmogWLJ7VD65KGgVbETS0Px7LnKk8NdAz4Z-AsHRp9WoVfArA5cNpfMKcjh_MQI-z96XQk5oIDUwx8D1'
//           },
//           body: jsonEncode(body));
//       log('Response status: ${res.statusCode}');
//       log('Response body: ${res.body}');
//     } catch (e) {
//       log('\nsendPushNotificationE: $e');
//     }
//   }
//
//   // for checking if user exists or not?
//   static Future<bool> userExists() async {
//     return (await firestore.collection('users').doc(user.uid).get()).exists;
//   }
//
//   // for adding an chat user for our conversation
//   static Future<bool> addChatUser(String email) async {
//     final data = await firestore
//         .collection('users')
//         .where('email', isEqualTo: email)
//         .get();
//
//     log('data: ${data.docs}');
//
//     if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
//       //user exists
//
//       log('user exists: ${data.docs.first.data()}');
//
//       firestore
//           .collection('users')
//           .doc(user.uid)
//           .collection('my_users')
//           .doc(data.docs.first.id)
//           .set({});
//
//       return true;
//     } else {
//       //user doesn't exists
//
//       return false;
//     }
//   }
//
//   // for getting current user info
//   static Future<void> getSelfInfo() async {
//     await firestore.collection('users').doc(user.uid).get().then((user) async {
//       if (user.exists) {
//         me = ChatUser.fromJson(user.data()!);
//         await getFirebaseMessagingToken();
//
//         //for setting user status to active
//         APIs.updateActiveStatus(true);
//         log('My Data: ${user.data()}');
//       } else {
//         await createUser().then((value) => getSelfInfo());
//       }
//     });
//   }
//
//   // for creating a new user
//   static Future<void> createUser() async {
//     final time = DateTime.now().millisecondsSinceEpoch.toString();
//
//     final chatUser = ChatUser(
//         id: user.uid,
//         name: user.displayName.toString(),
//         email: user.email.toString(),
//         about: "Hey, I'm using We Chat!",
//         image: user.photoURL.toString(),
//         createdAt: time,
//         isOnline: false,
//         lastActive: time,
//         pushToken: '');
//
//     return await firestore
//         .collection('users')
//         .doc(user.uid)
//         .set(chatUser.toJson());
//   }
//
//   // for getting id's of known users from firestore database
//   static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
//     return firestore
//         .collection('users')
//         .doc(user.uid)
//         .collection('my_users')
//         .snapshots();
//   }
//
//   // for getting all users from firestore database
//   static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
//       List<String> userIds) {
//     log('\nUserIds: $userIds');
//
//     return firestore
//         .collection('users')
//         .where('id',
//         whereIn: userIds.isEmpty
//             ? ['']
//             : userIds) //because empty list throws an error
//     // .where('id', isNotEqualTo: user.uid)
//         .snapshots();
//   }
//
//   // for adding an user to my user when first message is send
//   static Future<void> sendFirstMessage(
//       ChatUser chatUser, String msg, Type type) async {
//     await firestore
//         .collection('users')
//         .doc(chatUser.id)
//         .collection('my_users')
//         .doc(user.uid)
//         .set({}).then((value) => sendMessage(chatUser, msg, type));
//   }
//
//   // for updating user information
//   static Future<void> updateUserInfo() async {
//     await firestore.collection('users').doc(user.uid).update({
//       'name': me.name,
//       'about': me.about,
//     });
//   }
//
//   // update profile picture of user
//   static Future<void> updateProfilePicture(File file) async {
//     //getting image file extension
//     final ext = file.path.split('.').last;
//     log('Extension: $ext');
//
//     //storage file ref with path
//     final ref = storage.ref().child('profile_pictures/${user.uid}.$ext');
//
//     //uploading image
//     await ref
//         .putFile(file, SettableMetadata(contentType: 'image/$ext'))
//         .then((p0) {
//       log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
//     });
//
//     //updating image in firestore database
//     me.image = await ref.getDownloadURL();
//     await firestore
//         .collection('users')
//         .doc(user.uid)
//         .update({'image': me.image});
//   }
//
//   // for getting specific user info
//   static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
//       ChatUser chatUser) {
//     return firestore
//         .collection('users')
//         .where('id', isEqualTo: chatUser.id)
//         .snapshots();
//   }
//
//   // update online or last active status of user
//   static Future<void> updateActiveStatus(bool isOnline) async {
//     firestore.collection('users').doc(user.uid).update({
//       'is_online': isOnline,
//       'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
//       'push_token': me.pushToken,
//     });
//   }
//
//   ///************** Chat Screen Related APIs **************
//
//   // chats (collection) --> conversation_id (doc) --> messages (collection) --> message (doc)
//
//   // useful for getting conversation id
//   static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
//       ? '${user.uid}_$id'
//       : '${id}_${user.uid}';
//
//   // for getting all messages of a specific conversation from firestore database
//   static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
//       ChatUser user) {
//     return firestore
//         .collection('chats/${getConversationID(user.id)}/messages/')
//         .orderBy('sent', descending: true)
//         .snapshots();
//   }
//
//   // for sending message
//   static Future<void> sendMessage(
//       ChatUser chatUser, String msg, Type type) async {
//     //message sending time (also used as id)
//     final time = DateTime.now().millisecondsSinceEpoch.toString();
//
//     //message to send
//     final Message message = Message(
//         toId: chatUser.id,
//         msg: msg,
//         read: '',
//         type: type,
//         fromId: user.uid,
//         sent: time);
//
//     final ref = firestore
//         .collection('chats/${getConversationID(chatUser.id)}/messages/');
//     await ref.doc(time).set(message.toJson()).then((value) =>
//         sendPushNotification(chatUser, type == Type.text ? msg : 'image'));
//   }
//
//   //update read status of message
//   static Future<void> updateMessageReadStatus(Message message) async {
//     firestore
//         .collection('chats/${getConversationID(message.fromId)}/messages/')
//         .doc(message.sent)
//         .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
//   }
//
//   //get only last message of a specific chat
//
//
//   //send chat image
//   static Future<void> sendChatImage(ChatUser chatUser, File file) async {
//     //getting image file extension
//     final ext = file.path.split('.').last;
//
//     //storage file ref with path
//     final ref = storage.ref().child(
//         'images/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');
//
//     //uploading image
//     await ref
//         .putFile(file, SettableMetadata(contentType: 'image/$ext'))
//         .then((p0) {
//       log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
//     });
//
//     //updating image in firestore database
//     final imageUrl = await ref.getDownloadURL();
//     await sendMessage(chatUser, imageUrl, Type.image);
//   }
//
//   //delete message
//   static Future<void> deleteMessage(Message message) async {
//     await firestore
//         .collection('chats/${getConversationID(message.toId)}/messages/')
//         .doc(message.sent)
//         .delete();
//
//     if (message.type == Type.image) {
//       await storage.refFromURL(message.msg).delete();
//     }
//   }
//
//   //update message
//   static Future<void> updateMessage(Message message, String updatedMsg) async {
//     await firestore
//         .collection('chats/${getConversationID(message.toId)}/messages/')
//         .doc(message.sent)
//         .update({'msg': updatedMsg});
//   }
// }
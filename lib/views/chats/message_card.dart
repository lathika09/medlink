import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:medlink/constant/date_utils.dart';
import 'package:medlink/views/chats/model/message.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({Key? key,required this.message, required this.userId, required this.chatId}) : super(key: key);
  final Message message;
  final String userId;
  final String chatId;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {

  //READ OR UNREADMSG
  Future<void> updateMessageReadStatus(String chatId, Message message) async {
    final documentReference = FirebaseFirestore.instance
        .collection('chats/$chatId/messages')
        .doc(message.sent);

    final documentSnapshot = await documentReference.get();

    if (documentSnapshot.exists) {
      await documentReference.update({
        'read': DateTime.now().millisecondsSinceEpoch.toString(),
      });
    }
    else {
      print('Document not found: $chatId/messages/${message.sent}');
    }
  }

  //delete message
  Future<void> deleteMessage(String chatId,Message message) async {
    await FirebaseFirestore.instance
        .collection('chats/$chatId/messages/')
        .doc(message.sent)
        .delete();

    if (message.type == Type.image) {
      await FirebaseStorage.instance.refFromURL(message.message).delete();
    }
  }

  //update message
  Future<void> updateMessage(String chatId,Message message, String updatedMsg) async {
    await FirebaseFirestore.instance
        .collection('chats/$chatId/messages/')
        .doc(message.sent)
        .update({'msg': updatedMsg});
  }


  @override
  Widget build(BuildContext context) {
    bool isMe=widget.userId==widget.message.senderId;
    return InkWell(
      onLongPress: (){
        _showBottomSheet(isMe);
      },
      child: isMe
          ? greenMessage()
          :blueMessage(),
    );
  }

  //another msg
Widget blueMessage(){
    if(widget.message.read.isEmpty){
      updateMessageReadStatus(widget.chatId, widget.message);
      log("message read updated");

    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type==Type.image ? MediaQuery.of(context).size.width*0.03:MediaQuery.of(context).size.width*0.04),
            margin: EdgeInsets.symmetric(horizontal:MediaQuery.of(context).size.width*0.03,vertical: MediaQuery.of(context).size.height*0.009 ),
            decoration: BoxDecoration(
                color: Color.fromARGB(255, 221, 245, 255),
                borderRadius: BorderRadius.only(
                  topLeft:Radius.circular(30) ,
                  topRight:Radius.circular(30) ,
                  bottomRight:Radius.circular(30) ,
                ),
              border: Border.all(color: Colors.lightBlue),
            ),
            child:
            widget.message.type==Type.text
                ?
            Text(
              widget.message.message,
              style: TextStyle(fontSize: 16,color: Colors.black),)
                :ClipRRect(
              borderRadius: BorderRadius.circular(MediaQuery.of(context).size.height * .03),
              child: CachedNetworkImage(
                imageUrl:widget.message.message,
                placeholder: (context,url)=>const CircularProgressIndicator(strokeWidth: 2,),
                errorWidget: (context, url, error) => const CircleAvatar(
                    child: Icon(Icons.person,size: 70,)),
              ),
            ),

          ),
        ),
        Padding(
          padding:EdgeInsets.only(right:MediaQuery.of(context).size.width*0.04),
          child: Text(
            MyDateUtil.getFormattedTime(context: context, time: widget.message.sent),
            style: TextStyle(fontSize:13,color: Colors.black54),),
        )
      ],
    );
}

//our msg
Widget greenMessage(){
    return  Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(width: MediaQuery.of(context).size.width*0.04,),
            if(widget.message.read.isNotEmpty) const Icon(Icons.done_all_rounded,color: Colors.blue,size: 20,),
            SizedBox(width: 2,),
            //sent time
            Text(
              MyDateUtil.getFormattedTime(context: context, time: widget.message.sent),
              style: TextStyle(fontSize:13,color: Colors.black54),),
          ],
        ),
        Flexible(
          child: Container(
            padding:  EdgeInsets.all(widget.message.type==Type.image ? MediaQuery.of(context).size.width*0.03:MediaQuery.of(context).size.width*0.04),
            margin: EdgeInsets.symmetric(horizontal:MediaQuery.of(context).size.width*0.03,vertical: MediaQuery.of(context).size.height*0.009 ),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 218, 255, 176),
              borderRadius: BorderRadius.only(
                topLeft:Radius.circular(30) ,
                topRight:Radius.circular(30) ,
                bottomLeft:Radius.circular(30) ,
              ),
              border: Border.all(color: Colors.lightGreen),
            ),
            child:
            widget.message.type==Type.text ?
            Text(widget.message.message,
              style: TextStyle(fontSize: 16,color: Colors.black),)
                :ClipRRect(
              borderRadius: BorderRadius.circular(MediaQuery.of(context).size.height * .03),
              child: CachedNetworkImage(
                imageUrl:widget.message.message,
                placeholder: (context,url)=>const CircularProgressIndicator(strokeWidth: 2,),
                errorWidget: (context, url, error) => const CircleAvatar(
                    child: Icon(Icons.person,size: 70,)),
              ),
            ),
          ),
        ),
      ],
    );
}

  void _showBottomSheet(bool isMe) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            children: [
              //black divider
              Container(
                height: 4,
                margin: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * .015, horizontal: MediaQuery.of(context).size.width * .4),
                decoration: BoxDecoration(
                    color: Colors.grey, borderRadius: BorderRadius.circular(8)),
              ),

              widget.message.type == Type.text ?
              //copy option
              _OptionItem(
                  icon: const Icon(Icons.copy_all_rounded,
                      color: Colors.blue, size: 26),
                  name: 'Copy Text',
                  onTap: () async {
                    await Clipboard.setData(
                        ClipboardData(text: widget.message.message))
                        .then((value) {
                      Navigator.pop(context);

                      Dialogs.showSnackbar(context, 'Text Copied!!');
                    });
                  })
                  :
              //save option
              _OptionItem(
                  icon: const Icon(Icons.download_rounded,
                      color: Colors.blue, size: 26),
                  name: 'Save Image',
                  onTap: () async {
                    try {
                      log('Image Url: ${widget.message.message}');
                      await GallerySaver.saveImage(widget.message.message,
                          albumName: 'MediWise')
                          .then((success) {
                        Navigator.pop(context);
                        log("show : $success");
                        if (success != null && success) {
                          Dialogs.showSnackbar(
                              context, 'Image Successfully Saved!');
                        }
                        else{
                          log("failed");
                        }
                      });
                    } catch (e) {
                      log('ErrorWhileSavingImg: $e');
                    }
                  }),

              //separator
              if (isMe)
                Divider(
                  color: Colors.black54,
                  endIndent: MediaQuery.of(context).size.width * .04,
                  indent: MediaQuery.of(context).size.width * .04,
                ),

              //delete option
              if (isMe)
                _OptionItem(
                    icon: const Icon(Icons.delete_forever,
                        color: Colors.red, size: 26),
                    name: 'Delete Message',
                    onTap: () async {
                      await deleteMessage(widget.chatId,widget.message).then((value) {
                        Navigator.pop(context);
                      });
                    }),

              //separator
              Divider(
                color: Colors.black54,
                endIndent: MediaQuery.of(context).size.width * .04,
                indent: MediaQuery.of(context).size.width * .04,
              ),

              //sent time
              _OptionItem(
                  icon: const Icon(Icons.remove_red_eye, color: Colors.blue),
                  name:
                  'Sent At: ${MyDateUtil.getMessageTime(context: context, time: widget.message.sent)}',
                  onTap: () {}),

              //read time
              _OptionItem(
                  icon: const Icon(Icons.remove_red_eye, color: Colors.green),
                  name: widget.message.read.isEmpty
                      ? 'Read At: Not seen yet'
                      : 'Read At: ${MyDateUtil.getMessageTime(context: context, time: widget.message.read)}',
                  onTap: () {}),
            ],
          );
        }
        );
  }
}
class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;

  const _OptionItem(
      {required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => onTap(),
        child: Padding(
          padding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * .05,
              top:  MediaQuery.of(context).size.height * .015,
              bottom:  MediaQuery.of(context).size.height * .015),
          child: Row(children: [
            icon,
            Flexible(
                child: Text('    $name',
                    style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                        letterSpacing: 0.5)))
          ]),
        ));
  }
}

class Dialogs {
  static void showSnackbar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: Colors.blue.withOpacity(.8),
        behavior: SnackBarBehavior.floating));
  }

  static void showProgressBar(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) => const Center(child: CircularProgressIndicator()));
  }
}
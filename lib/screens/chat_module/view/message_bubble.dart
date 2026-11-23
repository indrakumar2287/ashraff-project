

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get/state_manager.dart';
import 'package:intl/intl.dart';
import 'package:shopping_app/screens/auth/controller/auth_controller.dart';

class MessageBubble extends StatefulWidget {
   MessageBubble({super.key, 

     required this.msg, 
  });

 
  Map<String, dynamic> msg ; 



  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {

  
    String? message ;
  String? sendername ;
  bool   isSender  = false;
   String? imagepath ; 

@override
  void initState() {
    String myId = FirebaseAuth.instance.currentUser?.uid ?? '' ; 
     message= widget.msg['message'] ?? '' ; 
     isSender= (widget.msg['senderId'].toString() == myId ) ;
     sendername= widget.msg['senderName'].toString() ?? '' ; 
     if(widget.msg['type'] == 'image'){
      imagepath = widget.msg['image'] ; 
     }

     setState(() {});
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
  

    String createdAt = '' ; 
   if(widget.msg['createdAt'] != null){
 createdAt =  DateFormat('h:mm a').format((widget.msg['createdAt'] as Timestamp).toDate() ) ;
    
   }
    

    return Column(
      // crossAxisAlignment: CrossAxisAlignment.end ,
      crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
         Text(sendername ?? '', style: TextStyle(
          color: Colors.blue
         ),),


         imagepath != null ? 
         
         Container(
          width: Get.width * 0.4,
          padding: EdgeInsets.all(5),
          margin: EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.black26
            )
          ),
          child:  Image.network(imagepath ?? '')
        )
        
        : 
        Container(
          // width: Get.width * 0.2,
          padding: EdgeInsets.all(5),
          margin: EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.black26
            )
          ),
          child: Text(message ?? ''),
        ),
        Text( createdAt.toString())
      ],
    ).paddingSymmetric(vertical: 10);
  }
}

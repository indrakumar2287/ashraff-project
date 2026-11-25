import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.msg});

  final Map<String, dynamic> msg;

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final isSender = msg['senderId']?.toString() == currentUserId;
    final message = msg['message']?.toString() ?? '';
    final senderName = msg['senderName']?.toString() ?? '';
    final imagePath = msg['type'] == 'image' ? msg['image']?.toString() : null;
    final createdAtValue = msg['createdAt'];
    final createdAt = createdAtValue is Timestamp
        ? DateFormat('h:mm a').format(createdAtValue.toDate())
        : '';

    return Column(
      crossAxisAlignment: isSender
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(senderName, style: const TextStyle(color: Colors.blue)),
        if (imagePath != null)
          Container(
            width: Get.width * 0.4,
            padding: const EdgeInsets.all(5),
            margin: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black26),
            ),
            child: Image.network(imagePath),
          )
        else
          Container(
            padding: const EdgeInsets.all(5),
            margin: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black26),
            ),
            child: Text(message),
          ),
        Text(createdAt),
      ],
    ).paddingSymmetric(vertical: 10);
  }
}

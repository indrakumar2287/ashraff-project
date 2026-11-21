import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:shopping_app/route_names.dart';
import 'package:shopping_app/screens/auth/controller/auth_controller.dart';
import 'package:shopping_app/utils/custom_toast.dart';

class ChatModuleController extends GetxController {
  Stream<QuerySnapshot<Map<String, dynamic>>> loadUsers() {
    final myUserId = FirebaseAuth.instance.currentUser?.uid;

    return FirebaseFirestore.instance
        .collection("Users")
        .where(FieldPath.documentId, isNotEqualTo: myUserId)
        .snapshots();

    // print("Data>> ${data.docs?.firstOrNull?.metadata}") ;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> loadChats() {
    return FirebaseFirestore.instance
        .collection("User Chats")
        .where(
          'membersIds',
          arrayContains: FirebaseAuth.instance.currentUser?.uid ?? '',
        )
        .snapshots();

    // print("Data>> ${data.docs?.firstOrNull?.metadata}") ;
  }

  RxBool isLoading = false.obs;
  void createANdOpenNewChat(String name, String userId) async {
    isLoading.value = true;
    try {
      final currentUser = await FirebaseAuth.instance.currentUser;
      final data = await FirebaseFirestore.instance.collection("User Chats").add({
        'createdAt': FieldValue.serverTimestamp(),
        'updateddAt': FieldValue.serverTimestamp(),
        "memberNames": [userName, name],
        "membersIds": [currentUser?.uid ?? '', userId],
        "lastMessage": '',
        "lastMessageTime": FieldValue.serverTimestamp(),
      });
      print("ID generated >> ${data.id}") ;

      selectedUsername.value = name;

      selectedUserId.value = userId;
      selectedChatId.value = data.id ; 

      Get.toNamed(RouteNames.chatModuleScreen);

      showSnackBar(text: "New Chat created!", isSuccess: true);
    } on Exception catch (e) {
      print("Error >> $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<String> getOtherUserName(List userNames) async {
    List list = userNames.where((item) => item != userName).toList();
    return list.firstOrNull;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getChat(String docId) {
    return FirebaseFirestore.instance
        .collection("User Chats")
        .doc(docId)
        .collection("Messages")
        .snapshots();

    // print("Data>> ${data.docs?.firstOrNull?.metadata}") ;
  }

  RxString selectedUsername = ''.obs;
  RxString selectedUserId = ''.obs;
  RxString selectedChatId = ''.obs;

  TextEditingController msgController = TextEditingController();
  void sendMessage() async {
    if (msgController.text.isEmpty) {
      return;
    }
    try {
      final currentUser = await FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance.collection("User Chats").doc(selectedChatId.value).collection("Messages").add({
        'createdAt': FieldValue.serverTimestamp(),
        'updateddAt': FieldValue.serverTimestamp(),
        "senderId": currentUser?.uid,
        "senderName": userName,
        "message" : msgController.text.toString() , 
        "attachments" : ''
      });

      msgController.clear() ; 

      
    } on Exception catch (e) {
      print("Error >> $e");
    }
  }
}

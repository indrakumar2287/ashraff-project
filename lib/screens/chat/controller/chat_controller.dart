import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:shopping_app/route_names.dart';
import 'package:shopping_app/screens/auth/controller/auth_controller.dart';
import 'package:shopping_app/services/chat_local_database.dart';
import 'package:shopping_app/utils/custom_toast.dart';

class ChatController extends GetxController {
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _messageSubscription;
  Stream<List<Map<String, dynamic>>>? localMessagesStream;

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
      final currentUser = FirebaseAuth.instance.currentUser;
      final data = await FirebaseFirestore.instance
          .collection("User Chats")
          .add({
            'createdAt': FieldValue.serverTimestamp(),
            'updateddAt': FieldValue.serverTimestamp(),
            "memberNames": [userName, name],
            "membersIds": [currentUser?.uid ?? '', userId],
            "lastMessage": '',
            "lastMessageTime": FieldValue.serverTimestamp(),
          });
      await openChat(data.id, userId, name);

      Get.toNamed(RouteNames.chatModuleScreen);

      showSnackBar(text: "New Chat created!", isSuccess: true);
    } on Exception catch (e) {
      debugPrint("Error >> $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<String> getOtherUserName(List userNames) async {
    List list = userNames.where((item) => item != userName).toList();
    return list.firstOrNull;
  }

  Future<String> getOtherUserId(List userIds) async {
    final myId = FirebaseAuth.instance.currentUser?.uid ?? '';
    List list = userIds.where((item) => item != myId).toList();

    return list.firstOrNull;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getChat(String docId) {
    return FirebaseFirestore.instance
        .collection("User Chats")
        .doc(docId)
        .collection("Messages")
        .orderBy('createdAt', descending: false)
        .snapshots();

    // print("Data>> ${data.docs?.firstOrNull?.metadata}") ;
  }

  RxString selectedUsername = ''.obs;
  RxString selectedUserId = ''.obs;
  RxString selectedChatId = ''.obs;

  Future<void> openChat(
    String chatId,
    String otherUserId,
    String otherUserName,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('A signed-in user is required to open a chat.');
    }

    selectedChatId.value = chatId;
    selectedUserId.value = otherUserId;
    selectedUsername.value = otherUserName;
    localMessagesStream = ChatLocalDatabase.instance
        .watchMessages(ownerUid: user.uid, chatId: chatId)
        .map((rows) => rows.map(_messageForDisplay).toList(growable: false));

    await _messageSubscription?.cancel();
    _messageSubscription = getChat(chatId).listen(
      (snapshot) {
        unawaited(_saveMessageSnapshot(user.uid, chatId, snapshot));
      },
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('Failed to receive chat messages: $error\n$stackTrace');
      },
    );
    update();
  }

  Future<void> _saveMessageSnapshot(
    String ownerUid,
    String chatId,
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) async {
    final rows = snapshot.docs
        .map((document) {
          final data = document.data();
          final createdAt = data['createdAt'];

          return <String, Object?>{
            'owner_uid': ownerUid,
            'chat_id': chatId,
            'remote_message_id': document.id,
            'sender_id': data['senderId']?.toString() ?? '',
            'sender_name': data['senderName']?.toString() ?? '',
            'message': data['message']?.toString() ?? '',
            'message_type': data['type']?.toString() ?? 'text',
            'image': data['image']?.toString(),
            'created_at_ms': createdAt is Timestamp
                ? createdAt.millisecondsSinceEpoch
                : null,
          };
        })
        .toList(growable: false);

    try {
      await ChatLocalDatabase.instance.saveMessages(
        ownerUid: ownerUid,
        chatId: chatId,
        messages: rows,
      );
    } on Exception catch (error, stackTrace) {
      debugPrint('Failed to cache chat messages: $error\n$stackTrace');
    }
  }

  Map<String, dynamic> _messageForDisplay(Map<String, Object?> row) {
    final createdAtMs = row['created_at_ms'];
    return {
      'senderId': row['sender_id']?.toString() ?? '',
      'senderName': row['sender_name']?.toString() ?? '',
      'message': row['message']?.toString() ?? '',
      'type': row['message_type']?.toString() ?? 'text',
      'image': row['image']?.toString(),
      'createdAt': createdAtMs is int
          ? Timestamp.fromMillisecondsSinceEpoch(createdAtMs)
          : null,
    };
  }

  @override
  void onClose() {
    _messageSubscription?.cancel();
    msgController.dispose();
    super.onClose();
  }

  TextEditingController msgController = TextEditingController();
  Future<void> sendMessage() async {
    if (msgController.text.isEmpty) {
      return;
    }
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance
          .collection("User Chats")
          .doc(selectedChatId.value)
          .collection("Messages")
          .add({
            'createdAt': FieldValue.serverTimestamp(),
            'updateddAt': FieldValue.serverTimestamp(),
            "senderId": currentUser?.uid,
            "senderName": userName,
            "message": msgController.text.toString(),
            "attachments": '',
            "type": "text",
          });

      try {
        await FirebaseFirestore.instance
            .collection("User Chats")
            .doc(selectedChatId.value)
            .set({
              'lastMessage': msgController.text.toString(),
            }, SetOptions(merge: true));
      } on Exception catch (e) {
        debugPrint("Error Lastmsg >> $e");
      }

      msgController.clear();
    } on Exception catch (e) {
      debugPrint("Error >> $e");
    }
  }

  void sendMediaMsg(String type, String media) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance
          .collection("User Chats")
          .doc(selectedChatId.value)
          .collection("Messages")
          .add({
            'createdAt': FieldValue.serverTimestamp(),
            'updateddAt': FieldValue.serverTimestamp(),
            "senderId": currentUser?.uid,
            "senderName": userName,
            "attachments": '',
            "image": media,
            "type": "image",
          });
    } on Exception catch (e) {
      debugPrint("Error >> $e");
    }
  }
}

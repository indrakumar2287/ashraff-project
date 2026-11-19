import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopping_app/route_names.dart';
import 'package:shopping_app/screens/chat/controller/chat_controller.dart';

class NewChatScreen extends StatefulWidget {
  const NewChatScreen({super.key});

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  late final ChatController _controller;
  late final Future<List<ChatUser>> _users;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ChatController>();
    _users = _controller.loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New chat')),
      body: FutureBuilder<List<ChatUser>>(
        future: _users,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Could not load users: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.isEmpty) {
            return const Center(child: Text('No other users found.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final user = snapshot.data![index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(
                    user.name.isEmpty ? '?' : user.name[0].toUpperCase(),
                  ),
                ),
                title: Text(user.name),
                subtitle: Text(user.email),
                onTap: () => _startChat(user),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _startChat(ChatUser user) async {
    try {
      final chatId = await _controller.openChat(user);
      if (!mounted) return;
      Get.toNamed(
        RouteNames.chatRoom,
        arguments: ChatRoomArguments(chatId: chatId, otherUserName: user.name),
      );
    } on FirebaseException catch (error) {
      Get.snackbar('Chat error', error.message ?? error.code);
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopping_app/screens/chat/controller/chat_module_controller.dart';

class NewChatScreen extends StatefulWidget {
  const NewChatScreen({super.key});

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  @override
  Widget build(BuildContext context) {
    Get.put(ChatController());
    return GetBuilder<ChatController>(
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(title: const Text("Create New Chat")),
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: controller.loadUsers(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Could not load users: ${snapshot.error}'),
                      );
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final users = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index].data();
                        return ListTile(
                          onTap: () => controller.createANdOpenNewChat(
                            user['name']?.toString() ?? '',
                            users[index].id,
                          ),
                          tileColor: Colors.grey.withAlpha(100),
                          title: Text(user['name']?.toString() ?? ''),
                        ).paddingAll(5);
                      },
                    );
                  },
                ),
              ),
            ],
          ).paddingAll(10),
        );
      },
    );
  }
}

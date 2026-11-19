import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopping_app/route_names.dart';
import 'package:shopping_app/screens/chat/controller/chat_controller.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChatController());

    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body: controller.currentUser == null
          ? _SignInMessage()
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: controller.chatsForCurrentUser(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Could not load chats: ${snapshot.error}'),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final userId = controller.currentUser!.uid;
                final chats =
                    snapshot.data!.docs
                        .map(
                          (document) =>
                              ChatConversation.fromDocument(document, userId),
                        )
                        .toList()
                      ..sort(
                        (first, second) => (second.updatedAt ?? DateTime(0))
                            .compareTo(first.updatedAt ?? DateTime(0)),
                      );

                if (chats.isEmpty) {
                  return const Center(
                    child: Text('No chats yet. Tap + to start one.'),
                  );
                }

                return ListView.builder(
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          chat.otherUserName.isEmpty
                              ? '?'
                              : chat.otherUserName[0].toUpperCase(),
                        ),
                      ),
                      title: Text(chat.otherUserName),
                      subtitle: Text(
                        chat.lastMessage.isEmpty
                            ? 'Start chatting'
                            : chat.lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => Get.toNamed(
                        RouteNames.chatRoom,
                        arguments: ChatRoomArguments(
                          chatId: chat.id,
                          otherUserName: chat.otherUserName,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(RouteNames.newChat),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _SignInMessage extends StatelessWidget {
  const _SignInMessage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Sign in to use chat.'),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => Get.toNamed(RouteNames.loginScreen),
            child: const Text('Sign in'),
          ),
        ],
      ),
    );
  }
}

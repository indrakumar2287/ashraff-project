import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopping_app/screens/chat/controller/chat_controller.dart';
import 'package:shopping_app/screens/chat/view/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatController>(
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(title: Text(controller.selectedUsername.value)),
          body: Column(
            children: [
              Expanded(
                child: controller.selectedUserId.value.isNotEmpty
                    ? StreamBuilder<List<Map<String, dynamic>>>(
                        stream: controller.localMessagesStream,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                'Could not load messages: ${snapshot.error}',
                              ),
                            );
                          }
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final messages = snapshot.data!;
                          return ListView.builder(
                            controller: scrollController,
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              return MessageBubble(msg: messages[index]);
                            },
                          );
                        },
                      )
                    : const SizedBox(),
              ),
              Container(
                height: 100,
                padding: const EdgeInsets.all(5),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller.msgController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: () => controller.sendMediaMsg('image', testImage),
                      child: const Icon(Icons.image),
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: () async {
                        await controller.sendMessage();
                        if (scrollController.hasClients) {
                          await scrollController.animateTo(
                            scrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        }
                      },
                      child: const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ],
          ).paddingAll(10),
        );
      },
    );
  }
}

const String testImage =
    'https://www.hocalwire.com/h-upload/uid/UrqcwKUWdSIBFwKspwg7hiPlTyX5TAoB7033284.jpg';

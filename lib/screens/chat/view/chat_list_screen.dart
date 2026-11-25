import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopping_app/route_names.dart';
import 'package:shopping_app/screens/auth/controller/auth_controller.dart';
import 'package:shopping_app/screens/chat/controller/chat_module_controller.dart';

class ChatUsersListScreen extends StatefulWidget {
  const ChatUsersListScreen({super.key});

  @override
  State<ChatUsersListScreen> createState() => _ChatUsersListScreenState();
}

class _ChatUsersListScreenState extends State<ChatUsersListScreen> {
  @override
  Widget build(BuildContext context) {
    Get.put(ChatController());

    return Scaffold(
      appBar: AppBar(title: Text("Chats")),
      body: Column(
        children: [
          Expanded(
            child: GetBuilder<ChatController>(
              builder: (controller) {
                return Column(
                  children: [
                    Expanded(
                      child: StreamBuilder(
                        stream: controller.loadChats(),
                        builder: (context, snapshotStream) {
                          if (!snapshotStream.hasData) {
                            return Center(child: CircularProgressIndicator());
                          }
                          final users = snapshotStream.data!.docs;
                          return ListView.builder(
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              final user = users[index].data();
                              // print("User >> ${user}");
                              final List memberNames =
                                  user['memberNames'] ?? [];
                              final List memberIds = user['membersIds'] ?? [];
                              final String lastMessage =
                                  user['lastMessage'] ?? '';
                              //  final String otherUserName =  await controller.getOtherUserName(memberNames) ;

                              return FutureBuilder(
                                future: controller.getOtherUserId(memberIds),
                                builder: (context, snapshot1) {
                                  return FutureBuilder(
                                    future: controller.getOtherUserName(
                                      memberNames,
                                    ),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return CircularProgressIndicator();
                                      }
                                      return ListTile(
                                        onTap: () {
                                          controller.selectedUsername.value =
                                              snapshot.data?.toString() ?? '';
                                          controller.selectedUserId.value =
                                              snapshot1.data?.toString() ?? '';

                                          // TODO
                                          controller.selectedChatId.value =
                                              users[index].id;

                                          Get.toNamed(
                                            RouteNames.chatModuleScreen,
                                          );
                                        },
                                        tileColor: Colors.grey.withAlpha(100),
                                        title: Text(
                                          snapshot.data?.toString() ?? '',
                                        ),
                                        subtitle: Text(
                                          lastMessage,
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ).paddingAll(5);
                                    },
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ).paddingAll(10);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await getUserName();
          Get.toNamed(RouteNames.newChatModule);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

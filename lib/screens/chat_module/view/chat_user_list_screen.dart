import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopping_app/route_names.dart';
import 'package:shopping_app/screens/auth/controller/auth_controller.dart';
import 'package:shopping_app/screens/chat_module/controller/chat_module_controller.dart';

class ChatUsersListScreenState extends StatefulWidget {
  const ChatUsersListScreenState({super.key});

  @override
  State<ChatUsersListScreenState> createState() =>
      _ChatUsersListScreenStateState();
}

class _ChatUsersListScreenStateState extends State<ChatUsersListScreenState> {


  @override
  Widget build(BuildContext context) {
    Get.put(ChatModuleController());

    return Scaffold(
      appBar: AppBar(title: Text("Chats")),
      body: Column(
        children: [
          Expanded(
            child: GetBuilder<ChatModuleController>(
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
                          print(
                            "Users List >> ${snapshotStream.data?.docs?.firstOrNull?.data() ?? ''}",
                          );
                          final users = snapshotStream.data?.docs ?? [];
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
                                              users[index].id ?? ''; 
                                  
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
                                }
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
          print("My username > ${await getUserName()}");
          Get.toNamed(RouteNames.newChatModule);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

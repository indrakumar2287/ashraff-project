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
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return CircularProgressIndicator();
                          }
                          print(
                            "Users List >> ${snapshot.data?.docs?.firstOrNull?.data() ?? ''}",
                          );
                          final users = snapshot.data?.docs ?? [];
                          return ListView.builder(
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              final user = users[index].data();
                              print("User >> ${user['memberNames']}");
                              final List memberNames = user['memberNames'];
                              //  final String otherUserName =  await controller.getOtherUserName(memberNames) ;

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

                                      // TODO
                                      //  controller.selectedUserId.value = userId;
                                      //  controller.selectedChatId.value = data.id ;

                                      Get.toNamed(RouteNames.chatModuleScreen);
                                    },
                                    tileColor: Colors.grey.withAlpha(100),
                                    title: Text(
                                      snapshot.data?.toString() ?? '',
                                    ),
                                  ).paddingAll(5);
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
          print("My username > ${await getUserName()}");
          Get.toNamed(RouteNames.newChatModule);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

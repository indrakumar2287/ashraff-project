import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/get_utils/src/extensions/export.dart';
import 'package:shopping_app/screens/auth/controller/auth_controller.dart';
import 'package:shopping_app/screens/chat_module/controller/chat_module_controller.dart';
import 'package:shopping_app/screens/chat_module/view/message_bubble.dart';

class ChatModuleScreen extends StatefulWidget {
  const ChatModuleScreen({super.key});

  @override
  State<ChatModuleScreen> createState() => _ChatModuleScreenState();
}

class _ChatModuleScreenState extends State<ChatModuleScreen> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatModuleController>(
        builder: (controller) {
              
          return Scaffold(
              appBar: AppBar(title: Text(controller.selectedUsername.value)),
            body: Column(
              children: [
                Expanded(
                  child: controller.selectedUserId.value.isNotEmpty
                      ? StreamBuilder(
                          stream: controller.getChat(
                            controller.selectedChatId.value,
                          ),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return CircularProgressIndicator();
                            }
                             print(
                            "Msg List >> ${snapshot.data?.docs?.firstOrNull?.data() ?? ''}",
                          );
                          final messages = snapshot.data?.docs ?? [];
                          return ListView.builder(
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final msg = messages[index].data();
                              // print("Msg >> ${msg['message']}");

                              String myId =
                                  FirebaseAuth.instance.currentUser?.uid ?? '';

                              print("My ID > $userId ");
                              print(
                                "Sender ID > ${msg['senderId'].toString()} ",
                              );

                              return MessageBubble(msg: msg);
                              return ListTile(
                                    tileColor: Colors.grey.withAlpha(100),
                                    title: Text(
                                      msg['message'].toString() ?? '',
                                    ),
                                  ).paddingAll(5);
                                
                            },
                          );
                      
                          },
                        )
                      : SizedBox(),
                ),
            
                Container(
                  height: 100,
                  padding: EdgeInsets.all(5),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller.msgController,
                          decoration: InputDecoration(border: OutlineInputBorder()),
                        ),
                      ),

                    SizedBox(width: 20),
                    GestureDetector(
                      onTap: () {
                        controller.sendMediaMsg('image', testImage);
                      },
                      child: Icon(Icons.image),
                    ), 
                      SizedBox(width: 20,),
                      GestureDetector(
                        onTap: (){
                          controller.sendMessage();

                        },
                        child: Icon(Icons.send))
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






final String testImage =
    'https://www.hocalwire.com/h-upload/uid/UrqcwKUWdSIBFwKspwg7hiPlTyX5TAoB7033284.jpg';

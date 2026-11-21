import 'package:flutter/material.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/state_manager.dart';
import 'package:get/utils.dart';
import 'package:shopping_app/screens/chat_module/controller/chat_module_controller.dart';

class NewChatModuleScreen extends StatefulWidget {
  const NewChatModuleScreen({super.key});

  @override
  State<NewChatModuleScreen> createState() => _NewChatModuleScreenState();
}

class _NewChatModuleScreenState extends State<NewChatModuleScreen> {
  @override
  Widget build(BuildContext context) {
    Get.put(ChatModuleController()) ; 
    return GetBuilder<ChatModuleController>(
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(title: Text("Create New Chat")),
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder(
                  stream: controller.loadUsers(),
                  builder: (context, snapshot) {
                    if(!snapshot.hasData){
                      return CircularProgressIndicator() ; 
                    }
                    print("Users List >> ${snapshot.data?.docs?.firstOrNull?.data() ?? ''}") ;
                    final users = snapshot.data?.docs ?? [] ;
                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index){
                        final user = users[index].data() ; 

                      return ListTile(
                        onTap: (){
                          controller.createANdOpenNewChat(user['name'] , users[index].id) ; 
                        },
                        tileColor: Colors.grey.withAlpha(100),
                        
                        title: Text(user['name']),
                      ).paddingAll(5
                      ) ; 
                    }) ; 
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

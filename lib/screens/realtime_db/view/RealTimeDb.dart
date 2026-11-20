import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/realtime_db_controller.dart';

class RealtimeDb extends StatefulWidget {
  const RealtimeDb({super.key});

  @override
  State<RealtimeDb> createState() => _RealtimeDbState();
}

class _RealtimeDbState extends State<RealtimeDb> {
  @override
  Widget build(BuildContext context) {
    Get.put(RealtimeDbController());
    return GetBuilder<RealtimeDbController>(
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(title: Text("RealTime DB")),
          body: Column(
            children: [
              Obx(() {
                return Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller.bookNameController,
                      ),
                    ),
                    controller.isLoading.value == true
                        ? CircularProgressIndicator()
                        : IconButton(
                            onPressed: () {
                              controller.addBookname();
                            },
                            icon: Icon(Icons.send),
                          ),
                  ],
                );
              }),

              Expanded(
                child: StreamBuilder(
                  stream: controller.getBookNames(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }
                    final docs = snapshot.data?.docs ?? [];
                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          onTap: (){
                            controller.showBookDetails(docs[index].id) ;
                          },
                          title: Text(docs[index]['name'].toString()),
                          trailing: GestureDetector(
                            onTap: () {
                              controller.deleteBook(docs[index].id);
                            },

                            child: Icon(
                              Icons.person_remove_alt_1_rounded,
                              color: Colors.red,
                            ),
                          ),
                          leading: GestureDetector(
                            onTap: () {
                              controller.editBookname(docs[index].id);
                            },
                            child: Icon(
                              Icons.edit,
                              color: Colors.grey,
                            ),
                          ),
                        );
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

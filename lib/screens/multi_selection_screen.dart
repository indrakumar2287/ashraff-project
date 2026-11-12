import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:multiselect_dropdown_flutter/multiselect_dropdown_flutter.dart';
import 'package:shopping_app/utils/user_listt.dart';

class MultiSelectionScreen extends StatefulWidget {
  MultiSelectionScreen({super.key});

  @override
  State<MultiSelectionScreen> createState() => _MultiSelectionScreenState();
}

class _MultiSelectionScreenState extends State<MultiSelectionScreen> {
  List<UserModel> selectedUsers = [];
  bool showFullText = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Multi Selection")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            CustomDropdown<String>.multiSelectSearch(
              label: Text("Names"),
              maxlines: 5,
              items: userNames.map((item) => item.name ).toList(),

              onListChanged: (List<String> p1) {
                selectedUsers.clear();
                setState(() {
                  for(int i = 0 ; i < p1.length ; i++){
                    final user = userNames.firstWhere((item)=> item.name == p1[i]) ;
                    print("User Details >> ${user.name} > ${user.email}") ;
                    selectedUsers.add(user) ;

                  }

                  // selectedUsers = p1;
                });
                print("Selected users > ${p1}");
              },
            ),

            GestureDetector(
              onTap: () {
                setState(() {
                  showFullText = !showFullText;
                });
              },
              child: Text(
                "Selected names > ${selectedUsers}",
                maxLines: showFullText ? 5 : 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            ElevatedButton(onPressed: (){
              setState(() {
                selectedUsers.removeLast() ;
              });
            }, child: Text("Remove Last"))
          ],
        ),
      ),
    );
  }
}

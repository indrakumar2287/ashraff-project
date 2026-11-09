import 'package:flutter/material.dart';
import 'package:shopping_app/utils/user_listt.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  UserModel? selectedUserModel ;

  @override
  void initState() {
    // TODO: implement initState
    selectedUserModel =  userNames[1] ;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Search Screen")),
      body: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Center(
              child: DropdownButton<UserModel>(
                value: selectedUserModel,
                items: userNames.map((item) {
                  return DropdownMenuItem<UserModel>(
                    value: item,
                    child: Text("${item.name} > ${item.id ?? ''}"),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedUserModel = value ;
                  });
                },
              ),
            ),


            
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}

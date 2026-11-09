import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shopping_app/utils/user_listt.dart';

class UserListScreen extends StatelessWidget {
  const UserListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("User List")),
      body: Container(
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: userNames.length,
                itemBuilder: (context, index) {
                  final user = userNames[index];
                  return userWidget(user);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget userWidget(UserModel user) {
    return Container(
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadiusGeometry.circular(20),
        border: Border.all(color: Colors.red),
        color: Colors.red.withAlpha(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Text(user.name),
              SizedBox(height: 10),
              Text(user.id?.toString() ?? 'No Number'),
            ],
          ),
          Text(user.email),
        ],
      ),
    );
  }
}

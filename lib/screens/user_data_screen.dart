import 'package:flutter/material.dart';
import 'package:shopping_app/utils/custom_dialog.dart';
import 'package:shopping_app/utils/user_listt.dart';

class UserDataScreen extends StatelessWidget {
  const UserDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("User Data")),
      body: Padding(
        padding: EdgeInsetsGeometry.all(10),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                itemCount: userNames.length,
                // scrollDirection: Axis.horizontal,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,

                  // childAspectRatio: 0.5,
                  // mainAxisSpacing: 20,
                  // crossAxisSpacing: 5
                ),
                itemBuilder: (context, index) {
                  final user = userNames[index];
                  return userItemWidget(context, user, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget userItemWidget(BuildContext context, UserModel user, int index) {
    return GestureDetector(
      onTap: () {
        // showUserDataDialog(context, user.id ?? 0);
        showDataBottomSheet(context, user.id ?? 0);
      },
      child: Container(
        height: 200,
        width: 500,

        padding: EdgeInsetsGeometry.all(10),
        margin: EdgeInsetsGeometry.all(5),
        decoration: BoxDecoration(
          color: index % 2 == 0
              ? Colors.red.withAlpha(40)
              : Colors.blue.withAlpha(40),
          borderRadius: BorderRadiusGeometry.circular(20),
          border: Border.all(color: index % 2 == 0 ? Colors.red : Colors.blue),
        ),
        child: Center(child: Text(user.name)),
      ),
    );
  }

  Future<void> showUserDataDialog(BuildContext context, int id) async {
    final UserModel user = userNames.firstWhere((item) {
      return item.id == id;
    });
    showCustomDialog(
      context,
      Dialog(
        // constraints: BoxConstraints(
        //   maxHeight: 200,
        // ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.close, color: Colors.red, size: 30),
                ),
              ),

              Text(
                "User Data",
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
              ),
              dataRow("Name", user.name),
              dataRow("Mobile Number", user.id.toString()),
              dataRow("Email", user.email),
            ],
          ),
        ),
      ),
    );
  }

  void showDataBottomSheet(BuildContext context, int id) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final UserModel user = userNames.firstWhere((item) {
          return item.id == id;
        });
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.close, color: Colors.red, size: 30),
                ),
              ),

              Text(
                "User Data",
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
              ),
              dataRow("Name", user.name),
              dataRow("Mobile Number", user.id.toString()),
              dataRow("Email", user.email),
            ],
          ),
        );
      },
    );
  }

  Widget dataRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            key,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          Text(value, style: TextStyle(color: Colors.black, fontSize: 12)),
        ],
      ),
    );
  }
}

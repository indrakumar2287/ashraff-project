import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopping_app/route_names.dart';
import 'package:shopping_app/screens/book/view/book_list_screen.dart';

class GetXWidgets extends StatelessWidget {
  const GetXWidgets({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("GetX Widgets")),
      body: Column(
        children: [
          GestureDetector(
            onTap: () {
              // Get.dialog(
              //   Dialog(
              //     constraints: BoxConstraints(
              //       minHeight: 800,
              //
              //     ),
              //
              //     child: Container(
              //       height: 200,
              //       width: 400,
              //
              //       color: Colors.white,
              //       child: Column(
              //         children: [
              //           Text("Hello"),
              //           GestureDetector(
              //             onTap: (){
              //               Get.back() ;
              //             },
              //             child: Icon(Icons.close, color: Colors.red,),
              //           )
              //         ],
              //       ),
              //     ),
              //   ),
              //
              // );

              Get.closeAllSnackbars();
              Get.snackbar(
                "Success",
                "Data received successfully!",
                backgroundColor: Colors.green,
                snackPosition: SnackPosition.BOTTOM,
                margin: EdgeInsets.only(bottom: 20, left: 10, right: 10),
              );
              print("height >> ${Get.statusBarHeight}");

              print("height 2 >> ${MediaQuery.of(context).size.height}");
            },
            child: Container(
              height: Get.height * 0.3,
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(40),
                border: Border.all(color: Colors.red),
              ),
            ),
          ),

          ElevatedButton(
            onPressed: () {
              // Get.to(BookListScreen());
              Get.toNamed(RouteNames.booksScreen) ;
            },
            child: Text("Navigate"),
          ).paddingSymmetric(vertical: 10),
        ],
      ).paddingSymmetric(horizontal: 20).marginAll(5),
    );
  }
}

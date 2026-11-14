import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopping_app/route_names.dart';
import 'package:shopping_app/screens/book/controller/book_controller.dart';
import 'package:shopping_app/screens/student/controller/employee_controller.dart';
import 'package:shopping_app/screens/student/view/employee_list_screen.dart';

class BookListScreen extends StatelessWidget {
  const BookListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print("Build Called");
    final controller = Get.put(BookController());
    return Scaffold(
      appBar: AppBar(
        title: Text("Books"),
        actions: [
          GestureDetector(
            onTap: () {
              Get.back();
            },
            child: Icon(Icons.arrow_back_ios),
          ),

          ElevatedButton(
            onPressed: () {
              Get.offAll(() => EmployeeListScreen());
            },
            child: Icon(Icons.home),
          ).paddingSymmetric(vertical: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Form(
            key: controller.bookFormKey,
            child: Column(
              children: [
                TextFormField(
                  controller: controller.idController,

                  validator: (value) {
                    if (!(value?.isNum == true)) {
                      return "value Can't b be number";
                    }
                  },

                  decoration: InputDecoration(
                    hintText: "Book Id",

                    // errorText: "$title is required!!"
                  ),
                ),

                // customTextField("Book Id", controller.idController),
                customTextField("Book Name", controller.bookNameController),
                customTextField("Book Author", controller.authorNameController),

                // DatePicker
                Obx(() {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Published Date "),
                      GestureDetector(
                        onTap: () async {
                          DateTime? date = await showDatePicker(
                            context: context,
                            firstDate: DateTime.now().subtract(
                              Duration(days: 10000),
                            ),
                            lastDate: DateTime.now(),
                          );

                          controller.publishedDate.value =
                              date ?? DateTime.now();
                        },

                        child: Text(controller.publishedDate.value.toString()),
                      ),
                    ],
                  );
                }),
                // CalendarDatePicker(
                //   initialDate: DateTime.now().subtract(Duration(days: 10000)),
                //   firstDate: DateTime.now().subtract(Duration(days: 10000)),
                //   lastDate: DateTime.now(),
                //   onDateChanged: (DateTime value) {
                //     controller.publishedDate = value;
                //   },
                // ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        controller.addBook();
                      },
                      child: Text('Add'),
                    ),

                    TextButton(
                      onPressed: () {
                        Get.toNamed(
                          RouteNames.booksDetailsScreen,
                          parameters: {
                            'name': controller.bookNameController.text,
                            'author': controller.authorNameController.text,
                          },
                        );
                      },
                      child: Text('Details'),
                    ),
                  ],
                ),

                Obx(() {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          controller.showLoading.value =
                              !controller.showLoading.value;
                        },
                        child: Text(
                          controller.showLoading.value ? "Hide" : "Show",
                          style: TextStyle(color: Colors.blue, fontSize: 18),
                        ),
                      ),

                      SizedBox(
                        child: controller.showLoading.value
                            ? CircularProgressIndicator()
                            : SizedBox(),
                      ),
                    ],
                  );
                }).paddingSymmetric(vertical: 10),

                Obx(() {
                  print("Obx Called");
                  return SizedBox(
                    height: 400,
                    child: ListView.builder(
                      itemCount: controller.books.length,

                      itemBuilder: (context, index) {
                        final BookModel book = controller.books[index];
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,

                          children: [
                            Column(
                              children: [
                                Text(book.bookName),
                                Text(book.author),
                                Row(
                                  children: [
                                    Text(book.publishedDate.toString()),
                                  ],
                                ),
                              ],
                            ),

                            IconButton(
                              onPressed: () {
                                controller.removeBook(index);
                              },
                              icon: Icon(
                                Icons.highlight_remove_outlined,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget customTextField(String title, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "value Can't be empty";
        }
      },

      decoration: InputDecoration(
        hintText: title,

        // errorookController" onDelete() calledText: "$title is required!!"
      ),
    ).paddingOnly(bottom: 10);
  }
}

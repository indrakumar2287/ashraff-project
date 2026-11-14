import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookDetailsScreen extends StatefulWidget {
  const BookDetailsScreen({super.key});

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  @override
  void initState() {
    print("Args > ${Get.parameters}");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Book Details")),
      body: Column(
        children: [
          Text("book name > ${Get.parameters['name']}"),
          Text("book author > ${Get.parameters['author']}"),
        ],
      ),
    );
  }
}

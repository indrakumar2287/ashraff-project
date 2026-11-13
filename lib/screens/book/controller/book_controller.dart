import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookController extends GetxController {
  RxList<BookModel> books = <BookModel>[].obs;


   GlobalKey<FormState> bookFormKey = GlobalKey<FormState>() ;

  RxBool showLoading = false.obs;

  TextEditingController bookNameController = TextEditingController();
  TextEditingController authorNameController = TextEditingController();
  TextEditingController idController = TextEditingController();
  Rx<DateTime> publishedDate = DateTime.now().obs;

  void addBook() {

    if(!bookFormKey.currentState!.validate() ){
      Get.snackbar(
          "Error",
          "Please add required fields",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red
      );

    }

    if (bookNameController.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Please add the book name",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red
      );
      return;
    }
    BookModel book = BookModel(
      id: idController.text,
      author: authorNameController.text,
      bookName: bookNameController.text,
      publishedDate: publishedDate.value,
    );
    books.add(book);
    clearControllers();
  }

  void removeBook(int index) {
    books.removeAt(index);
  }
  
  void clearControllers(){
    bookNameController.clear();
    idController.clear();
    authorNameController.clear();
  }
}

class BookModel {
  BookModel({
    required this.id,
    required this.author,
    required this.bookName,
    required this.publishedDate,
  });

  String bookName;

  dynamic id;

  String author;
  DateTime publishedDate;
}

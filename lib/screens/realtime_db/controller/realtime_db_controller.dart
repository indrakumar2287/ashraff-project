import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopping_app/utils/custom_toast.dart';

class RealtimeDbController extends GetxController {
  TextEditingController bookNameController = TextEditingController();

  RxBool isLoading = false.obs;

  Future<void> addBookname() async {
    isLoading.value = true;
    try {
      await FirebaseFirestore.instance.collection("Books").add({
        "name": bookNameController.text.toString(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      bookNameController.clear();

      showSnackBar(text: "Book added successfully", isSuccess: true);
    } on Exception catch (e) {
      print("Error >> $e");
    } finally {
      isLoading.value = false;
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getBookNames() {
    return FirebaseFirestore.instance.collection("Books").snapshots();

    // print("Data>> ${data.docs?.firstOrNull?.metadata}") ;
  }

  Future<void> deleteBook(String docId) async {
    await FirebaseFirestore.instance.collection("Books").doc(docId).delete();
  }

  Future<void> editBookname(String docId) async {
    await FirebaseFirestore.instance.collection("Books").doc(docId).update({
      "name": bookNameController.text.toString(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    bookNameController.clear();

    showSnackBar(text: "Book Edited successfully", isSuccess: true);
  }

  final bookDetailsController = TextEditingController();

  void showBookDetails(String docId) async {
    Get.dialog(
      Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: bookDetailsController),

            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection("Books")
                    .doc(docId)
                    .collection("Book Details")
                    .add({"detail": bookDetailsController.text.toString()});
                Get.back();
              },
              child: Text("Update Details"),
            ),
          ],
        ).paddingSymmetric(horizontal: 10, vertical: 60),
      ),
    );
  }
}

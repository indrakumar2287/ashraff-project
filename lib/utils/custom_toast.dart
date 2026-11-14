import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

void showToast(String str) {
  Fluttertoast.showToast(msg: str);
}

void showSnackBar({required String text, required bool isSuccess}) {
  Get.closeAllSnackbars();
  Get.snackbar(
    isSuccess ? 'Success' : "Error",
    text,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: isSuccess ? Colors.green : Colors.red,
  );
}

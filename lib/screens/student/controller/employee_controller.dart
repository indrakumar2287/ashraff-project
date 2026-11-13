import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class EmployeeController extends GetxController {
  List<String> employee = [];

  TextEditingController nameController = TextEditingController();

  void addEmployee() {
    if (nameController.text.isEmpty) {
      Get.snackbar("Error", "please write in textbox", snackPosition: SnackPosition.BOTTOM);
      return ;
    }
    employee.add(nameController.text);
    update() ;
  }

  void removeEmployee(int index) {
    employee.removeAt(index);
    update();
  }
}

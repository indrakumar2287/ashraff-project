import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopping_app/screens/student/controller/employee_controller.dart';

class EmployeeListScreen extends StatelessWidget {
  const EmployeeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(EmployeeController());
    return GetBuilder<EmployeeController>(
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(title: Text("Employee")),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: controller.nameController,
                  decoration: InputDecoration(hintText: "Name"),
                ).paddingOnly(bottom: 10),

                TextButton(
                  onPressed: () {
                    controller.addEmployee();
                  },
                  child: Text('Add'),
                ),

                Expanded(
                  child: ListView.builder(
                    itemCount: controller.employee.length,

                    itemBuilder: (context, index) {
                      final name = controller.employee[index];
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [
                          Text(name),

                          IconButton(
                            onPressed: () {
                              controller.removeEmployee(index);
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
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

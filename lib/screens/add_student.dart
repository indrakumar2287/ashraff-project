import 'package:flutter/material.dart';
import 'package:shopping_app/utils/local_db.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  List<Map<String, dynamic>> addedStudents = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Student")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(addedStudents?.lastOrNull?['name'] ?? 'No Name'),
            SizedBox(height: 100),

            Center(
              child: ElevatedButton(
                onPressed: () async {
                  var result = await DatabaseHelper().getStudents();

                  print("Result >>> ${result.lastOrNull}");

                  setState(() {
                    addedStudents.addAll(result);
                  });
                },
                child: Text("Show Data"),
              ),
            ),

            SizedBox(height: 100),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  int result = await DatabaseHelper().insertStudent(
                    name: "Indra2",
                    age: 17,
                    course: "Computer",
                  );

                  print("Result >>> $result");
                },
                child: Text("Add"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

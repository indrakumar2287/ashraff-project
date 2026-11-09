import 'package:flutter/material.dart';
import 'package:multiselect_dropdown_flutter/multiselect_dropdown_flutter.dart';

class MultiSelectionScreen extends StatelessWidget {
   MultiSelectionScreen({super.key});

   final List myList = const [
     {'id': 'dog', 'label': 0},
     {'id': 'cat', 'label': 1},
     {'id': 'mouse', 'label': 2},
     {'id': 'rabbit', 'label': 3},
   ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Multi Selection"),),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            MultiSelectDropdown(
              list: myList,
              initiallySelected: const [],
              onChange: (newList) {
                print(newList) ;
                // your logic
              },
            ),
          ],
        ),
      ),
    );
  }
}

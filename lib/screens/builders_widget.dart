import 'package:flutter/material.dart';

class BuildersWidget extends StatefulWidget {
  const BuildersWidget({super.key});

  @override
  State<BuildersWidget> createState() => _BuildersWidgetState();
}

class _BuildersWidgetState extends State<BuildersWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Builders"),
      ),
      body: Center(
        child: FutureBuilder(
          future: returnNums(),
          builder: (context, snapshot) {
            print("Snapshot >> $snapshot");

            return Container();
          },
        ),
      ),
    );
  }
}

// Function
Future<int> returnNums() async {
  await Future.delayed(Duration(seconds: 2));
  return 1;
}

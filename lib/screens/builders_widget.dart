import 'package:flutter/material.dart';

class BuildersWidget extends StatefulWidget {
  const BuildersWidget({super.key});

  @override
  State<BuildersWidget> createState() => _BuildersWidgetState();
}

class _BuildersWidgetState extends State<BuildersWidget> {
  List<int> nums = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Builders")),
      body: Center(
        child: Column(
          children: [
            // SizedBox(
            //   height: 200,
            //   width: 200,
            //   child: FutureBuilder(
            //     future: returnNums(),
            //     builder: (context, snapshot) {
            //       print("Snapshot >> $snapshot");
            //
            //       switch(snapshot.connectionState) {
            //         case ConnectionState.waiting:
            //           return CircularProgressIndicator() ;
            //         case ConnectionState.done :
            //           if(snapshot.hasData){
            //             return  Text(snapshot.data?.toString() ?? "") ;
            //           } else {
            //            return Text("No Data") ;
            //           }
            //         case ConnectionState.none:
            //         case ConnectionState.active:
            //           throw UnimplementedError();
            //
            //       }
            //
            //
            //     },
            //   ),
            // ),
            StreamBuilder(
              stream: getNumbersInStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  print("Snapshot >> ${snapshot.connectionState}");
                  print("Snapshot  222 >> ${snapshot.data}");
                  nums.add(int.parse(snapshot.data?.toString() ?? "0"));
                  return Text("${nums}");
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return SizedBox(child: CircularProgressIndicator());
                }

                return Text("Stream");
              },
            ),
          ],
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

Stream<int> getNumbersInStream() async* {
  for (var i = 0; i < 5; i++) {
    await Future.delayed(Duration(seconds: 2));
    yield i;
  }
}

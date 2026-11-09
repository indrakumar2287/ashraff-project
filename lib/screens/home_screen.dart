import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key, required this.email, this.password = "Test"});

  String email;
  String password;

  @override
  Widget build(BuildContext context) {
    print("Email >> ${email}");
    print("Password >> ${password}");
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Screen"),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 100,
                child: Row(
                  children: [
                    Container(
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadiusGeometry.circular(20),
                      ),
                    ),
                    SizedBox(width: 10,),
                    Expanded(
                      child: Container(
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadiusGeometry.circular(20),
                        ),
                        child: Center(
                          child: Icon(Icons.eighteen_up_rating),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10,),
              sectionWidget("Section 1"),
              sectionWidget("Section 2"),
              sectionWidget("Section 3"),
              sectionWidget("Section 4"),
              sectionWidget("Section 5"),
              sectionWidget("Section 6"),
            ],
          ),
        ),
      ),
    );
  }

  Widget sectionWidget(String str) {
    return Column(
      children: [
        SizedBox(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,

            children: [Text(str)],
          ),
        ),
        SizedBox(height: 20),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: BouncingScrollPhysics(),

          child: Row(
            children: [
              itemWidget(),
              itemWidget(),
              itemWidget(),
              itemWidget(),
              itemWidget(),
            ],
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget itemWidget() {
    return Stack(
      children: [
        Container(
          height: 100,
          width: 100,
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadiusGeometry.circular(20),
            border: Border.all(color: Colors.green),
            color: Colors.green.withAlpha(20),
          ),
        ),

        Positioned(
          right: 15,
          top: 15,
          child: Icon(Icons.close, color: Colors.red),
        ),
        //
        Positioned(top: 50, right: 50, child: Icon(Icons.home)),
      ],
    );
  }
}

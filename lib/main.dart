import 'package:flutter/material.dart';
import 'package:shopping_app/screens/add_student.dart';
import 'package:shopping_app/screens/home_screen.dart';
import 'package:shopping_app/screens/login_screen.dart';
import 'package:shopping_app/screens/user_data_screen.dart';
import 'package:shopping_app/screens/user_list_screen.dart';
import 'package:shopping_app/utils/local_db.dart';
import 'package:sqflite/sqflite.dart';

import 'screens/multi_selection_screen.dart';
import 'screens/search_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Get a location using getDatabasesPath
  await DatabaseHelper().getDataBase() ;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
        cardColor: Colors.blue,

      ),
      // darkTheme: ,
      debugShowCheckedModeBanner: false,
      home: AddStudentScreen() ,
      // home: HomeScreen(email: "") ,
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
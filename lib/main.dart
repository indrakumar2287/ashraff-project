import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopping_app/firebase_options.dart';
import 'package:shopping_app/route_names.dart';
import 'package:shopping_app/screens/add_student.dart';
import 'package:shopping_app/screens/auth/view/signup_screen.dart';
import 'package:shopping_app/screens/book/view/book_details.dart';
import 'package:shopping_app/screens/book/view/book_list_screen.dart';
import 'package:shopping_app/screens/builders_widget.dart';
import 'package:shopping_app/screens/getx_widgets.dart';
import 'package:shopping_app/screens/home_screen.dart';
import 'package:shopping_app/screens/auth/view/login_screen.dart';
import 'package:shopping_app/screens/student/view/employee_list_screen.dart';
import 'package:shopping_app/screens/user_data_screen.dart';
import 'package:shopping_app/screens/user_list_screen.dart';
import 'package:shopping_app/utils/local_db.dart';
import 'package:sqflite/sqflite.dart';

import 'screens/multi_selection_screen.dart';
import 'screens/search_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Get a location using getDatabasesPath
  // await DatabaseHelper().getDataBase() ;


  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      initialRoute: RouteNames.builders,
      getPages: [
        GetPage(
          name: RouteNames.employeeScreen,
          page: () => EmployeeListScreen(),

        ),
        GetPage(name: RouteNames.getxWidgets, page: () => GetXWidgets()),
        GetPage(name: RouteNames.booksScreen, page: () => BookListScreen()),
        GetPage(name: RouteNames.booksDetailsScreen, page: () => BookDetailsScreen()),
        GetPage(name: RouteNames.loginScreen, page: () => LoginScreen()),
        GetPage(name: RouteNames.signup, page: () => SignupScreen()),
        GetPage(name: RouteNames.builders, page: () => BuildersWidget()),
      ],
      theme: ThemeData(
        // colorScheme: .fromSeed(seedColor: Colors.deepPurple),
        cardColor: Colors.blue,

      ),
      // darkTheme: ,
      debugShowCheckedModeBanner: false,
      // home: GetXWidgets() ,
      // home: HomeScreen(email: "") ,
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

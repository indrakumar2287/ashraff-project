import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shopping_app/route_names.dart';
import 'package:shopping_app/services/local_db_sf.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Future.delayed(Duration(seconds: 3), () async {
      final bool status =
          await LocalDb.getBool(LocalDbStrings.ISLOGIN) ?? false;

      if (status) {
        Get.offAllNamed(RouteNames.home);
      } else {
        Get.offAllNamed(RouteNames.loginScreen);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Icon(Icons.chat)));
  }
}

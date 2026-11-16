import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/get_utils/src/extensions/export.dart';
import 'package:shopping_app/route_names.dart';
import 'package:shopping_app/screens/auth/controller/auth_controller.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: GetBuilder<AuthController>(
        builder: (controller) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  'Sign up',
                  style: TextStyle(
                    color: Colors.purple,
                    fontWeight: FontWeight.w700,
                    fontSize: 30,
                  ),
                ),
              ).paddingOnly(bottom: 20),
              TextField(
                controller: controller.emailController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),

                  hintText: "Enter Email ",
                ),
              ).paddingOnly(bottom: 10),
              TextField(
                controller: controller.nameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),

                  hintText: "Enter Name ",
                ),
              ).paddingOnly(bottom: 10),
              TextField(
                controller: controller.passowrdController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.password),

                  hintText: "Enter Password ",
                ),
              ).paddingOnly(bottom: 10),

              Obx(() {
                return Center(
                  child: ElevatedButton(
                    onPressed: () {
                      controller.signUpUser();
                    },
                    onLongPress: () {
                      print("Long Press");
                    },

                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.purple),
                      foregroundColor: WidgetStatePropertyAll(Colors.white),
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(10),
                        ),
                      ),
                    ),
                    child: controller.isLoadingSignUp.value
                        ? CircularProgressIndicator(color: Colors.white,).paddingAll(4)
                        : Text('Sign Up'),
                  ),
                );
              }),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account? "),
                    GestureDetector(
                      onTap: () {
                        Get.toNamed(RouteNames.loginScreen);
                      },
                      child: Text(
                        "Login ",
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                ).paddingOnly(top: 10),
              ),
            ],
          ).paddingSymmetric(horizontal: 10, vertical: 10);
        },
      ),
    );
  }
}


// Widget customTextField(){
//           return TextField(
//                 obscureText: isPasswordVisible ? false : true,
//                 controller: passwordController,
//                 decoration: InputDecoration(
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.password),

//                   suffixIcon: GestureDetector(
//                     onTap: updatePasswordVisibility,
//                     child: isPasswordVisible
//                         ? Icon(Icons.hide_image)
//                         : Icon(Icons.image),
//                   ),
//                   hintText: "Enter password ",
//                 ),
//               ) ;
// }

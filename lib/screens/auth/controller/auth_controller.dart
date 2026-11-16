import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/state_manager.dart';
import 'package:shopping_app/route_names.dart';
import 'package:shopping_app/services/firebase_service.dart';
import 'package:shopping_app/utils/custom_toast.dart';

class AuthController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passowrdController = TextEditingController();

  RxBool isLoadingLogin = false.obs ;
  RxBool isLoadingSignUp = false.obs ;

  void signUpUser() async {
    try {
      isLoadingSignUp.value = true ;
      bool isSuccess = await FirebaseService().signUpUser(
        email: emailController.text,
        password: passowrdController.text,
        name: nameController.text,
      );

      if (isSuccess) {
        Get.toNamed(RouteNames.booksScreen);

        showSnackBar(text: "Sign up successfully", isSuccess: true);
      } else {
        // showSnackBar(text: "Firebase Error", isSuccess: false);
      }
    } on Exception catch (e) {
      // TODO
    } finally {
      isLoadingSignUp.value = false ;

    }
  }





  Future<void> login() async {
    try {
      isLoadingLogin.value = true ;
      if (emailController.text.isEmpty || passowrdController.text.isEmpty) {
        print("Please enter details");
        showToast("Please enter details");
        return;
      }
      bool isSuccess = await FirebaseService().loginUser(
        email: emailController.text,
        password: passowrdController.text,
      );
      if(isSuccess){
        Get.toNamed(RouteNames.booksScreen);
        showSnackBar(text: "Logged in successfully", isSuccess: true);
      }
    } on Exception catch (e) {
      // TODO
    }finally{
      isLoadingLogin.value = false ;
    }

  }
}

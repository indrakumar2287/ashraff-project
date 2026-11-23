
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/state_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopping_app/route_names.dart';
import 'package:shopping_app/services/firebase_service.dart';
import 'package:shopping_app/services/local_db_sf.dart';
    
import 'package:shopping_app/utils/custom_toast.dart';
import 'package:shopping_app/services/local_db_strings.dart';

class AuthController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passowrdController = TextEditingController();

  RxBool isLoadingLogin = false.obs;
  RxBool isLoadingSignUp = false.obs;

  void signUpUser() async {
    try {
      isLoadingSignUp.value = true;
      final token = await LocalDb.getValue(LocalDbStrings.FCMTOKEN); 
      bool isSuccess = await FirebaseService().signUpUser(
        email: emailController.text,
        password: passowrdController.text,
        name: nameController.text,
        token: token ?? ''
      );

      if (isSuccess) {

        Get.offAllNamed(RouteNames.home);

        showSnackBar(text: "Sign up successfully", isSuccess: true);
        LocalDb.setBool(LocalDbStrings.ISLOGIN, true);

        userId = FirebaseAuth.instance.currentUser?.uid ?? ''; 
        await setUserNameInLocalDB(nameController.text); 
      
      } else {
        // showSnackBar(text: "Firebase Error", isSuccess: false);
      }
    } on Exception catch (e) {
      // TODO
    } finally {
      isLoadingSignUp.value = false;
    }
  }

  Future<void> login() async {
    try {
      isLoadingLogin.value = true;
      if (emailController.text.isEmpty || passowrdController.text.isEmpty) {
        print("Please enter details");
        showToast("Please enter details");
        return;
      }
      bool isSuccess = await FirebaseService().loginUser(
        email: emailController.text,
        password: passowrdController.text,
      );
      if (isSuccess) {
        Get.offAllNamed(RouteNames.home);
        showSnackBar(text: "Logged in successfully", isSuccess: true);


        LocalDb.setBool(LocalDbStrings.ISLOGIN, true);
        userId = FirebaseAuth.instance.currentUser?.uid ?? ''; 

        final userData = await FirebaseService().getCurrentUserDetails();
        print("userData >> ${userData}");
        await setUserNameInLocalDB(userData?['name'].toString() ?? '');  

       
      }
    } on Exception catch (e) {
      // TODO
    } finally {
      isLoadingLogin.value = false;
    }
  }
}


Future<void> setUserNameInLocalDB(String userName) async {
  LocalDb.setValue(LocalDbStrings.USERNAME, userName);
}

Future<String> getUserName() async {
  return await LocalDb.getValue(LocalDbStrings.USERNAME) ?? '';
}



String userName = '';
String userId = '';

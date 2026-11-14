import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shopping_app/screens/home_screen.dart';
import 'package:shopping_app/services/firebase_service.dart';
import 'package:shopping_app/utils/custom_toast.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  bool isPasswordVisible = false;

  void updatePasswordVisibility() {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white.withAlpha(50),
      appBar: AppBar(
        title: Text("Login Screen"),
        elevation: 10,
        leading: Icon(Icons.home),
        actions: [
          GestureDetector(
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Icon(Icons.calendar_month),
            ),
          ),
          Icon(Icons.back_hand_sharp),
          SizedBox(width: 20),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Center(
              child: Text(
                'Login',
                style: TextStyle(
                  color: Colors.purple,
                  fontWeight: FontWeight.w700,
                  fontSize: 30,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text("Email Address"),
                ),
                TextField(
                  controller: emailController,
                  // Keyboard
                  keyboardType: TextInputType.emailAddress,

                  // Full Filter - Restriction
                  // inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    // label: Text("Email"),
                    hintText: "Enter email address",
                    // hint: Text("Enter email", style: TextStyle(color: Colors.red),),
                    // prefix: Icon(Icons.email, color: Colors.black,),
                    prefixIcon: Icon(Icons.email),
                    // suffix: Icon(Icons.ads_click),
                    // suffixIcon: Icon(Icons.ads_click),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    // enabled: false,
                    // fillColor: Colors.yellowAccent,
                    // filled: true,
                  ),
                ),
                SizedBox(height: 30),

                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text("Password"),
                ),
                TextField(
                  obscureText: isPasswordVisible ? false : true,
                  controller: passwordController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.password),

                    suffixIcon: GestureDetector(
                      onTap: updatePasswordVisibility,
                      child: isPasswordVisible
                          ? Icon(Icons.hide_image)
                          : Icon(Icons.image),
                    ),
                    hintText: "Enter password ",
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),

            // Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  login();
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
                child: Text('Sign In'),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.refresh),
      ),
    );
  }

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      print("Please enter details");
      showToast("Please enter details");
      return;
    }
    bool isSuccess = await FirebaseService().loginUser(
      email: emailController.text,
      password: passwordController.text,
    );
    if(isSuccess){
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            email: emailController.text,
            password: passwordController.text,
          ),
        ),
      );

      showSnackBar(text: "Logged in successfully", isSuccess: true);
    }

  }
}

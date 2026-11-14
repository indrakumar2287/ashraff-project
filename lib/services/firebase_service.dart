import 'package:firebase_auth/firebase_auth.dart';
import 'package:shopping_app/utils/custom_toast.dart';

class FirebaseService {
  Future<bool> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential user = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      print("User >> ${user.user?.displayName}");

      return true;
    } catch (e) {
      print("Firebase Error >> $e");
      showSnackBar(text: e.toString(), isSuccess: false);

      return false;
    }
  }
}

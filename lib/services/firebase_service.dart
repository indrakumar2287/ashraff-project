import 'package:cloud_firestore/cloud_firestore.dart';
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

      // print("User >> ${user.user}");
      // UserMetadata? metaData = user.user?.metadata ;
      // print("Name >> ${metaData}") ;

      final user2 = FirebaseAuth.instance.currentUser ;


      final data  = await FirebaseFirestore.instance.collection("Users").doc(user2?.uid).get() ;

      print("UserData >> ${data.data()}");

      return true;
    } catch (e) {
      print("Firebase Error >> $e");
      showSnackBar(text: e.toString(), isSuccess: false);

      return false;
    }
  }

  Future<bool> signUpUser({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      UserCredential user = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      FirebaseFirestore.instance.collection("Users").doc(user.user?.uid).set({
        "name": name,
        "email": email,
        "uid": user?.user?.uid,
        "createdAt": FieldValue.serverTimestamp(),
      });

      print(" Name >> ${user.user?.displayName}") ;

      return true;
    } on FirebaseException catch (e) {
      print("Firebase error >> $e");

      showSnackBar(text:e.toString(), isSuccess: false) ;

      return false;
    }
  }
}

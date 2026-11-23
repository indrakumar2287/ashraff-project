import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopping_app/main.dart';

SharedPreferences? prefs;

class LocalDb {
  static Future<void> setValue(String key, String value) async {
    try {
      await prefs?.setString(key, value);
    } on Exception catch (e) {
      print("Error > $e");
    }
  }

  static Future<String?> getValue(String key) async {
    try {
      final value = prefs?.getString(key) ?? '';
      return value;
    } on Exception catch (e) {
      print("Error > $e");
      return null;
    }
  }

  static Future<void> setBool(String key, bool value) async {
    try {
      await prefs?.setBool(key, value);
    } on Exception catch (e) {
      print("Error > $e");
    }
  }

  static Future<bool?> getBool(String key) async {
    try {
      final value = prefs?.getBool(key) ?? false;
      return value;
    } on Exception catch (e) {
      print("Error > $e");
      return null;
    }
  }
}

class LocalDbStrings {
  static String USERNAME = "USERNAME";
  static String ISLOGIN = "ISLOGIN";
  static String FCMTOKEN = "FCMTOKEN";
}

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FirebaseMessaging messaging = FirebaseMessaging.instance;

  static final FlutterLocalNotificationsPlugin localNotifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    try {
      await messaging.requestPermission();
      
      const androidSettings = AndroidInitializationSettings("@mipmap/ic_launcher") ;
      const settings = InitializationSettings(
        android: androidSettings
      );
      
      await localNotifications.initialize(settings: settings);
      
      const channel = AndroidNotificationChannel(
        'chat_channel',
        "Chat Notification",
        importance: Importance.high,
      );
      
      await localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);
      
      final token = await messaging.getToken();
      print("FCM TOKEN >> $token");
      
      FirebaseMessaging.onMessage.listen((message) async {
        await showNotification(message);
      });
      
      FirebaseMessaging.onMessageOpenedApp.listen((message) async {
        print("Notification Clicked > ${message.data}");
      });
    } on Exception catch (e) {
      print("Error Firebase messanging >>> $e"   ) ; 
    }
  }

  static Future<void> showNotification(RemoteMessage message) async {

    print("New Notification Received >> ${message.notification?.body}") ; 
    await localNotifications.show(
      id: DateTime.now().second,
      title: message?.notification?.title ?? "New Message",
      body: message?.notification?.body ?? "",
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'chat_channel',
          "Chat Notification",
        ),
      ),
    );
  }
}

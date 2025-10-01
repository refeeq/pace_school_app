// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:school_app/core/utils/utils.dart';

// class LocalNotifications {
//   static final FlutterLocalNotificationsPlugin _notificationPlugin =
//       FlutterLocalNotificationsPlugin();
//   static void display(RemoteMessage message) async {
//     final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

//     try {
//       final NotificationDetails notificationDetails = NotificationDetails(
//         android: AndroidNotificationDetails(
//           'high_importance_channe',
//           'High Importance Notifications',
//           importance: Importance.max,
//           priority: Priority.high,
//           playSound: true,
//           styleInformation: BigTextStyleInformation(''),
//         ),
//         iOS: IOSNotificationDetails(),
//       );
//       await _notificationPlugin.show(
//         id,
//         message.notification!.title,
//         message.notification!.body,
//         notificationDetails,
//         payload: message.data['route'],
//       );
//     } on Exception catch (e) {
//       print(e.toString());
//     }
//   }

//   static void initialize(BuildContext context) {
//     final InitializationSettings initializationSettings =
//         InitializationSettings(
//       android: AndroidInitializationSettings('@mipmap/ic_launcher'),
//       iOS: IOSInitializationSettings(),
//     );
//     _notificationPlugin.initialize(
//       initializationSettings,
//       onSelectNotification: (payload) async {
//         if (payload != null) {
//           if (payload.startsWith("/data")) {
//             if (await Permission.manageExternalStorage.request().isGranted) {
//               await openFile(payload);
//             }
//           } else {
//             Navigator.pushNamed(context, payload);
//           }
//         }
//       },
//     );
//   }
// }

// import 'dart:io';

// import 'package:app_settings/app_settings.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// class NotificationServices {
//   static FirebaseMessaging messaging = FirebaseMessaging.instance;

//   final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();
// //for to get notification permission from users but on below android 13 system do not show dialog box

//   void initLocalNotifications(
//       BuildContext context, RemoteMessage message) async {
//     var androidInitializationSettings =
//         const AndroidInitializationSettings('@mipmap/ic_launcher');
//     var iosInitializationSettings = const DarwinInitializationSettings();

//     var initializationSetting = InitializationSettings(
//         android: androidInitializationSettings, iOS: iosInitializationSettings);

//     await _flutterLocalNotificationsPlugin.initialize(initializationSetting,
//         onDidReceiveNotificationResponse: (payload) {
//       // handle interaction when app is active for android
//       // handleMessage(context, message);
//     });
//   }

//   void firebaseInit(BuildContext context) {
//     FirebaseMessaging.onMessage.listen((message) {
//       print('dddfff : ${message.notification?.body}');
//       if (Platform.isAndroid) {
//         initLocalNotifications(context, message);
//         showNotification(message);
//       }
//     });
//   }

//   Future<void> showNotification(RemoteMessage message) async {
//     AndroidNotificationChannel channel = AndroidNotificationChannel(
//       message.notification!.android!.channelId.toString(),
//       message.notification!.android!.channelId.toString(),
//       importance: Importance.max,
//       showBadge: true,
//       // playSound: true,
//       // sound: const RawResourceAndroidNotificationSound('jetsons_doorbell')
//     );

//     AndroidNotificationDetails androidNotificationDetails =
//         const AndroidNotificationDetails(
//       'high_importance_channe',
//       'High Importance Notifications',
//       importance: Importance.high,
//       priority: Priority.high,
//       playSound: true,
//       // ticker: 'ticker',
//       // sound: RawResourceAndroidNotificationSound('jetsons_doorbell')
//       //  icon: largeIconPath
//     );

//     const DarwinNotificationDetails darwinNotificationDetails =
//         DarwinNotificationDetails(
//             presentAlert: true, presentBadge: true, presentSound: true);

//     NotificationDetails notificationDetails = NotificationDetails(
//         android: androidNotificationDetails, iOS: darwinNotificationDetails);

//     Future.delayed(Duration.zero, () {
//       final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
//       _flutterLocalNotificationsPlugin.show(
//         id,
//         message.notification!.title.toString(),
//         message.notification!.body.toString(),
//         notificationDetails,
//       );
//     });
//   }

//   void getNotificationPermision() async {
//     NotificationSettings settings = await messaging.requestPermission(
//         alert: true,
//         announcement: true,
//         badge: true,
//         carPlay: true,
//         criticalAlert: true,
//         provisional: true,
//         sound: true);
//     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//     } else if (settings.authorizationStatus ==
//         AuthorizationStatus.provisional) {
//     } else {
//       AppSettings.openAppSettings();
//     }
//   }

// // to get fcm token of users device
//   Future<void> getToken(String id) async {
//     await messaging.getToken().then((token) {
//       if (token != null) {
//         print(token);
//         // FirebaseFirestore.instance
//         //     .collection('user')
//         //     .doc(id)
//         //     .update({'push_token': token});
//       } else {
//         print('no token found');
//       }
//     });
//   }

//   // void isTokenRefresh() {
//   //   messaging.onTokenRefresh.listen((event) {
//   //     event.toString();
//   //   });
//   // }
// }
// //  Padding(
// //                   padding: const EdgeInsets.all(22.0),
// //                   child: Column(
// //                     mainAxisAlignment: MainAxisAlignment.start,
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Column(
// //                         mainAxisAlignment: MainAxisAlignment.start,
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           Text(
// //                             'AIRBNB',
// //                             textAlign: TextAlign.center,
// //                             style: Theme.of(context)
// //                                 .textTheme
// //                                 .bodyLarge!
// //                                 .merge(TextStyle(
// //                                   color: Color(0xFFC6FCA6),
// //                                   fontFamily: 'Manrope',
// //                                   fontWeight: FontWeight.w800,
// //                                   letterSpacing: 0.84,
// //                                 )),
// //                           ),
// //                           SizedBox(
// //                             height: 26,
// //                           ),
// //                           Text(
// //                             'Curating AR experiences while travelling',
// //                             style: Theme.of(context)
// //                                 .textTheme
// //                                 .headlineMedium!
// //                                 .merge(TextStyle(
// //                                   color: Colors.white,
// //                                   fontFamily: 'Inter',
// //                                   fontWeight: FontWeight.w400,
// //                                 )),
// //                           ),
// //                           Container(
// //                             width: 447,
// //                             height: 3,
// //                             color:
// //                                 Colors.white.withOpacity(0.14000000059604645),
// //                           ),
// //                           Text(
// //                             'Onboarding increased to 12%.',
// //                             style: Theme.of(context)
// //                                 .textTheme
// //                                 .titleMedium!
// //                                 .merge(TextStyle(
// //                                   color: Colors.white
// //                                       .withOpacity(0.800000011920929),
// //                                   fontFamily: 'Manrope',
// //                                   fontWeight: FontWeight.w400,
// //                                 )),
// //                           ),
// //                         ],
// //                       ),
// //                       SizedBox(
// //                         height: MediaQuery.sizeOf(context).height * 0.06,
// //                       ),
// //                       Align(
// //                         alignment: Alignment.bottomRight,
// //                         child: ClipRect(
// //                           child: Align(
// //                             alignment:
// //                                 Alignment.topLeft, // Align image to the right

// //                             heightFactor: 0.4,
// //                             child: Image.asset(
// //                               "img1.png",
// //                               fit: BoxFit.cover,
// //                               height: MediaQuery.sizeOf(context).height * 0.234,
// //                             ),
// //                           ),
// //                         ),
// //                       )
// //                     ],
// //                   ),
// //                 ),
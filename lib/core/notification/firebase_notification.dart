import 'dart:developer';

import 'package:app_settings/app_settings.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:school_app/app.dart';
import 'package:school_app/core/provider/nav_provider.dart';
import 'package:school_app/core/provider/student_provider.dart';
import 'package:school_app/main.dart';
import 'package:school_app/views/screens/home_screen/bottom_nav.dart';

/// To verify that your messages are being received, you ought to see a notification appearon your device/emulator via the flutter_local_notifications plugin.
/// Define a top-level named handler which background/terminated messages will
/// call. Be sure to annotate the handler with `@pragma('vm:entry-point')` above the function declaration.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase with default name for background messages
  await Firebase.initializeApp(options: AppEnivrornment.firebaseOptions);
  await setupFlutterNotifications();
  showFlutterNotification(message);
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  print('Handling a background message ${message.messageId}');
}

/// Create a [AndroidNotificationChannel] for heads up notifications
late AndroidNotificationChannel channel;

bool isFlutterLocalNotificationsInitialized = false;

Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }

  try {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
    } else {
      AppSettings.openAppSettings();
    }

    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description:
          'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin!
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
    isFlutterLocalNotificationsInitialized = true;
  } catch (e) {
    print("Error initializing local notifications: $e");
  }
}

void showFlutterNotification(RemoteMessage message) {
  try {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null &&
        android != null &&
        !kIsWeb &&
        flutterLocalNotificationsPlugin != null) {
      flutterLocalNotificationsPlugin!.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: 'ic_notification',
            largeIcon: const DrawableResourceAndroidBitmap('ic_launcher'),
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    }
  } catch (e) {
    print("Error showing notification: $e");
  }
}

/// Initialize the [FlutterLocalNotificationsPlugin] package.
FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;

void goToNextScreen(Map<String, dynamic> data, context) {
  debugPrint(data.toString());
  log("$data");

  if (data['click_action'] != null) {
    if (data['click_action'] == 'NOTIFICATION') {
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) {
            Future(() {
              Provider.of<NavProvider>(
                context,
                listen: false,
              ).changeIndex(2, context);
            });
            return const HomeScreenView();
          },
        ),
        (route) => false,
      );
    } else if (data['click_action'] == 'COMMUNICATION') {
      if (data['studcode'] != null) {
        Future(() {
          Provider.of<StudentProvider>(
            context,
            listen: false,
          ).selectStudentWithStudId(data['studcode']);
        });
      }
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) {
            Future(() {
              Provider.of<NavProvider>(
                context,
                listen: false,
              ).changeIndex(3, context);
            });
            return const HomeScreenView();
          },
        ),
        (route) => false,
      );
    } else {
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) {
            Future(() {
              Provider.of<NavProvider>(
                context,
                listen: false,
              ).changeIndex(0, context);
            });
            return const HomeScreenView();
          },
        ),
        (route) => false,
      );
    }
  }
}

class FirebaseNotificationService {
  static void start(BuildContext context) {
    // Initialize local notifications
    setupFlutterNotifications();

    // FirebaseMessaging.instance.getInitialMessage().then(
    //           (value) => setState(
    //             () {
    //               _resolved = true;
    //               initialMessage = value?.data.toString();
    //             },
    //           ),
    //         );
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (message.notification != null) {
        if (message.data['click_action'] == "COMMUNICATION") {
          int? count = await Hive.box('communication').get('count');
          if (count == null) {
            count = 1;
          } else {
            count++;
          }
          await Hive.box("communication").put("count", count);
          await Hive.box("communication").put("new", "+");
        } else if (message.data['click_action'] == "NOTIFICATION") {
          await Hive.box("notificationCount").put("new", "+");
          int? count = await Hive.box('notificationCount').get('count');
          if (count == null) {
            count = 1;
          } else {
            count++;
          }
        }

        log('onMessage: ${message.notification!.title}');
        showFlutterNotification(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('A new onMessageOpenedApp event was published!');
      goToNextScreen(message.data, context);
    });
  }
}

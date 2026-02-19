import 'dart:convert';
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
import 'package:school_app/core/notification/fcm_topic_service.dart';
import 'package:school_app/core/notification/menu_deeplink_helper.dart';
import 'package:school_app/core/provider/communication_provider.dart';
import 'package:school_app/views/screens/parent/parent_communication/communication_detail/communication_detail.dart';
import 'dart:io' show Platform;

/// Resolves student code for COMMUNICATION deep link:
/// 1. From data['studcode'] if present
/// 2. From data['topic'] e.g. "stud_3333" -> "3333"
/// 3. From app's stored topics: first topic starting with "stud_" (suffix = studcode)
Future<String?> resolveStudCodeFromNotificationData(Map<String, dynamic> data) async {
  try {
    final studCodeRaw = data['studcode'];
    final studCode = studCodeRaw?.toString().trim();
    if (studCode != null && studCode.isNotEmpty) return studCode;

    final topicRaw = data['topic'];
    final topic = topicRaw?.toString().trim();
    if (topic != null && topic.isNotEmpty && topic.startsWith('stud_')) {
      return topic.substring(5);
    }

    final topics = await FcmTopicService.getStoredTopics();
    for (final t in topics) {
      final s = t.toString().trim();
      if (s.startsWith('stud_') && s.length > 5) {
        return s.substring(5);
      }
    }
  } catch (e, st) {
    log('resolveStudCodeFromNotificationData error: $e\n$st');
  }
  return null;
}

/// To verify that your messages are being received, you ought to see a notification appearon your device/emulator via the flutter_local_notifications plugin.
/// Define a top-level named handler which background/terminated messages will
/// call. Be sure to annotate the handler with `@pragma('vm:entry-point')` above the function declaration.
/// Delimiter so you can quickly spot FCM logs in console (e.g. search for "FCM_PAYLOAD" or "══").
const String _kFcmLogStart = '\n═══ [FCM_PAYLOAD] START ═══';
const String _kFcmLogEnd = '═══ [FCM_PAYLOAD] END ═══\n';

/// Prints the full FCM message as received (messageId, notification, data) in a distinct block.
void printFcmMessage(RemoteMessage message, {String source = 'FOREGROUND'}) {
  try {
    final notification = message.notification;
    final data = message.data;
    final notificationMap = notification != null
        ? {
            'title': notification.title,
            'body': notification.body,
          }
        : null;
    final payload = {
      'messageId': message.messageId,
      'sentTime': message.sentTime?.toIso8601String(),
      'notification': notificationMap,
      'data': data,
    };
    final payloadJson = const JsonEncoder.withIndent('  ').convert(payload);
    log('$_kFcmLogStart\n[FCM] source: $source\n$payloadJson\n$_kFcmLogEnd');
  } catch (e, st) {
    log('$_kFcmLogStart\n[FCM] source: $source | ERROR printing payload: $e\n$st\n$_kFcmLogEnd');
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: AppEnivrornment.firebaseOptions);
  await setupFlutterNotifications();
  showFlutterNotification(message);
  try {
    final payload = {
      'messageId': message.messageId,
      'notification': message.notification != null
          ? {
              'title': message.notification!.title,
              'body': message.notification!.body,
            }
          : null,
      'data': message.data,
    };
    final payloadJson = const JsonEncoder.withIndent('  ').convert(payload);
    print('$_kFcmLogStart\n[FCM] source: BACKGROUND\n$payloadJson\n$_kFcmLogEnd');
  } catch (e) {
    print('$_kFcmLogStart\n[FCM] source: BACKGROUND | data: ${message.data}\n$_kFcmLogEnd');
  }
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

    // Initialize local notifications plugin
    const androidSettings = AndroidInitializationSettings('ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await flutterLocalNotificationsPlugin!.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap from local notifications plugin
        if (response.payload != null && response.payload!.isNotEmpty) {
          try {
            // Payload is JSON encoded
            final data = jsonDecode(response.payload!) as Map<String, dynamic>;
            log('Notification tapped, payload: $data');
            Future.delayed(const Duration(milliseconds: 300), () {
              goToNextScreen(data, null);
            });
          } catch (e) {
            log('Error parsing notification payload: $e, payload: ${response.payload}');
          }
        }
      },
    );

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
    if (notification == null || kIsWeb || flutterLocalNotificationsPlugin == null) {
      return;
    }

    final title = notification.title ?? '';
    final body = notification.body ?? '';
    
    if (title.isEmpty && body.isEmpty) {
      return;
    }

    // Create JSON payload string from message data for notification tap handling
    final payload = jsonEncode(message.data);

    if (Platform.isAndroid) {
      // Android notification
      flutterLocalNotificationsPlugin!.show(
        notification.hashCode,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: 'ic_launcher',
            largeIcon: const DrawableResourceAndroidBitmap('ic_launcher'),
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        payload: payload,
      );
    } else if (Platform.isIOS) {
      // iOS notification
      flutterLocalNotificationsPlugin!.show(
        notification.hashCode,
        title,
        body,
        const NotificationDetails(
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: payload,
      );
    }
  } catch (e) {
    log("Error showing notification: $e");
  }
}

/// Initialize the [FlutterLocalNotificationsPlugin] package.
FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;

void goToNextScreen(Map<String, dynamic> data, BuildContext? context) {
  debugPrint(data.toString());
  log("goToNextScreen called with data: $data");

  // Use navigatorKey.currentContext if context is null or invalid
  final safeContext = context ?? navigatorKey.currentContext;
  if (safeContext == null) {
    log("Warning: No valid context available for navigation");
    return;
  }

    if (data['click_action'] != null) {
    if (data['click_action'] == 'NOTIFICATION') {
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) {
            // Use Future.microtask to ensure context is valid
            Future.microtask(() {
              try {
                Provider.of<NavProvider>(
                  context,
                  listen: false,
                ).changeIndex(2, context);
              } catch (e) {
                log("Error changing nav index: $e");
              }
            });
            return const HomeScreenView();
          },
        ),
        (route) => false,
      );
    } else if (data['click_action'] == 'COMMUNICATION') {
      final String? commTypeId = data['comm_type_id']?.toString().trim();

      Future<void> runCommunicationNavigation() async {
        try {
          final String? studCode = await resolveStudCodeFromNotificationData(data);

          final navContext = navigatorKey.currentContext;
          if (navContext == null) {
            log("COMMUNICATION: No navigator context, skipping");
            return;
          }

          if (studCode != null) {
            try {
              Provider.of<StudentProvider>(
                navContext,
                listen: false,
              ).selectStudentWithStudId(studCode);
            } catch (e) {
              log("COMMUNICATION: Error selecting student: $e");
            }
          }

          final state = navigatorKey.currentState;
          if (state == null) {
            log("COMMUNICATION: No navigator state, skipping");
            return;
          }

          state.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) {
                Future.microtask(() async {
                  try {
                    Provider.of<NavProvider>(
                      context,
                      listen: false,
                    ).changeIndex(3, context);

                    if (studCode != null &&
                        commTypeId != null &&
                        commTypeId.isNotEmpty) {
                      await Future.delayed(const Duration(milliseconds: 400));
                      final ctx = navigatorKey.currentContext;
                      if (ctx != null) {
                        final commProvider = Provider.of<CommunicationProvider>(
                          ctx,
                          listen: false,
                        );
                        await commProvider.getCommunicationList(studCode);
                        final tiles = commProvider.communicationList;
                        if (tiles.isNotEmpty) {
                            final tile = tiles.firstWhere(
                            (t) => t.id == commTypeId,
                            orElse: () => tiles.first,
                          );
                          navigatorKey.currentState?.push(
                            MaterialPageRoute(
                              builder: (_) => CommunicationDetailScreen(
                                studCode: studCode,
                                communicationTileModel: tile,
                              ),
                            ),
                          );
                        }
                      }
                    }
                  } catch (e, st) {
                    log("COMMUNICATION: Error in microtask: $e\n$st");
                  }
                });
                return const HomeScreenView();
              },
            ),
            (route) => false,
          );
        } catch (e, st) {
          log("COMMUNICATION: runCommunicationNavigation error: $e\n$st");
        }
      }
      runCommunicationNavigation();
    } else if (data['click_action'] == 'MENU') {
      final String? menuKey = data['menu_key']?.toString().trim();
      final String? url = data['url']?.toString().trim();

      Future<void> runMenuNavigation() async {
        try {
          final String? studCode = await resolveStudCodeFromNotificationData(data);

          final state = navigatorKey.currentState;
          if (state == null) {
            log("MENU: No navigator state, skipping");
            return;
          }

          state.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) {
                Future.microtask(() async {
                  try {
                    Provider.of<NavProvider>(
                      context,
                      listen: false,
                    ).changeIndex(0, context);

                    if (menuKey != null && menuKey.isNotEmpty) {
                      await Future.delayed(const Duration(milliseconds: 500));
                      await navigateToMenuScreen(
                        menuKey: menuKey,
                        studcode: studCode,
                        url: url?.isNotEmpty == true ? url : null,
                      );
                    }
                  } catch (e, st) {
                    log("MENU: Error in microtask: $e\n$st");
                  }
                });
                return const HomeScreenView();
              },
            ),
            (route) => false,
          );
        } catch (e, st) {
          log("MENU: runMenuNavigation error: $e\n$st");
        }
      }
      runMenuNavigation();
    } else {
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) {
            Future.microtask(() {
              try {
                Provider.of<NavProvider>(
                  context,
                  listen: false,
                ).changeIndex(0, context);
              } catch (e) {
                log("Error changing nav index: $e");
              }
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
  static bool _isInitialized = false;
  static BuildContext? _storedContext;

  // Expose initialization state so UI code can avoid redundant setup work.
  static bool get isInitialized => _isInitialized;

  static void start(BuildContext context) {
    if (_isInitialized) {
      log("FirebaseNotificationService already initialized, skipping...");
      return;
    }
    _isInitialized = true;
    _storedContext = context;

    // Initialize local notifications
    setupFlutterNotifications();

    // Handle foreground messages (app is open)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      printFcmMessage(message, source: 'FOREGROUND');
      if (message.notification != null) {
        // Update badge counts
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

        // Show local notification only when app is in foreground
        // (FCM handles it automatically when app is in background/terminated)
        showFlutterNotification(message);
      }
    });

    // Handle notification tap when app is opened from background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      printFcmMessage(message, source: 'OPENED FROM NOTIFICATION');
      Future.delayed(const Duration(milliseconds: 500), () {
        goToNextScreen(message.data, _storedContext);
      });
    });

    // Handle notification tap when app is launched from terminated state
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        printFcmMessage(message, source: 'LAUNCHED FROM NOTIFICATION');
        Future.delayed(const Duration(milliseconds: 1000), () {
          goToNextScreen(message.data, _storedContext);
        });
      }
    });
  }
}

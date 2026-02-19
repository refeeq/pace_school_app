import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:school_app/app.dart';
import 'package:school_app/core/notification/firebase_notification.dart';
import 'package:school_app/core/services/dependecyInjection.dart';

import 'core/constants/db_constants.dart';
import 'core/models/auth_model.dart';
import 'core/models/parent_model.dart';
import 'core/models/students_model.dart';

Future<void> initilization() async {
  try {
    // Initialize Firebase with default name for compatibility
    await Firebase.initializeApp(options: AppEnivrornment.firebaseOptions);

    // Initialize dependency injection
    serviceLocators();

    // Initialize Hive database
    await Hive.initFlutter();

    // Register Hive adapters
    Hive.registerAdapter(ParentModelAdapter());
    Hive.registerAdapter(AuthModelAdapter());
    Hive.registerAdapter(StudentModelAdapter());

    // Open Hive boxes
    await Hive.openBox("token");
    await Hive.openBox("allNotification");
    await Hive.openBox("notification");
    await Hive.openBox("communication");
    await Hive.openBox("notificationPermission");
    await Hive.openBox<ParentModel>(PARENTDB);
    await Hive.openBox<AuthModel>(USERDB);
    await Hive.openBox("notificationCount");
    await Hive.openBox("documentExpiry");
    await Hive.openBox("fcm_topics");

    // Set default notification setting
    if (Hive.box('notification').values.isEmpty) {
      await Hive.box('notification').put("notification", true);
    }

    // Register background message handler for FCM
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  } catch (e) {
    print('Initialization error: $e');
    // Continue with app launch even if initialization fails
  }
}

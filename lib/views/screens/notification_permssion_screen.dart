import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:school_app/views/screens/student/login_screen/login_screen_view.dart';

class NotificationPermissionScreen extends StatefulWidget {
  const NotificationPermissionScreen({super.key});

  @override
  State<NotificationPermissionScreen> createState() =>
      _NotificationPermissionScreenState();
}

class _NotificationPermissionScreenState
    extends State<NotificationPermissionScreen>
    with WidgetsBindingObserver {
  bool isNotificationPermissionEnabled = true;

  @override
  Widget build(BuildContext context) {
    if (isNotificationPermissionEnabled) {
      // Notification permission is enabled.
      return LoginScreen();
    } else {
      // Notification permission is not enabled.
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'This app requires notification permission.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await openAppSettings();
                },
                child: const Text('Enable Permission'),
              ),
            ],
          ),
        ),
      );
    }
  }

  // Function to check and update the notification permission status.
  Future<void> checkNotificationPermissionStatus() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      if (mounted) {
        setState(() {
          isNotificationPermissionEnabled = status.isGranted;
        });
      }
    } else {
      try {
        var settings = await FirebaseMessaging.instance
            .getNotificationSettings();
        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          if (mounted) {
            setState(() {
              isNotificationPermissionEnabled = true;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              isNotificationPermissionEnabled = false;
            });
          }
        }
      } catch (e) {
        print("Firebase Messaging error in notification permission screen: $e");
        if (mounted) {
          setState(() {
            isNotificationPermissionEnabled = false;
          });
        }
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      checkNotificationPermissionStatus();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    checkNotificationPermissionStatus();
  }
}

import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/notification/firebase_notification.dart';
import 'package:school_app/core/provider/notification_provider.dart';
import 'package:school_app/core/provider/student_provider.dart';
import 'package:school_app/core/repository/repository.dart';
import 'package:school_app/core/services/dependecyInjection.dart';
import 'package:school_app/core/themes/const_gradient.dart';
import 'package:school_app/views/components/communication_icon.dart';
import 'package:school_app/views/components/notification_icon.dart';
import 'package:school_app/views/screens/parent/parent_profile/parent_profile_screen_view.dart';
import 'package:upgrader/upgrader.dart';

import '../../../core/provider/ios_update_provider.dart';
import '../../../core/provider/nav_provider.dart';
import '../../../core/services/auto_update.dart';
import '../../../core/themes/const_colors.dart';
import '../parent/communication_checker.dart';
import '../parent/parent_notification_screen/parent_notification_screen_view.dart';
import 'home_screen_view.dart';

class HomeScreenView extends StatefulWidget {
  const HomeScreenView({super.key});

  @override
  State<HomeScreenView> createState() => _HomeScreenViewState();
}

class _HomeScreenViewState extends State<HomeScreenView>
    with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    var list = [
      const HomeView(),
      const ParentProfileScreenView(),
      const ParentNotificationScreenView(),
      const CommunicationChecker(),
    ];

    return Consumer<NavProvider>(
      builder: (context, provider, child) => LayoutBuilder(
        builder: (p0, p1) => Container(
          decoration: BoxDecoration(gradient: ConstGradient.linearGradient),
          child: PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) async {
              if (didPop) return;
              showModalBottomSheet(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(15.0),
                  ),
                ),
                context: context,
                builder: (context) => UpgradeAlert(
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.28,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Align(
                              alignment: Alignment.topRight,
                              child: InkWell(
                                onTap: () => Navigator.pop(context),
                                child: const CircleAvatar(
                                  backgroundColor: Color.fromARGB(
                                    255,
                                    108,
                                    111,
                                    122,
                                  ),
                                  radius: 14,
                                  child: Center(
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const Text(
                              'Are you sure you want to exit ?',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 12,
                                right: 12,
                              ),
                              child: GestureDetector(
                                onTap: () async {
                                  SystemNavigator.pop();
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(255, 164, 2, 2),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  width: MediaQuery.of(context).size.width,
                                  height: 50,
                                  child: const Center(
                                    child: Text(
                                      'YES',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        color: Color.fromRGBO(255, 255, 255, 1),
                                        fontFamily: 'SourceSansPro',
                                        fontSize: 18,
                                        letterSpacing: 0,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 12,
                                  right: 12,
                                ),
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "NO",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        color: ConstColors.primary,
                                        fontFamily: 'SourceSansPro',
                                        fontSize: 18,
                                        letterSpacing: 0,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );

              return;
            },
            child: Scaffold(
              key: _scaffoldKey,
              backgroundColor: Colors.white,
              body: list[provider.index],
              bottomNavigationBar: Container(
                width: 328.w,
                height: 64.h,
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Color(0x214D4D52),
                      blurRadius: 16,
                      offset: Offset(0, 2),
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: Color(0x1EFFFFFF),
                      blurRadius: 1,
                      offset: Offset(0, 0),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.only(left: 15.0.w, right: 15.0.w),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          provider.changeIndex(0, context);
                        },
                        child: provider.index == 0
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/bottom/home_selected.png",
                                    height: 35,
                                    width: 35,
                                  ),
                                  SizedBox(width: 0.w),
                                  Text(
                                    "Home",
                                    style: TextStyle(
                                      color: provider.index == 0
                                          ? ConstColors.primary
                                          : null,
                                    ),
                                  ),
                                ],
                              )
                            : Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset(
                                  "assets/bottom/home_unselected.png",
                                  height: 35,
                                  width: 35,
                                ),
                              ),
                      ),
                      InkWell(
                        onTap: () {
                          provider.changeIndex(1, context);
                        },
                        child: provider.index == 1
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/bottom/profile_selected.png",
                                    height: 35,
                                    width: 35,
                                  ),
                                  SizedBox(width: 0.w),
                                  Text(
                                    "Profile",
                                    style: TextStyle(
                                      color: provider.index == 1
                                          ? ConstColors.primary
                                          : null,
                                    ),
                                  ),
                                ],
                              )
                            : Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset(
                                  "assets/bottom/profile_unselected.png",
                                  height: 35,
                                  width: 35,
                                ),
                              ),
                      ),
                      InkWell(
                        onTap: () {
                          provider.changeIndex(2, context);
                        },
                        child: provider.index == 2
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  NotificationIcon(
                                    isSelected: provider.index == 2,
                                  ),
                                  SizedBox(width: 0.w),
                                  Text(
                                    "Notification",
                                    style: TextStyle(
                                      color: provider.index == 2
                                          ? ConstColors.primary
                                          : Colors.transparent,
                                    ),
                                  ),
                                ],
                              )
                            : Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: NotificationIcon(
                                  isSelected: provider.index == 2,
                                ),
                              ),
                      ),
                      InkWell(
                        onTap: () {
                          provider.changeIndex(3, context);
                        },
                        child: provider.index == 3
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CommunicationIcon(
                                    isSelected: provider.index == 3,
                                  ),
                                  SizedBox(width: 0.w),
                                  Text(
                                    "Communication",
                                    style: TextStyle(
                                      color: provider.index == 3
                                          ? ConstColors.primary
                                          : null,
                                    ),
                                  ),
                                ],
                              )
                            : Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CommunicationIcon(
                                  isSelected: provider.index == 3,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> checkNotificationPermissionStatus() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      await messaging
          .getToken()
          .then((value) {
            log("token: ${value.toString()}");
          })
          .onError((error, stackTrace) {
            log(error.toString());
          });
      if (Platform.isAndroid) {
        final status = await Permission.notification.status;
        if (status.isGranted) {
          initNotification(context);
        } else {
          await Hive.box('notification').put("notification", false);
        }
      } else {
        var settings = await FirebaseMessaging.instance
            .getNotificationSettings();
        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          initNotification(context);
        } else {
          await Hive.box('notification').put("notification", false);
        }
      }
    } catch (e) {
      log("Firebase Messaging error in checkNotificationPermissionStatus: $e");
      await Hive.box('notification').put("notification", false);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (!kDebugMode) {
      if (state == AppLifecycleState.resumed) {
        checkNotificationPermissionStatus();
        if (Platform.isAndroid) {
          AutoUpdateAndriod().checkforUpdate(context);
        } else {
          Future(
            () => Provider.of<AutoUpdateProvider>(
              context,
              listen: false,
            ).checkForUpdates(),
          );
        }
      }
    }
  }

  @override
  void didChangeDependencies() async {
    Provider.of<NotificationProvider>(
      context,
      listen: false,
    ).getAllNotificationCount();

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  Future<void> initNotification(BuildContext context) async {
    //local notification initialization
    FirebaseNotificationService.start(context);
    await Future.delayed(const Duration(seconds: 1));
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      await messaging.getToken().then((value) {
        log(value.toString());
      });
    } catch (e) {
      log("Firebase Messaging error in initNotification: $e");
    }
    //firebase notification
    // NotificationService().getToken();
    //sending firebase token to server
    Repository repo = locator<Repository>();
    if (Hive.box("notificationPermission").isEmpty) {
      repo.setFcmToken();
    }

    // NotificationService.handleNotifications(context);
  }

  @override
  void initState() {
    if (mounted) {
      Future(
        () =>
            Provider.of<StudentProvider>(context, listen: false).getStudents(),
      );
    }
    checkNotificationPermissionStatus();
    // init();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }
}

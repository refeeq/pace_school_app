import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:school_app/core/constants/db_constants.dart';
import 'package:school_app/core/models/auth_model.dart';
import 'package:school_app/views/screens/home_screen/bottom_nav.dart';
import 'package:school_app/views/screens/student/login_screen/login_screen_view.dart';

class AuthListener extends StatefulWidget {
  const AuthListener({super.key});

  @override
  State<AuthListener> createState() => _AuthListenerState();
}

class _AuthListenerState extends State<AuthListener> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<AuthModel>(USERDB).listenable(),
      builder: (context, Box<AuthModel> box, child) {
        if (box.values.isNotEmpty) {
          // User is logged in, navigate to the appropriate screen
          return const HomeScreenView();
        } else {
          // User is logged out, navigate to the login screen
          return LoginScreen();
        }
      },
    );
  }

  @override
  void didChangeDependencies() {
    // if (!kDebugMode) {
    //   if (Platform.isAndroid) {
    //     AutoUpdateAndriod().checkforUpdate(context);
    //   } else {
    //     Future(
    //       () => Provider.of<AutoUpdateProvider>(context, listen: false)
    //           .checkForUpdates(),
    //     );
    //   }
    // }

    super.didChangeDependencies();
  }
}

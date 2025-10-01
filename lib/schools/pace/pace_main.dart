import 'package:flutter/material.dart';
import 'package:school_app/app.dart';
import 'package:school_app/inital.dart';
import 'package:school_app/main.dart';

void main() async {
  // Setup environment first
  AppEnivrornment.setupEnv(AppEnvironmentNames.pace);

  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase and other services
  await initilization();

  // Run the app
  runApp(const MyApp());
}

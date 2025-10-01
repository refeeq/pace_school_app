import 'package:flutter/material.dart';
import 'package:school_app/app.dart';
import 'package:school_app/inital.dart';
import 'package:school_app/main.dart';

void main() async {
  AppEnivrornment.setupEnv(AppEnvironmentNames.cbsa);
  WidgetsFlutterBinding.ensureInitialized();
  await initilization();
  runApp(const MyApp());
}

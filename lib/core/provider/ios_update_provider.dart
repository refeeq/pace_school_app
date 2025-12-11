import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:school_app/app.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../views/screens/home_screen/bottom_nav.dart';

class AppleUpdateScreen extends StatelessWidget {
  const AppleUpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            Center(
              child: Image.asset(
                AppEnivrornment.appImageName,
                height: MediaQuery.of(context).size.height * 0.22,
              ),
            ),
            Center(
              child: Text(
                "New Update Available",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: 10),
            const Text('A new version of the app is available!'),
            const SizedBox(height: 30),
            MaterialButton(
              color: ConstColors.primary,
              onPressed: () {
                String url = AppEnivrornment.appUrl;

                launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.apple, color: Colors.white),
                  SizedBox(width: 10),
                  Text("UPDATE NOW", style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            MaterialButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomeScreenView(),
                  ),
                  (route) => false,
                );
              },
              child: const Text(
                "UPDATE LATER",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AutoUpdateProvider with ChangeNotifier {
  //   class AppVersionProvider extends ChangeNotifier {
  String _currentVersion = '';
  String _latestVersion = '';

  bool loading = false;
  String get currentVersion => _currentVersion;
  String get latestVersion => _latestVersion;
  Future<void> checkforUpdateinitial(BuildContext context) async {
    checkForUpdates();
    if (!isAppUpToDate()) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AppleUpdateScreen()),
      );
    }
  }

  // Method to check for app updates
  Future<void> checkForUpdates() async {
    loading = true;
    notifyListeners();
    await getVersion();
    // Get the latest version from the App Store
    // Replace APP_STORE_APP_ID with your own app's ID
    String appID = AppEnivrornment.appId;
    String url = 'https://itunes.apple.com/lookup?id=$appID';
    http.Response response = await http.get(Uri.parse(url));
    var data = json.decode(response.body);
    if (data['results'][0] != []) {
      _latestVersion = data['results'][0]['version'];
    }
    loading = false;
    notifyListeners();
  }

  Future<void> getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _currentVersion = packageInfo.version;
    notifyListeners();
  }

  // Method to check if the app is up to date
  bool isAppUpToDate() {
    bool isUpdate = false;

    if (currentVersion != latestVersion) {
      List<String> currentParts = _currentVersion.split('.');
      List<String> latestParts = _latestVersion.split('.');
      for (int i = 0; i < currentParts.length; i++) {
        int currentPart = int.parse(currentParts[i]);
        int latestPart = int.parse(latestParts[i]);
        if (latestPart > currentPart) {
          isUpdate = true;
          break;
        }
      }
    }
    return isUpdate;
  }
}

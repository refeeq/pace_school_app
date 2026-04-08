import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:logger/logger.dart';

// class AutoUpdate {
//   String _currentVersion = '';
//   String _latestVersion = '';
//   bool isUpdate = false;
//   Future<String> checkForUpdate() async {
//     String appID = 'YOUR_APP_ID'; // Replace with your app's ID
//     String url = 'https://itunes.apple.com/lookup?id=$appID';
//     http.Response response = await http.get(Uri.parse(url));
//     var data = json.decode(response.body);

//     _latestVersion = data['results'][0]['version'];
//     return _latestVersion;
//   }

//   compareVersions() {
//     if (_currentVersion.isNotEmpty && _latestVersion.isNotEmpty) {
//       List<String> currentParts = _currentVersion.split('.');
//       List<String> latestParts = _latestVersion.split('.');
//       for (int i = 0; i < currentParts.length; i++) {
//         int currentPart = int.parse(currentParts[i]);
//         int latestPart = int.parse(latestParts[i]);
//         if (latestPart > currentPart) {
//           isUpdate = true;
//           break;
//         }
//       }
//       return isUpdate;
//     }
//   }

//   Future<void> getAppVersion() async {
//     PackageInfo packageInfo = await PackageInfo.fromPlatform();

//     _currentVersion = packageInfo.version;
//   }
// }

class AutoUpdateAndriod {
  // set up the AlertDialog

  bool isUpadate = false;
  Logger logger = Logger();
  Future<void> checkforUpdate(BuildContext context) async {
    // Checks for any updates

    try {
      AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();

      // Check if there is an update available. Then force update based on
      // the version number
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable &&
          updateInfo.immediateUpdateAllowed) {
        InAppUpdate.performImmediateUpdate().then((value) async {
          await InAppUpdate.checkForUpdate();
        });
      }
    }
    //if any error occured catch will print the error
    catch (e) {
      logger.i(e);
    }
  }
}

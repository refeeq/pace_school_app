import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/provider/communication_provider.dart';
import 'package:school_app/core/provider/notification_provider.dart';

class NavProvider with ChangeNotifier {
  var index = 0;
  void changeIndex(int val, BuildContext context) {
    index = val;
    if (val == 2) {
      Provider.of<NotificationProvider>(
        context,
        listen: false,
      ).getAllNotifications(isRefresh: true);
      Provider.of<NotificationProvider>(
        context,
        listen: false,
      ).getAllNotificationCount();
    } else if (val == 3) {
      Provider.of<CommunicationProvider>(
        context,
        listen: false,
      ).getStudentList();
    }
    log("bottom index $val");
    notifyListeners();
  }
}

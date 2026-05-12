import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/provider/communication_provider.dart';
import 'package:school_app/core/provider/notification_provider.dart';
import 'package:school_app/core/provider/student_provider.dart';

class NavProvider with ChangeNotifier {
  var index = 0;
  /// Clears navigation state. Call on logout.
  void clearOnLogout() {
    index = 0;
    notifyListeners();
  }

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
      final comm = Provider.of<CommunicationProvider>(
        context,
        listen: false,
      );
      comm.getStudentList();
      final studentProvider = Provider.of<StudentProvider>(
        context,
        listen: false,
      );
      if (studentProvider.studentsModel?.data.isNotEmpty ?? false) {
        comm.getCommunicationList(
          studentProvider.selectedStudentModel(context).studcode,
        );
      }
    }
    log("bottom index $val");
    notifyListeners();
  }
}

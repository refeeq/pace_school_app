import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:observe_internet_connectivity/observe_internet_connectivity.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:school_app/core/config/app_status.dart';
import 'package:school_app/core/models/notification_model.dart';
import 'package:school_app/core/services/dependecyInjection.dart';

import '../repository/notification/repository.dart';

class NotificationProvider with ChangeNotifier {
  NotificationRepository repository = locator<NotificationRepository>();

  DataState getAllNotificationState = DataState.Uninitialized;

  int _currentPageNumber = 0; // Current Page to get Data from API

  bool _didLastLoad =
      false; // Property through which we can check if last page have been loaded from API or not
  List<NotificationModel> _notificationList = []; // List Containing the data
  bool _isNotificationPermissionEnabled = false;
  DataState get dataState =>
      getAllNotificationState; // getters of State of Data

  bool get isNotificationPermissionEnabled => _isNotificationPermissionEnabled;

  List<NotificationModel> get notificationList =>
      _notificationList; // getters of List of Data

  // Function to check and update the notification permission status.
  Future<void> checkNotificationPermissionStatus() async {
    final status = await Permission.notification.status;
    _isNotificationPermissionEnabled = status.isGranted;
    notifyListeners();
  }

  /// Clears all cached user data. Call on logout.
  void clearOnLogout() {
    getAllNotificationState = DataState.Uninitialized;
    _currentPageNumber = 0;
    _didLastLoad = false;
    _notificationList = [];
    notifyListeners();
  }

  Future<void> getAllNotificationCount() async {
    bool hasInternet = await InternetConnectivity().hasInternetConnection;
    if (hasInternet) {
      var respon = await repository.getAllNotifications(0);
      if (respon.isRight) {
        await Hive.box('notificationCount').put("count", 0);
        await Hive.box("notificationCount").put("new", "");
        await Hive.box("notificationCount").put("count", respon.right['count']);
      }
    }
  }

  Future<void> getAllNotifications({
    bool isRefresh = false, //required BuildContext context
  }) async {
    bool hasInternet = await InternetConnectivity().hasInternetConnection;
    if (!isRefresh) {
      getAllNotificationState =
          (getAllNotificationState == DataState.Uninitialized)
          ? DataState.Initial_Fetching
          : DataState.More_Fetching;
    } else {
      _notificationList.clear();
      _notificationList = [];
      _currentPageNumber = 0;
      getAllNotificationState = DataState.Initial_Fetching;
      _didLastLoad = false;
      if (!hasInternet) {
        getAllNotificationState = DataState.NoInterNetConnectionState;
      }
    }
    notifyListeners();
    if (hasInternet) {
      try {
        if (_didLastLoad) {
          getAllNotificationState = DataState.No_More_Data;
        } else {
          var respon = await repository.getAllNotifications(_currentPageNumber);
          if (isRefresh) {
            await Hive.box('notificationCount').put("count", 0);

            await Hive.box(
              "notificationCount",
            ).put("count", respon.right['count']);
          }

          if (respon.isLeft) {
            // showToast(respon.left.message.toString(), context);
            log(respon.left.message.toString());
            log(respon.left.key.toString());
            getAllNotificationState = DataState.Error;
          } else {
            if (isRefresh) {
              notificationList.clear();
            }
            getAllNotificationState = DataState.Fetched;
            List<NotificationModel> list = List<NotificationModel>.from(
              respon.right["data"].map((x) => NotificationModel.fromJson(x)),
            );

            if (_notificationList.isEmpty && list.isEmpty) {
              _notificationList = [];
            } else if (list.isEmpty) {
              _didLastLoad = true;
            } else {
              _notificationList += list;

              _currentPageNumber += 1;
            }
          }
        }
        notifyListeners();
      } catch (e) {
        getAllNotificationState = DataState.Error;
        notifyListeners();
      }
    }
  }

  Future<void> readNotification(String id) async {
    var respon = await repository.readNotifiction(id);
    if (respon.isLeft) {
      log(respon.left.message.toString());
      log(respon.left.key.toString());
      //   getAllNotificationState = AppStates.Error;
    } else {
      //   getAllNotificationState = AppStates.Fetched;
      //  showToast(respon.right.message);
      log(respon.right.toString());
      // notificationList = respon.right;
    }
    notifyListeners();
  }
}

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:observe_internet_connectivity/observe_internet_connectivity.dart';
import 'package:school_app/core/config/app_status.dart';
import 'package:school_app/core/models/student_menu_model.dart';
import 'package:school_app/core/repository/guest/repository.dart';
import 'package:school_app/core/services/dependecyInjection.dart';

class GuestProvider with ChangeNotifier {
  GuestRepository repository = locator<GuestRepository>();
  AppStates guestMenuState = AppStates.Unintialized;
  List<StudentMenu> guestMenueList = [];
  Future<void> getGuestMenu() async {
    guestMenuState = AppStates.Initial_Fetching;
    bool hasInternet = await InternetConnectivity().hasInternetConnection;

    if (!hasInternet) {
      guestMenuState = AppStates.NoInterNetConnectionState;
    } else {
      var respon = await repository.getGuestMenue();
      if (respon.isLeft) {
        log(respon.left.message.toString());
        log(respon.left.key.toString());
        guestMenuState = AppStates.Error;
      } else {
        if (respon.right['status'] == true) {
          guestMenuState = AppStates.Fetched;
          //   showToast(respon.right.message);
          log(respon.right.toString());
          guestMenueList = List<StudentMenu>.from(
            respon.right["data"].map((x) => StudentMenu.fromJson(x)),
          );
        } else {
          guestMenueList = [];
        }
      }
    }
    notifyListeners();
  }
}

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:observe_internet_connectivity/observe_internet_connectivity.dart';
import 'package:school_app/core/config/app_status.dart';
import 'package:school_app/core/models/school_info_model.dart';
import 'package:school_app/core/repository/school/repository.dart';
import 'package:school_app/core/services/dependecyInjection.dart';

class SchoolProvider with ChangeNotifier {
  SchoolRepository repository = locator<SchoolRepository>();
  AppStates schoolInfoState = AppStates.Unintialized;
  SchoolInfoModel? schoolInfoModel;
  Future<void> getSchoolInfo() async {
    schoolInfoState = AppStates.Initial_Fetching;
    bool hasInternet = await InternetConnectivity().hasInternetConnection;

    if (!hasInternet) {
      schoolInfoState = AppStates.NoInterNetConnectionState;
    } else {
      var respon = await repository.getSchoolInfo();
      if (respon.isLeft) {
        log(respon.left.message.toString());
        log(respon.left.key.toString());
        schoolInfoState = AppStates.Error;
      } else {
        if (respon.right != {}) {
          schoolInfoState = AppStates.Fetched;
          // showToast(respon.right.message);
          log(respon.right.toString());
          schoolInfoModel = respon.right;
        } else {
          log(respon.right.toString());
        }
      }
    }
    notifyListeners();
  }
}

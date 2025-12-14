import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:observe_internet_connectivity/observe_internet_connectivity.dart';
import 'package:school_app/core/config/app_status.dart';
import 'package:school_app/core/models/parent_profile_list_model.dart';
import 'package:school_app/core/models/parent_profile_model.dart';
import 'package:school_app/core/repository/parent/repository.dart';
import 'package:school_app/core/services/dependecyInjection.dart';

import '../utils/utils.dart';

class ParentProvider with ChangeNotifier {
  ParentRepository repository = locator<ParentRepository>();

  ParentProfileModel? parentProfileModel;

  AppStates parentDetail = AppStates.Unintialized;
  ParentProfileListModel? parentProfileListModel;
  AppStates parentDetailListState = AppStates.Unintialized;
  AppStates parentOtpState = AppStates.Unintialized;
  AppStates parentMobileOtpState = AppStates.Unintialized;
  int parentSelected = 0;

  Future<void> getParentDetails() async {
    parentDetail = AppStates.Initial_Fetching;
    bool hasInternet = await InternetConnectivity().hasInternetConnection;

    if (!hasInternet) {
      parentDetail = AppStates.NoInterNetConnectionState;
    } else {
      notifyListeners();
      var respon = await repository.getParentProfile();
      if (respon.isLeft) {
        log(respon.left.message.toString());
        log(respon.left.key.toString());
        parentDetail = AppStates.Error;
      } else {
        if (respon.right.status == true) {
          parentDetail = AppStates.Fetched;
          // showToast(respon.right.message);
          log(respon.right.data.toString());
          parentProfileModel = respon.right;
        }
      }
    }
    notifyListeners();
  }

  Future<void> getParentDetailsList() async {
    parentDetailListState = AppStates.Initial_Fetching;
    notifyListeners();
    bool hasInternet = await InternetConnectivity().hasInternetConnection;

    if (!hasInternet) {
      parentDetailListState = AppStates.NoInterNetConnectionState;
    } else {
      notifyListeners();
      var respon = await repository.getParentProfileList();
      if (respon.isLeft) {
        log(respon.left.message.toString());
        log(respon.left.key.toString());
        parentDetailListState = AppStates.Error;
      } else {
        if (respon.right.status == true) {
          parentDetailListState = AppStates.Fetched;
          // showToast(respon.right.message);
          log(respon.right.data.toString());
          parentProfileListModel = respon.right;
        }
      }
    }
    notifyListeners();
  }

  void selectParent(int id) {
    parentSelected = id;
    notifyListeners();
  }

  Future<void> sendMobileOtp({
    required String relation,
    required String mobile,
    required BuildContext context,
  }) async {
    parentMobileOtpState = AppStates.Initial_Fetching;
    bool hasInternet = await InternetConnectivity().hasInternetConnection;

    if (!hasInternet) {
      parentMobileOtpState = AppStates.NoInterNetConnectionState;
    } else {
      notifyListeners();
      var respon = await repository.updateParentMobile(
        mobile: mobile,
        relation: relation,
      );
      if (respon.isLeft) {
        log(respon.left.message.toString());
        log(respon.left.key.toString());
        parentMobileOtpState = AppStates.Error;
      } else {
        if (respon.right['status'] == true) {
          parentMobileOtpState = AppStates.Fetched;
          showToast(respon.right["message"].toString(), context);
          log(respon.right.toString());
        } else {
          parentMobileOtpState = AppStates.Error;
          showToast(respon.right["message"].toString(), context);
        }
      }
    }
    notifyListeners();
  }

  Future<void> sendEmailOtp({
    required String relation,
    required String email,
    required BuildContext context,
  }) async {
    parentOtpState = AppStates.Initial_Fetching;
    bool hasInternet = await InternetConnectivity().hasInternetConnection;

    if (!hasInternet) {
      parentOtpState = AppStates.NoInterNetConnectionState;
    } else {
      notifyListeners();
      var respon = await repository.updateParentEmail(
        email: email,
        relation: relation,
      );
      if (respon.isLeft) {
        log(respon.left.message.toString());
        log(respon.left.key.toString());
        parentOtpState = AppStates.Error;
      } else {
        if (respon.right['status'] == true) {
          parentOtpState = AppStates.Fetched;
          showToast(respon.right["message"].toString(), context);
          // showToast(respon.right.message);
          log(respon.right.toString());
          // parentProfileListModel = respon.right;
        } else {
          parentOtpState = AppStates.Error;
          showToast(respon.right["message"].toString(), context);
        }
      }
    }
    notifyListeners();
  }

  void updateParentMobileOtpStatus() {
    parentMobileOtpState = AppStates.Unintialized;
    notifyListeners();
  }

  void updateParentOtpStatus() {
    parentOtpState = AppStates.Unintialized;
    notifyListeners();
  }

  Future verifyEmailOtp({
    required String relation,
    required String email,
    required String otp,
    required BuildContext context,
  }) async {
    parentOtpState = AppStates.Initial_Fetching;
    bool hasInternet = await InternetConnectivity().hasInternetConnection;

    if (!hasInternet) {
      parentOtpState = AppStates.NoInterNetConnectionState;
    } else {
      notifyListeners();
      var respon = await repository.updateParentEmailOtp(
        email: email,
        relation: relation,
        otp: otp,
      );
      if (respon.isLeft) {
        log(respon.left.message.toString());
        log(respon.left.key.toString());
        parentOtpState = AppStates.Error;
      } else {
        if (respon.right['status'] == true) {
          getParentDetailsList();
          parentOtpState = AppStates.Unintialized;
          showToast(respon.right["message"].toString(), context);

          log(respon.right.toString());
          // parentProfileListModel = respon.right;
        } else {
          parentOtpState = AppStates.Error;
          showToast(respon.right["message"].toString(), context);
        }
      }
    }
    notifyListeners();
  }

  Future verifyMobile({
    required String relation,
    required String mobile,
    required String otp,
    required BuildContext context,
  }) async {
    parentMobileOtpState = AppStates.Initial_Fetching;
    bool hasInternet = await InternetConnectivity().hasInternetConnection;

    if (!hasInternet) {
      parentMobileOtpState = AppStates.NoInterNetConnectionState;
    } else {
      notifyListeners();
      var respon = await repository.updateParentMobileOtp(
        mobile: mobile,
        relation: relation,
        otp: otp,
      );
      if (respon.isLeft) {
        log(respon.left.message.toString());
        log(respon.left.key.toString());
        parentMobileOtpState = AppStates.Error;
      } else {
        if (respon.right['status'] == true) {
          getParentDetailsList();
          parentMobileOtpState = AppStates.Unintialized;
          showToast(respon.right["message"].toString(), context);
          log(respon.right.toString());
        } else {
          parentMobileOtpState = AppStates.Error;
          showToast(respon.right["message"].toString(), context);
        }
      }
    }
    notifyListeners();
  }
}

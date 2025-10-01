import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:observe_internet_connectivity/observe_internet_connectivity.dart';
import 'package:school_app/core/config/app_status.dart';
import 'package:school_app/core/models/admission_det_model.dart';
import 'package:school_app/core/models/leave_list_model.dart';
import 'package:school_app/core/repository/leaveApplication/repository.dart';
import 'package:school_app/core/services/dependecyInjection.dart';
import 'package:school_app/core/utils/utils.dart';

class LeaveProvider with ChangeNotifier {
  List<Grade> leaveReasonList = [];
  Grade? selectedLeaveReasonModel;
  LeaveApplicationRepository repository = locator<LeaveApplicationRepository>();
  AppStates leaveReasonFetchState = AppStates.Unintialized;
  AppStates applyLeaveState = AppStates.Unintialized;
  String error = '';
  List<LeaveListModel> leaveList = [];

  AppStates leaveListFetchState = AppStates.Unintialized;

  Future<void> applyLeave({
    required String fromDate,
    required String endDate,
    required String reasonId,
    required String reason,
    required String studentId,
    required BuildContext context,
  }) async {
    error = "";
    showAlertLoader(context);
    applyLeaveState = AppStates.Initial_Fetching;
    bool hasInternet = await InternetConnectivity().hasInternetConnection;

    if (!hasInternet) {
      applyLeaveState = AppStates.NoInterNetConnectionState;
    } else {
      var respon = await repository.applyLeaveApplication(
        fromDate: fromDate,
        endDate: endDate,
        reasonId: reasonId,
        studentId: studentId,
        reason: reason,
      );
      if (respon.isLeft) {
        Navigator.pop(context);
        log(respon.left.message.toString());
        log(respon.left.key.toString());
        applyLeaveState = AppStates.Error;
      } else {
        Navigator.pop(context);
        if (respon.right["status"] == true) {
          applyLeaveState = AppStates.Fetched;
          getLeaveList(studentId: studentId);
        } else {
          error = respon.right["message"];
          notifyListeners();
          applyLeaveState = AppStates.Error;
        }
      }
    }
    notifyListeners();
  }

  Future<void> getLeaveList({required String studentId}) async {
    leaveList.clear();
    error = "";
    leaveListFetchState = AppStates.Initial_Fetching;
    bool hasInternet = await InternetConnectivity().hasInternetConnection;
    notifyListeners();
    if (!hasInternet) {
      leaveListFetchState = AppStates.NoInterNetConnectionState;
    } else {
      var respon = await repository.getLeaveList(studentId: studentId);
      if (respon.isLeft) {
        log(respon.left.message.toString());
        log(respon.left.key.toString());
        leaveListFetchState = AppStates.Error;
      } else {
        if (respon.right["status"] == true) {
          leaveListFetchState = AppStates.Fetched;

          //  showToast(respon.right.message);
          log(respon.right.toString());
          leaveList = List<LeaveListModel>.from(
            respon.right["data"].map((x) => LeaveListModel.fromJson(x)),
          );
        } else {
          error = respon.right["message"];
          notifyListeners();
          leaveListFetchState = AppStates.Error;
        }
      }
    }
    notifyListeners();
  }

  Future<void> getLeaveReaonsList() async {
    leaveReasonList.clear();
    error = "";
    leaveReasonFetchState = AppStates.Initial_Fetching;
    bool hasInternet = await InternetConnectivity().hasInternetConnection;

    if (!hasInternet) {
      leaveListFetchState = AppStates.NoInterNetConnectionState;
    } else {
      var respon = await repository.getLeaveResonList();
      if (respon.isLeft) {
        log(respon.left.message.toString());
        log(respon.left.key.toString());
        leaveReasonFetchState = AppStates.Error;
      } else {
        if (respon.right["status"] == true) {
          leaveReasonFetchState = AppStates.Fetched;
          //  showToast(respon.right.message);
          log(respon.right.toString());
          leaveReasonList = List<Grade>.from(
            respon.right["data"].map((x) => Grade.fromJson(x)),
          );
        } else {
          leaveReasonFetchState = AppStates.Error;
        }
      }
    }
    notifyListeners();
  }

  void updateLeaveReson(reason) {
    selectedLeaveReasonModel = reason;
    notifyListeners();
  }

  void updateLeaveState(state) {
    applyLeaveState = state;
    notifyListeners();
  }
}

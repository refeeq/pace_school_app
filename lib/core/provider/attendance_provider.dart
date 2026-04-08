import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:observe_internet_connectivity/observe_internet_connectivity.dart';
import 'package:school_app/core/config/app_status.dart';
import 'package:school_app/core/models/attendance_response_model.dart';
import 'package:school_app/core/models/students_model.dart';
import 'package:school_app/core/repository/attendance/repository.dart';
import 'package:school_app/core/services/dependecyInjection.dart';
import 'package:school_app/core/utils/utils.dart';

import '../../views/components/calender/neat_and_clean_calendar_event.dart';

class AttendenceProvider with ChangeNotifier {
  int valu = 0;
  AttendanceRepository repository = locator<AttendanceRepository>();

  AppStates attendanceListState = AppStates.Unintialized;
  List<NeatCleanCalendarEvent> eventList = [];
  AttendanceResponseModel? attendanceResponseModel;
  StudentModel? studentModel;
  bool load = false;
  int selectedMonth = 0;

  /// Clears all cached user data. Call on logout.
  void clearOnLogout() {
    eventList = [];
    attendanceResponseModel = null;
    studentModel = null;
    attendanceListState = AppStates.Unintialized;
    selectedMonth = 0;
    notifyListeners();
  }

  void changeMonthe(int month) {
    if (month > 0 && month <= 11) {
      selectedMonth = month;
    } else if (month > 11) {
      selectedMonth = 0;
    } else {
      selectedMonth = 11;
    }

    notifyListeners();
  }

  Future<void> getAttendanceList({
    required String month,
    required String year,
    required String studentId,
    required BuildContext context,
  }) async {
    eventList.clear();
    attendanceListState = AppStates.Initial_Fetching;
    bool hasInternet = await InternetConnectivity().hasInternetConnection;
    notifyListeners();
    if (!hasInternet) {
      attendanceListState = AppStates.NoInterNetConnectionState;
    } else {
      var respon = await repository.getAttendance(
        month: month,
        year: year,
        studentId: studentId,
      );
      if (respon.isLeft) {
        log(respon.left.message.toString());
        log(respon.left.key.toString());
        if (context.mounted) {
          showToast(respon.left.message.toString(), context);
        }
        attendanceListState = AppStates.Error;
      } else {
        if (respon.right['status'] == true) {
          attendanceListState = AppStates.Fetched;

          for (var element in AttendanceResponseModel.fromJson(
            respon.right,
          ).data) {
            eventList.add(
              NeatCleanCalendarEvent(
                element.remark,
                startTime: element.fromDate,
                endTime: element.toDate,
                color: element.color == ''
                    ? Colors.transparent
                    : HexColor(element.color),
                isAllDay: true,
              ),
            );
          }
          //  showToast(respon.right.message);
          log(respon.right.toString());
          attendanceResponseModel = AttendanceResponseModel.fromJson(
            respon.right,
          );
        }
      }
    }
    notifyListeners();
  }

  void updateIndex(int newVal) {
    valu = newVal;
    notifyListeners();
  }
}

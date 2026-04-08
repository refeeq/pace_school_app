import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:observe_internet_connectivity/observe_internet_connectivity.dart';
import 'package:school_app/core/config/app_status.dart';
import 'package:school_app/core/models/circular_list_model.dart';
import 'package:school_app/core/models/students_model.dart';
import 'package:school_app/core/repository/circular/repository.dart';
import 'package:school_app/core/services/dependecyInjection.dart';

class CircularProvider with ChangeNotifier {
  CircularRepository repository = locator<CircularRepository>();
  AppStates circularListState = AppStates.Unintialized;

  AppStates parentCircularListState = AppStates.Unintialized;
  StudentModel? studentModel;
  List<CircularModel>? circularListModel;
  List<CircularModel>? parentCircularList;

  /// Error message when circular list cannot be shown (e.g. inactive student).
  String? circularListMessage;

  /// Clears all cached user data. Call on logout.
  void clearOnLogout() {
    circularListState = AppStates.Unintialized;
    parentCircularListState = AppStates.Unintialized;
    studentModel = null;
    circularListModel = null;
    parentCircularList = null;
    circularListMessage = null;
    notifyListeners();
  }

  static const String _notActiveMessage =
      'Circulars are not available. This student is not active.';

  /// Returns true only when statusLabel is exactly "Active" (case insensitive).
  static bool _isActiveStatus(String? label) {
    if (label == null || label.isEmpty) return false;
    return label.toLowerCase().trim() == 'active';
  }

  Future<void> getCircularList({String? studCode}) async {
    circularListState = AppStates.Initial_Fetching;
    circularListMessage = null;
    bool hasInternet = await InternetConnectivity().hasInternetConnection;
    notifyListeners();
    studentModel = null;
    if (!hasInternet) {
      circularListState = AppStates.NoInterNetConnectionState;
    } else {
      var respon = await repository.getCircular(studCode: studCode);
      if (respon.isLeft) {
        log(respon.left.message.toString());
        log(respon.left.key.toString());
        circularListState = AppStates.Error;
      } else {
        circularListState = AppStates.Fetched;
        //  showToast(respon.right.message);
        log('studentCircular response fetched successfully');
        final rawData = respon.right["data"];
        final rawStudentDetails = respon.right["studentDetails"];
        List<CircularModel> list = [];
        if (rawData is List) {
          list = List<CircularModel>.from(
            rawData.map((x) => x is Map<String, dynamic>
                ? CircularModel.fromJson(x)
                : null).whereType<CircularModel>(),
          );
        }
        circularListModel = list;
        studentModel = rawStudentDetails is Map<String, dynamic>
            ? StudentModel.fromJson(rawStudentDetails)
            : null;
      }
    }
    notifyListeners();
  }

  Future<void> getParentCircularList() async {
    parentCircularListState = AppStates.Initial_Fetching;
    bool hasInternet = await InternetConnectivity().hasInternetConnection;

    if (!hasInternet) {
      parentCircularListState = AppStates.NoInterNetConnectionState;
    } else {
      var respon = await repository.getParentCircular();
      if (respon.isLeft) {
        log(respon.left.message.toString());
        log(respon.left.key.toString());
        parentCircularListState = AppStates.Error;
      } else {
        parentCircularListState = AppStates.Fetched;
        // showToast(respon.right.message);

        parentCircularList = respon.right;
      }
    }
    notifyListeners();
  }
}

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

  Future<void> getCircularList({String? studCode}) async {
    circularListState = AppStates.Initial_Fetching;
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
        log("response${respon.right}");
        List<CircularModel> list = List<CircularModel>.from(
          respon.right["data"].map((x) => CircularModel.fromJson(x)),
        );
        circularListModel = list;
        studentModel = StudentModel.fromJson(respon.right["studentDetails"]);
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

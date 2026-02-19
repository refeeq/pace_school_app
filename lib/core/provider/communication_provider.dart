import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:observe_internet_connectivity/observe_internet_connectivity.dart';
import 'package:school_app/core/config/app_status.dart';
import 'package:school_app/core/models/communicatio_tile_model.dart';
import 'package:school_app/core/models/communication_detail_model.dart';
import 'package:school_app/core/models/communication_student_model.dart';
import 'package:school_app/core/models/students_model.dart';
import 'package:school_app/core/repository/communication/repository.dart';
import 'package:school_app/core/services/dependecyInjection.dart';

class CommunicationProvider with ChangeNotifier {
  final CommunicationRepository repository = locator<CommunicationRepository>();
  StudentModel? studentModel;
  AppStates studentListState = AppStates.Unintialized;
  List<CommunicationStudentModel> communicationStudentList = [];
  AppStates communicationListState = AppStates.Unintialized;

  List<CommunicationTileModel> communicationList = [];

  DataState communicationDetailState = DataState.Uninitialized;
  List<CommunicationDetailModel> communicationDetailList = [];
  int _currentPageNumber = 0; // Current Page to get Data from API

  int count = 0;
  bool _didLastLoad =
      false; // Property through which we can check if last page have been loaded from API or not
  /// Clears all cached user data. Call on logout.
  void clearOnLogout() {
    studentModel = null;
    studentListState = AppStates.Unintialized;
    communicationStudentList = [];
    communicationListState = AppStates.Unintialized;
    communicationList = [];
    communicationDetailState = DataState.Uninitialized;
    communicationDetailList = [];
    _currentPageNumber = 0;
    _didLastLoad = false;
    notifyListeners();
  }

  Future<void> getCommunicationDetailList(
    String studentId,
    String type, {
    bool isRefresh = false,
  }) async {
    count++;
    log("getCommunicationDetailList $count");
    if (!isRefresh) {
      communicationDetailState =
          (communicationDetailState == DataState.Uninitialized)
          ? DataState.Initial_Fetching
          : DataState.More_Fetching;
    } else {
      communicationDetailList.clear();
      _currentPageNumber = 0;
      _didLastLoad = false;
      communicationDetailState = DataState.Initial_Fetching;
    }
    notifyListeners();
    if (_didLastLoad) {
      communicationDetailState = DataState.No_More_Data;
    } else {
      var respon = await repository.getCommunicationDetails(
        studentId,
        type,
        _currentPageNumber,
      );
      if (respon.isLeft) {
        log(respon.left.message.toString());
        log(respon.left.key.toString());
        communicationDetailState = DataState.Error;
      } else {
        // log("Communication Response\n${respon.right}");
        log('getCommunicationsBifur response fetched successfully');
        if (respon.right['status'] == true) {
          communicationDetailState = DataState.Fetched;
          //   showToast(respon.right.message);
          // log(respon.right.toString());
          List<CommunicationDetailModel> list =
              List<CommunicationDetailModel>.from(
                respon.right["data"].map(
                  (x) => CommunicationDetailModel.fromJson(x),
                ),
              );
          log("getCommunicationDetailList length ${list.length}");
          if (communicationDetailList.isEmpty && list.isEmpty) {
            communicationDetailList = [];
          } else if (list.isEmpty) {
            _didLastLoad = true;
          } else {
            communicationDetailList += list;

            _currentPageNumber += 1;
          }
        } else {
          communicationDetailList = [];
        }
      }
    }
    notifyListeners();
  }

  Future<void> getCommunicationList(String studentId) async {
    studentModel = null;
    communicationList = [];

    communicationListState = AppStates.Initial_Fetching;
    bool hasInternet = await InternetConnectivity().hasInternetConnection;
    notifyListeners();
    if (!hasInternet) {
      communicationListState = AppStates.NoInterNetConnectionState;
    } else {
      var respon = await repository.getCommunicationTileList(studentId);
      if (respon.isLeft) {
        log(respon.left.message.toString());
        log(respon.left.key.toString());
        communicationListState = AppStates.Error;
      } else {
        if (respon.right['status'] == true) {
          studentModel = StudentModel.fromJson(respon.right["studentDetails"]);
          communicationListState = AppStates.Fetched;

          //   showToast(respon.right.message);
          log('getCommunications response fetched successfully');
          communicationList = List<CommunicationTileModel>.from(
            respon.right["data"].map((x) => CommunicationTileModel.fromJson(x)),
          );
        } else {
          communicationStudentList = [];
        }
      }
    }
    notifyListeners();
  }

  Future<void> getStudentList() async {
    communicationStudentList.clear();
    studentListState = AppStates.Initial_Fetching;
    bool hasInternet = await InternetConnectivity().hasInternetConnection;
    //studentModel = null;
    if (!hasInternet) {
      studentListState = AppStates.NoInterNetConnectionState;
    } else {
      var respon = await repository.getStudentList();
      if (respon.isLeft) {
        log(respon.left.message.toString());
        log(respon.left.key.toString());
        studentListState = AppStates.Error;
      } else {
        if (respon.right['status'] == true) {
          studentListState = AppStates.Fetched;
          await Hive.box('communication').clear();

          await Hive.box("communication").put("count", respon.right['count']);
          //   showToast(respon.right.message);
          log('getCommunicationStudentList response fetched successfully');
          communicationStudentList = List<CommunicationStudentModel>.from(
            respon.right["data"].map(
              (x) => CommunicationStudentModel.fromJson(x),
            ),
          );
        } else {
          communicationStudentList = [];
          studentListState = AppStates.Fetched;
        }
      }
    }
    notifyListeners();
  }

  Future<void> getStudentListNew() async {
    var respon = await repository.getStudentList();
    if (respon.right['status'] == true) {
      // studentListState = AppStates.Fetched;
      await Hive.box('communication').clear();

      await Hive.box("communication").put("count", respon.right['count']);
      //   showToast(respon.right.message);
      log('getCommunicationStudentList response fetched successfully');
      communicationStudentList = List<CommunicationStudentModel>.from(
        respon.right["data"].map((x) => CommunicationStudentModel.fromJson(x)),
      );
    }
    notifyListeners();
  }
}

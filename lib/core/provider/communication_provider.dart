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

  bool _didLastLoad =
      false; // Property through which we can check if last page have been loaded from API or not

  /// Prevents overlapping detail API calls when scroll notifications fire repeatedly at max extent.
  bool _communicationDetailFetchInFlight = false;

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
    _communicationDetailFetchInFlight = false;
    notifyListeners();
  }

  Future<void> getCommunicationDetailList(
    String studentId,
    String type, {
    bool isRefresh = false,
  }) async {
    if (_communicationDetailFetchInFlight) {
      log(
        '[Communication] detail: skipped fetch — request already in flight '
        '(studcode=$studentId tileId=$type)',
      );
      return;
    }

    if (!isRefresh && _didLastLoad) {
      log(
        '[Communication] detail: skipped fetch — no more pages '
        '(studcode=$studentId tileId=$type)',
      );
      communicationDetailState = DataState.No_More_Data;
      notifyListeners();
      return;
    }

    if (isRefresh) {
      communicationDetailList.clear();
      _currentPageNumber = 0;
      _didLastLoad = false;
      communicationDetailState = DataState.Initial_Fetching;
    } else {
      communicationDetailState =
          (communicationDetailState == DataState.Uninitialized)
          ? DataState.Initial_Fetching
          : DataState.More_Fetching;
    }

    final mode = isRefresh ? 'refresh' : 'pagination';
    final pageForApi = _currentPageNumber;

    notifyListeners();

    if (_didLastLoad) {
      log(
        '[Communication] detail: skipped fetch — no more pages '
        '(studcode=$studentId tileId=$type)',
      );
      communicationDetailState = DataState.No_More_Data;
      notifyListeners();
      return;
    }

    log(
      '[Communication] detail: requesting messages → '
      'mode=$mode pageNo=$pageForApi '
      '(maps to API field pageNo) '
      'tileId=$type studcode=$studentId',
    );

    _communicationDetailFetchInFlight = true;
    try {
      var respon = await repository.getCommunicationDetails(
        studentId,
        type,
        pageForApi,
      );
      if (respon.isLeft) {
        log(
          '[Communication] detail: request failed — '
          '${respon.left.message ?? "no message"} (${respon.left.key})',
        );
        communicationDetailState = DataState.Error;
      } else {
        if (respon.right['status'] == true) {
          communicationDetailState = DataState.Fetched;
          List<CommunicationDetailModel> list =
              List<CommunicationDetailModel>.from(
                respon.right["data"].map(
                  (x) => CommunicationDetailModel.fromJson(x),
                ),
              );
          if (communicationDetailList.isEmpty && list.isEmpty) {
            communicationDetailList = [];
            log(
              '[Communication] detail: response OK — empty thread '
              '(studcode=$studentId tileId=$type)',
            );
          } else if (list.isEmpty) {
            _didLastLoad = true;
            log(
              '[Communication] detail: response OK — empty page; '
              'no older messages (studcode=$studentId tileId=$type)',
            );
          } else {
            communicationDetailList += list;
            _currentPageNumber += 1;
            log(
              '[Communication] detail: response OK — '
              '+${list.length} message(s), '
              'total loaded=${communicationDetailList.length}, '
              'next pageNo will be $_currentPageNumber',
            );
          }
        } else {
          communicationDetailList = [];
          log(
            '[Communication] detail: response status=false '
            '(studcode=$studentId tileId=$type)',
          );
        }
      }
    } finally {
      _communicationDetailFetchInFlight = false;
      notifyListeners();
    }
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

  /// Set unread count for a given student locally (used to keep avatar badge in sync with tiles).
  void setStudentUnread(String studentId, int unread) {
    final index = communicationStudentList.indexWhere(
      (s) => s.studcode == studentId,
    );
    if (index == -1) return;

    final current = communicationStudentList[index];
    final clampedUnread = unread.clamp(0, 9999);

    communicationStudentList[index] = CommunicationStudentModel(
      studcode: current.studcode,
      fullname: current.fullname,
      communicationStudentModelClass: current.communicationStudentModelClass,
      section: current.section,
      studStat: current.studStat,
      acdyear: current.acdyear,
      acYearId: current.acYearId,
      photo: current.photo,
      unread: clampedUnread,
      lastMessage: current.lastMessage,
    );
    notifyListeners();
  }
}

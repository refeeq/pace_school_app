// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:observe_internet_connectivity/observe_internet_connectivity.dart';
import 'package:school_app/core/config/app_status.dart';
import 'package:school_app/core/models/common_res_model.dart';
import 'package:school_app/core/models/exam_report_model.dart';
import 'package:school_app/core/models/student_detail_model.dart';
import 'package:school_app/core/models/student_menu_model.dart';
import 'package:school_app/core/models/students_model.dart';
import 'package:school_app/core/repository/student/repository.dart';
import 'package:school_app/core/services/dependecyInjection.dart';
import 'package:school_app/core/utils/utils.dart';

enum PageControllerState {
  NoNeedPageController,
  PageControllerNeeded,
  Uninitialized,
}

class StudentProvider with ChangeNotifier {
  StudentRepository repository = locator<StudentRepository>();
  StudentModel? _selectedStudentModel;
  StudentsModel? studentsModel;
  String studID = '';
  AppStates studentListState = AppStates.Unintialized;
  StudentDetailModel? studentDetailModel;
  AppStates studentDetail = AppStates.Unintialized;

  StudentMenuModel? studentMenuModel;
  AppStates studentMenu = AppStates.Unintialized;
  AppStates progressReportState = AppStates.Unintialized;
  PageController pageController = PageController(initialPage: 0);
  ExamReportModel expamReportModel = ExamReportModel(
    status: AppStates.Unintialized,
  );
  CommonResModel progressReport = CommonResModel(
    status: AppStates.Unintialized,
  );
  PageControllerState pageControllerState = PageControllerState.Uninitialized;
  AppStates updateStudentDocState = AppStates.Unintialized;

  Future<void> getProgressReport(String stdCode, examId, accId) async {
    progressReport = CommonResModel(status: AppStates.Initial_Fetching);
    bool hasInternet = await InternetConnectivity().hasInternetConnection;
    if (!hasInternet) {
      expamReportModel = ExamReportModel(
        status: AppStates.NoInterNetConnectionState,
      );
    } else {
      var respon = await repository.progressReport(
        studCode: stdCode,
        examId: examId,
        accId: accId,
      );
      if (respon.isLeft) {
        log(respon.left.message.toString());
        log(respon.left.key.toString());

        progressReport = CommonResModel(
          status: AppStates.Error,
          message: respon.left.message.toString(),
        );
      } else {
        log("Progress Report Provider - Response type: ${respon.right.runtimeType}");
        log("Progress Report Provider - Response: ${respon.right}");
        final dataForUi = respon.right.toString();
        log("Progress Report Provider - Data passed to UI (length: ${dataForUi.length}): ${dataForUi.length > 500 ? '${dataForUi.substring(0, 500)}...' : dataForUi}");
        progressReport = CommonResModel(
          status: AppStates.Fetched,
          data: dataForUi,
        );
        // if (respon.right['status'] == true) {
        //   log("###############################");

        //   var htmlContent = jsonDecode(respon.right)["data"];
        //   log("###############################");
        //   log(htmlContent.toString());

        //   //  showToast(respon.right.message);

        //   notifyListeners();
        // } else {
        //   progressReport = CommonResModel(
        //       status: AppStates.Error, message: respon.right['message']);
        // }
      }
    }
    notifyListeners();
  }

  Future<void> getProgressReportExams(String stdCode) async {
    expamReportModel = ExamReportModel(status: AppStates.Initial_Fetching);
    bool hasInternet = await InternetConnectivity().hasInternetConnection;
    if (!hasInternet) {
      expamReportModel = ExamReportModel(
        status: AppStates.NoInterNetConnectionState,
      );
    } else {
      var respon = await repository.getProgressReport(studCode: stdCode);
      if (respon.isLeft) {
        log(respon.left.message.toString());
        log(respon.left.key.toString());

        expamReportModel = ExamReportModel(
          status: AppStates.Error,
          message: respon.left.message.toString(),
        );
      } else {
        if (jsonDecode(respon.right)['status'] == true) {
          log("###############################");
          log("${jsonDecode(respon.right)["data"]}");
          expamReportModel = ExamReportModel(
            status: AppStates.Fetched,
            data: List<ExamReport>.from(
              (jsonDecode(respon.right)["data"] as List<dynamic>).map(
                (x) => ExamReport.fromJson(x),
              ),
            ),
          );
          //  showToast(respon.right.message);

          notifyListeners();
        } else {
          expamReportModel = ExamReportModel(
            status: AppStates.Error,
            message: jsonDecode(respon.right)['message'],
          );
        }
      }
    }
    notifyListeners();
  }

  Future<void> getStudentDetail({required String studCode}) async {
    studentDetail = AppStates.Initial_Fetching;
    studentDetailModel = null;
    // notifyListeners();
    bool hasInternet = await InternetConnectivity().hasInternetConnection;

    if (!hasInternet) {
      studentDetail = AppStates.NoInterNetConnectionState;
    } else {
      notifyListeners();
      var respon = await repository.getStudentDetails(studCode: studCode);
      if (respon.isLeft) {
        log(respon.left.message.toString());
        log(respon.left.key.toString());

        studentDetail = AppStates.Error;
      } else {
        if (respon.right.status == true) {
          studentDetail = AppStates.Fetched;
          //  showToast(respon.right.message);
          log(respon.right.data.toString());
          studentDetailModel = respon.right;
        }
      }
    }
    notifyListeners();
  }

  Future<void> getStudentMenu({required String studcode}) async {
    studentMenu = AppStates.Initial_Fetching;
    bool hasInternet = await InternetConnectivity().hasInternetConnection;

    if (!hasInternet) {
      studentMenu = AppStates.NoInterNetConnectionState;
    } else {
      notifyListeners();
      var respon = await repository.getStudentMenu(studCode: studcode);
      if (respon.isLeft) {
        log(respon.left.message.toString());
        log(respon.left.key.toString());
        studentMenu = AppStates.Error;
      } else {
        if (respon.right.status == true) {
          studentMenu = AppStates.Fetched;
          //   showToast(respon.right.message);
          log(respon.right.data.toString());
          studentMenuModel = respon.right;
        }
      }
    }
    notifyListeners();
  }

  Future<void> getStudents() async {
    studentListState = AppStates.Initial_Fetching;
    bool hasInternet = await InternetConnectivity().hasInternetConnection;

    if (!hasInternet) {
      studentListState = AppStates.NoInterNetConnectionState;
    } else {
      var respon = await repository.getStudents();
      if (respon.isLeft) {
        log(respon.left.message.toString());
        log(respon.left.key.toString());

        studentListState = AppStates.Error;
      } else {
        if (respon.right.status == true) {
          studentListState = AppStates.Fetched;

          log(respon.right.data.toString());
          studentsModel = respon.right;
        }
      }
    }
    notifyListeners();
  }

  void resetUpdateStudentDocState({bool notify = true}) {
    updateStudentDocState = AppStates.Unintialized;
    if (notify) notifyListeners();
  }

  StudentModel selectedStudentModel(BuildContext) {
    print("Student ID $studID");
    if (studID.isNotEmpty) {
      if (studentsModel == null) {
        getStudents();
        Future.delayed(const Duration(seconds: 2));
      }

      for (var element in studentsModel!.data) {
        if (element.studcode == studID) {
          _selectedStudentModel = element;
        }
      }
      studID = "";
      return _selectedStudentModel!;
    } else {
      return _selectedStudentModel ?? studentsModel!.data[0];
    }
  }

  void selectStudent(
    StudentModel studentModel, {
    int? index,
    PageControllerState select = PageControllerState.NoNeedPageController,
  }) {
    // pageControllerState = select;
    // if (select == PageControllerState.NoNeedPageController) {
    //   if (index != null) {
    //     pageController.jumpToPage(index);
    //   } else {}
    // }
    _selectedStudentModel = studentModel;
    notifyListeners();
  }

  void selectStudentWithStudId(String studId) {
    studID = studId;

    notifyListeners();
  }

  Future<bool> updateStudentDocumentDetails({
    required String studCode,
    required String emiratesId,
    required String emiratesIdExp,
    required BuildContext context,
  }) async {
    updateStudentDocState = AppStates.Initial_Fetching;
    notifyListeners();

    bool hasInternet = await InternetConnectivity().hasInternetConnection;
    if (!hasInternet) {
      updateStudentDocState = AppStates.NoInterNetConnectionState;
      notifyListeners();
      showToast("No internet connection!", context, type: ToastType.error);
      return false;
    }

    final respon = await repository.updateStudentDocumentDetails(
      studCode: studCode,
      emiratesId: emiratesId,
      emiratesIdExp: emiratesIdExp,
    );

    if (respon.isLeft) {
      log(respon.left.message.toString());
      log(respon.left.key.toString());
      updateStudentDocState = AppStates.Error;
      showToast(respon.left.message ?? "Failed to update details", context, type: ToastType.error);
      notifyListeners();
      return false;
    } else {
      final data = respon.right;
      if (data['status'] == true) {
        updateStudentDocState = AppStates.Fetched;
        showToast(data["message"].toString(), context, type: ToastType.success);
        await getStudentDetail(studCode: studCode);
        notifyListeners();
        return true;
      } else {
        updateStudentDocState = AppStates.Error;
        showToast(data["message"].toString(), context, type: ToastType.error);
        notifyListeners();
        return false;
      }
    }
  }
}

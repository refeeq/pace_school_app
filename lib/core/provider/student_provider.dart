// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:school_app/core/utils/platform_check.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:observe_internet_connectivity/observe_internet_connectivity.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:school_app/core/config/app_status.dart';
import 'package:school_app/core/models/common_res_model.dart';
import 'package:school_app/core/models/exam_report_model.dart';
import 'package:school_app/core/models/report_card_model.dart';
import 'package:school_app/core/models/student_detail_model.dart';
import 'package:school_app/core/models/student_menu_model.dart';
import 'package:school_app/core/models/students_model.dart';
import 'package:school_app/core/notification/fcm_topic_service.dart';
import 'package:school_app/core/repository/student/repository.dart';
import 'package:school_app/core/services/dependecyInjection.dart';
import 'package:school_app/core/utils/error_message_utils.dart';
import 'package:school_app/core/utils/utils.dart';

/// Represents a document expiry warning for a student.
class DocumentWarning {
  final String studentName;
  final String studentCode;
  final String documentType;
  final String expiryDate;
  final DocumentExpiryStatus status;

  DocumentWarning({
    required this.studentName,
    required this.studentCode,
    required this.documentType,
    required this.expiryDate,
    required this.status,
  });
}

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
  ReportNamesResponse? reportNamesData;
  AppStates reportNamesState = AppStates.Unintialized;
  CommonResModel reportCardHtml = CommonResModel(
    status: AppStates.Unintialized,
  );
  PageControllerState pageControllerState = PageControllerState.Uninitialized;
  AppStates updateStudentDocState = AppStates.Unintialized;

  List<DocumentWarning> documentWarnings = [];
  bool _documentWarningsFetched = false;
  bool _documentWarningsFetching = false;

  /// True when backend requires a newer app version and the user must update.
  bool _updateRequired = false;
  bool get updateRequired => _updateRequired;

  /// Version requirements from the last getStudents response (when update is required).
  AppVersionData? _appVersionData;
  AppVersionData? get appVersionData => _appVersionData;

  Future<void> fetchDocumentWarningsForAllStudents() async {
    if (studentsModel == null ||
        studentsModel!.data.isEmpty ||
        _documentWarningsFetched ||
        _documentWarningsFetching) {
      return;
    }
    _documentWarningsFetching = true;
    try {
      final warnings = <DocumentWarning>[];
      final students = studentsModel!.data;
      final results = await Future.wait(
        students.map((s) => repository.getStudentDetails(studCode: s.studcode)),
      );
      for (var i = 0; i < results.length; i++) {
        final respon = results[i];
        if (respon.isRight && respon.right.status == true) {
          final data = respon.right.data;
          final studentName = data.fullname;
          final studCode = data.studcode;

          void checkDocument(String dateStr, String docType) {
            if (dateStr.isEmpty) return;
            final status = getDocumentExpiryStatus(dateStr);
            if (status == DocumentExpiryStatus.expired ||
                status == DocumentExpiryStatus.expiringSoon) {
              warnings.add(DocumentWarning(
                studentName: studentName,
                studentCode: studCode,
                documentType: docType,
                expiryDate: dateStr,
                status: status,
              ));
            }
          }

          checkDocument(data.emiratesIdExp, 'Emirates ID');
          checkDocument(data.ppExpDate, 'Passport');
        }
      }
      documentWarnings = warnings;
      _documentWarningsFetched = true;
      Hive.box('documentExpiry').put('count', warnings.length);
      notifyListeners();
    } finally {
      _documentWarningsFetching = false;
    }
  }

  void resetDocumentWarningsFetch() {
    _documentWarningsFetched = false;
  }

  /// Clears all cached user data. Call on logout.
  void clearOnLogout() {
    _selectedStudentModel = null;
    studentsModel = null;
    studID = '';
    studentListState = AppStates.Unintialized;
    studentDetailModel = null;
    studentDetail = AppStates.Unintialized;
    studentMenuModel = null;
    studentMenu = AppStates.Unintialized;
    progressReportState = AppStates.Unintialized;
    expamReportModel = ExamReportModel(status: AppStates.Unintialized);
    progressReport = CommonResModel(status: AppStates.Unintialized);
    reportNamesData = null;
    reportNamesState = AppStates.Unintialized;
    reportCardHtml = CommonResModel(status: AppStates.Unintialized);
    documentWarnings = [];
    _documentWarningsFetched = false;
    _documentWarningsFetching = false;
    _updateRequired = false;
    _appVersionData = null;
    notifyListeners();
  }

  /// Compares two semantic version strings (e.g. "1.1.12" vs "1.1.13").
  /// Returns -1 if v1 < v2, 0 if equal, 1 if v1 > v2. On parse error returns 0.
  static int _compareVersions(String v1, String v2) {
    try {
      final a = v1.split('.').map((e) => int.tryParse(e.trim()) ?? 0).toList();
      final b = v2.split('.').map((e) => int.tryParse(e.trim()) ?? 0).toList();
      final len = a.length > b.length ? a.length : b.length;
      for (int i = 0; i < len; i++) {
        final na = i < a.length ? a[i] : 0;
        final nb = i < b.length ? b[i] : 0;
        if (na < nb) return -1;
        if (na > nb) return 1;
      }
      return 0;
    } catch (_) {
      return 0;
    }
  }

  /// Returns true if the current app version is below the required minimum.
  /// Compares version number first, then build number if versions are equal.
  /// On any error (missing data, parse, platform) returns false so the app is not blocked.
  Future<bool> _isUpdateRequired(AppVersionData? versionData) async {
    log('[FORCE_UPDATE] Starting version check...');
    if (versionData == null) {
      log('[FORCE_UPDATE] No version data received from backend');
      return false;
    }
    try {
      if (!isIOS && !isAndroid) {
        log('[FORCE_UPDATE] Not on mobile platform (web/desktop) - skipping check');
        return false;
      }
      final platform = isIOS ? 'iOS' : 'Android';
      log('[FORCE_UPDATE] Platform detected: $platform');
      
      final info = await PackageInfo.fromPlatform();
      final currentVersion = info.version.trim();
      final currentBuildStr = info.buildNumber.trim();
      final currentBuild = int.tryParse(currentBuildStr) ?? 0;
      
      if (currentVersion.isEmpty) {
        log('[FORCE_UPDATE] ❌ Current app version is empty - cannot compare');
        return false;
      }
      
      log('[FORCE_UPDATE] Current app version: $currentVersion (build: $currentBuild)');
      
      final min = isIOS ? versionData.ios : versionData.android;
      log('[FORCE_UPDATE] Minimum required - Version: ${min.minimumVersion}, Build: ${min.minimumBuild}');
      
      if (min.minimumVersion.isEmpty) {
        log('[FORCE_UPDATE] Minimum version is empty - update not required');
        return false;
      }
      
      // Compare version number first
      try {
        final cmp = _compareVersions(currentVersion, min.minimumVersion);
        log('[FORCE_UPDATE] Version comparison result: $cmp (negative=current lower, 0=equal, positive=current higher)');
        
        if (cmp < 0) {
          log('[FORCE_UPDATE] ✅ UPDATE REQUIRED: Current version ($currentVersion) is lower than minimum ($min.minimumVersion)');
          return true;
        }
        if (cmp > 0) {
          log('[FORCE_UPDATE] ✅ No update needed: Current version ($currentVersion) is higher than minimum ($min.minimumVersion)');
          return false;
        }
        
        // Versions are equal, check build number
        final buildUpdateRequired = currentBuild < min.minimumBuild;
        if (buildUpdateRequired) {
          log('[FORCE_UPDATE] ✅ UPDATE REQUIRED: Current build ($currentBuild) is lower than minimum ($min.minimumBuild)');
        } else {
          log('[FORCE_UPDATE] ✅ No update needed: Current build ($currentBuild) meets minimum ($min.minimumBuild)');
        }
        return buildUpdateRequired;
      } catch (e) {
        log('[FORCE_UPDATE] ❌ Error comparing versions: $e');
        return false; // On comparison error, allow app access
      }
    } catch (e) {
      log('[FORCE_UPDATE] ❌ Error during version check: $e');
      return false;
    }
  }

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
        // log("Progress Report Provider - Response type: ${respon.right.runtimeType}");
        // log("Progress Report Provider - Response: ${respon.right}");
        log('progress report response fetched successfully');
        final dataForUi = respon.right.toString();
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

  Future<void> getReportNamesByClass(String admissionNo) async {
    reportNamesState = AppStates.Initial_Fetching;
    reportNamesData = null;
    notifyListeners();

    bool hasInternet = await InternetConnectivity().hasInternetConnection;
    if (!hasInternet) {
      log('[getReportNamesByClass] No internet connection');
      reportNamesState = AppStates.NoInterNetConnectionState;
    } else {
      var respon = await repository.getReportNamesByClass(admissionNo: admissionNo);
      if (respon.isLeft) {
        log('[getReportNamesByClass] Provider: repository returned Left - ${respon.left.message}');
        reportNamesState = AppStates.Error;
        reportNamesData = null;
      } else {
        dynamic raw = respon.right;
        log('[getReportNamesByClass] Provider: raw type=${raw.runtimeType}, raw=$raw');
        if (raw is String) {
          try {
            raw = jsonDecode(raw);
            log('[getReportNamesByClass] Provider: parsed JSON string, raw=$raw');
          } catch (e) {
            log('[getReportNamesByClass] Provider: ERROR - failed to parse JSON: $e');
            reportNamesState = AppStates.Error;
            reportNamesData = null;
            notifyListeners();
            return;
          }
        }
        if (raw is Map<String, dynamic>) {
          final status = raw['status'];
          log('[getReportNamesByClass] Provider: status=$status (type=${status.runtimeType})');
          if (status == true) {
            final data = raw['data'];
            log('[getReportNamesByClass] Provider: data type=${data?.runtimeType}, data=$data');
            if (data is Map<String, dynamic>) {
              reportNamesData = ReportNamesResponse.fromJson(data);
              reportNamesState = AppStates.Fetched;
              log('[getReportNamesByClass] Provider: success, reports=${reportNamesData?.reports.length ?? 0}');
            } else {
              log('[getReportNamesByClass] Provider: ERROR - data is not Map, data=$data');
              reportNamesState = AppStates.Error;
              reportNamesData = null;
            }
          } else {
            log('[getReportNamesByClass] Provider: ERROR - status != true, message=${raw['message']}');
            reportNamesState = AppStates.Error;
            reportNamesData = null;
          }
        } else {
          log('[getReportNamesByClass] Provider: ERROR - raw is not Map, raw=$raw');
          reportNamesState = AppStates.Error;
          reportNamesData = null;
        }
      }
    }
    notifyListeners();
  }

  Future<void> getReportCardHtml(String admissionNo, String reportId) async {
    reportCardHtml = CommonResModel(status: AppStates.Initial_Fetching);
    notifyListeners();

    bool hasInternet = await InternetConnectivity().hasInternetConnection;
    if (!hasInternet) {
      reportCardHtml = CommonResModel(
        status: AppStates.NoInterNetConnectionState,
      );
    } else {
      var respon = await repository.getReportCardHtml(
        admissionNo: admissionNo,
        reportId: reportId,
      );
      if (respon.isLeft) {
        log(respon.left.message.toString());
        reportCardHtml = CommonResModel(
          status: AppStates.Error,
          message: respon.left.message.toString(),
        );
      } else {
        final raw = respon.right;
        String? htmlContent;
        String? apiMessage;

        Map<String, dynamic>? parsed;
        if (raw is Map<String, dynamic>) {
          parsed = raw;
        } else if (raw is String && raw.trim().isNotEmpty) {
          if (raw.trim().startsWith('{')) {
            try {
              parsed = jsonDecode(raw) as Map<String, dynamic>?;
            } catch (_) {
              parsed = null;
            }
          } else {
            htmlContent = raw;
          }
        }

        if (parsed != null) {
          apiMessage = parsed['message']?.toString();
          if (parsed['status'] == true) {
            final data = parsed['data'];
            if (data is String && data.trim().isNotEmpty) {
              htmlContent = data;
            } else if (data is Map<String, dynamic>) {
              final html = data['html'];
              if (html is String && html.trim().isNotEmpty) {
                htmlContent = html;
              }
            }
          }
        }

        if (htmlContent != null && htmlContent.trim().isNotEmpty) {
          reportCardHtml = CommonResModel(
            status: AppStates.Fetched,
            data: htmlContent,
          );
        } else {
          reportCardHtml = CommonResModel(
            status: AppStates.Error,
            message: sanitizeErrorMessage(
              apiMessage,
              fallback: 'Unable to load the report card. Please try again.',
            ),
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

  Future<void> getStudents({bool forceRefresh = false}) async {
    // Avoid unnecessary API calls if data is already fetched and up to date
    if (!forceRefresh &&
        studentsModel != null &&
        studentListState == AppStates.Fetched) {
      return;
    }
    // Prevent concurrent fetches - another call is already in progress
    if (!forceRefresh && studentListState == AppStates.Initial_Fetching) {
      return;
    }

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
          
          // Check for app version requirements
          try {
            final versionData = respon.right.appVersion;
            _appVersionData = versionData;
            if (versionData != null) {
              log('[FORCE_UPDATE] 📦 Version data received from backend:');
              log('[FORCE_UPDATE]    iOS - Version: ${versionData.ios.minimumVersion}, Build: ${versionData.ios.minimumBuild}');
              log('[FORCE_UPDATE]    Android - Version: ${versionData.android.minimumVersion}, Build: ${versionData.android.minimumBuild}');
            } else {
              log('[FORCE_UPDATE] 📦 No version data in API response');
            }
            
            _updateRequired = await _isUpdateRequired(versionData);
            
            if (_updateRequired) {
              log('[FORCE_UPDATE] 🚨 FORCE UPDATE REQUIRED - Blocking app access');
            } else {
              log('[FORCE_UPDATE] ✅ App version is up to date - Proceeding normally');
            }
          } catch (e) {
            log('[FORCE_UPDATE] ❌ Error during version check process: $e');
            _updateRequired = false; // On error, allow app access
            _appVersionData = null;
          }

          if (!_updateRequired) {
            try {
              fetchDocumentWarningsForAllStudents();
              final topics = studentsModel?.topics ?? [];
              if (topics.isNotEmpty) {
                try {
                  await FcmTopicService.subscribeToTopics(topics);
                } catch (e) {
                  log('Error subscribing to FCM topics: $e');
                }
              }
            } catch (e) {
              log('[FORCE_UPDATE] Error in post-fetch operations: $e');
            }
          } else {
            log('[FORCE_UPDATE] ⏸️ Skipping FCM topics and document warnings (update required)');
          }
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

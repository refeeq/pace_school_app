import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:school_app/core/constants/api_constants.dart';
import 'package:school_app/core/constants/db_constants.dart';
import 'package:school_app/core/error/error_exception.dart';
import 'package:school_app/core/models/auth_model.dart';
import 'package:school_app/core/models/fee_response_model.dart';
import 'package:school_app/core/models/fees_list_model.dart';
import 'package:school_app/core/models/fees_model.dart';
import 'package:school_app/core/models/student_detail_model.dart';
import 'package:school_app/core/models/student_menu_model.dart';
import 'package:school_app/core/models/students_model.dart';
import 'package:school_app/core/repository/student/repository.dart';
import 'package:school_app/core/services/api_services.dart';
import 'package:school_app/core/utils/error_message_utils.dart';

class StudentRepositoryImpl implements StudentRepository {
  final DioAPIServices apiServices;

  StudentRepositoryImpl(this.apiServices);
  @override
  Future<Either<MyError, dynamic>> getProgressReport({
    required String studCode,
  }) async {
    var userData = Hive.box<AuthModel>(USERDB);
    userData.values;
    AuthModel authModel = userData.get(0) as AuthModel;
    var data = FormData.fromMap({
      "token": authModel.token,
      "famcode": authModel.famcode,
      "admission_no": studCode,
    });
    Dio dio = Dio();

    var response = await dio.post(
      ApiConstatns.availableProgrssReport,
      data: data,
    );
    log("response ${response.data}");
    return Right((response.data));
  }

  @override
  Future<Either<MyError, StudentDetailModel>> getStudentDetails({
    required String studCode,
  }) async {
    var userData = Hive.box<AuthModel>(USERDB);
    userData.values;
    AuthModel authModel = userData.get(0) as AuthModel;
    var data = FormData.fromMap({
      "token": authModel.token,
      "famcode": authModel.famcode,
      "admission_no": studCode,
    });
    var response = await apiServices.postAPI(
      url: ApiConstatns.getStudentProfile,
      body: data,
    );

    if (response.isLeft) {
      log(response.left.message!);
      return Left(response.left);
    } else {
      // log(response.right.toString());
      log('studentProfile response fetched successfully');
      return Right(StudentDetailModel.fromJson(response.right));
    }
  }

  @override
  Future<Either<MyError, FeeListModel>> getStudentFee({
    required String studCode,
  }) async {
    var userData = Hive.box<AuthModel>(USERDB);
    userData.values;
    AuthModel authModel = userData.get(0) as AuthModel;
    var data = FormData.fromMap({
      "token": authModel.token,
      "famcode": authModel.famcode,
      "admission_no": studCode,
    });
    var response = await apiServices.postAPI(
      url: ApiConstatns.getStudentFee,
      body: data,
    );

    if (response.isLeft) {
      log(response.left.message!);
      return Left(response.left);
    } else {
      log(response.right.toString());
      return Right(FeeListModel.fromJson(response.right));
    }
  }

  @override
  Future<Either<MyError, dynamic>> getStudentFeeStatement({
    required String studCode,
    required int limitTwo,
  }) async {
    var userData = Hive.box<AuthModel>(USERDB);
    userData.values;
    AuthModel authModel = userData.get(0) as AuthModel;
    var data = FormData.fromMap({
      "token": authModel.token,
      "famcode": authModel.famcode,
      "studcode": studCode,
      "pageNo": limitTwo,
    });
    var response = await apiServices.postAPI(
      url: ApiConstatns.studentFeeLedger,
      body: data,
    );

    if (response.isLeft) {
      log(response.left.message!);
      return Left(response.left);
    } else {
      if (response.right['status'] == false) {
        log(response.right['message']);
        return Right(response.right);
      } else {
        log(response.right.toString());

        return Right(response.right);
      }
    }
  }

  @override
  Future<Either<MyError, FeeResponseModel>> getStudentFeeSubmit({
    required String studCode,
    required List<FeesModel> list,
  }) async {
    var userData = Hive.box<AuthModel>(USERDB);
    userData.values;
    AuthModel authModel = userData.get(0) as AuthModel;
    var data = FormData.fromMap({
      "token": authModel.token,
      "famcode": authModel.famcode,
      "admission_no": studCode,
      "data": List<dynamic>.from(list.map((x) => x.toJson())),
    });
    var response = await apiServices.postAPI(
      url: ApiConstatns.studentFeeSubmit,
      body: data,
    );

    if (response.isLeft) {
      log(response.left.message!);
      return Left(response.left);
    } else {
      log(response.right.toString());
      //(response.right.toString());
      //
      return Right(FeeResponseModel.fromJson(response.right));
    }
  }

  @override
  Future<Either<MyError, StudentMenuModel>> getStudentMenu({
    required String studCode,
  }) async {
    var userData = Hive.box<AuthModel>(USERDB);
    userData.values;
    AuthModel authModel = userData.get(0) as AuthModel;
    var data = FormData.fromMap({
      "token": authModel.token,
      "famcode": authModel.famcode,
      "admission_no": studCode,
    });
    var response = await apiServices.postAPI(
      url: ApiConstatns.getStudentMenu,
      body: data,
    );

    if (response.isLeft) {
      log(response.left.message!);
      return Left(response.left);
    } else {
      // log(response.right.toString());
      log('studentMenu response fetched successfully');
      return Right(StudentMenuModel.fromJson(response.right));
    }
  }

  @override
  Future<Either<MyError, StudentsModel>> getStudents() async {
    var userData = Hive.box<AuthModel>(USERDB);
    userData.values;
    AuthModel authModel = userData.get(0) as AuthModel;
    var data = FormData.fromMap({
      "token": authModel.token,
      "famcode": authModel.famcode,
    });
    var response = await apiServices.postAPI(
      url: ApiConstatns.getStudents,
      body: data,
    );
    response.fold(
      (left) => MyError(key: left.key, message: left.message),
      (right) => StudentsModel.fromJson(right),
    );
    if (response.isLeft) {
      log(response.left.message!);
      return Left(response.left);
    } else {
      // log(response.right.toString());
      log('studentDetails response fetched successfully');
      return Right(StudentsModel.fromJson(response.right));
    }
  }

  @override
  Future<Either<MyError, dynamic>> progressReport({
    required String studCode,
    examId,
    accId,
  }) async {
    var userData = Hive.box<AuthModel>(USERDB);
    userData.values;
    AuthModel authModel = userData.get(0) as AuthModel;

    var data = FormData.fromMap({
      "token": authModel.token,
      "famcode": authModel.famcode,
      "admission_no": studCode,
      "exm_id": examId,
      "ac_year_id": accId,
    });
    Dio dio = Dio();

    var response = await dio.post(ApiConstatns.progrssReport, data: data);

    // log("Progress Report API - Response type: ${responseData.runtimeType}");
    // log("Progress Report API - Keys: ...");
    log('progress report response fetched successfully');

    return Right(response.data);
  }

  @override
  Future<Either<MyError, dynamic>> updateStudentDocumentDetails({
    required String studCode,
    required String emiratesId,
    required String emiratesIdExp,
  }) async {
    try {
      var userData = Hive.box<AuthModel>(USERDB);
      userData.values;
      AuthModel authModel = userData.get(0) as AuthModel;

      var data = FormData.fromMap({
        "token": authModel.token,
        "famcode": authModel.famcode,
        "admission_no": studCode,
        "emirates_id": emiratesId,
        "emirates_exp": emiratesIdExp,
      });

      var response = await apiServices.postAPI(
        url: ApiConstatns.updateStudentEmiratesID,
        body: data,
      );

      if (response.isLeft) {
        log(
          "Error updating student document details: ${response.left.message}",
        );
        return Left(response.left);
      } else {
        // Return Right for all successful API responses
        // Provider will check response.right['status'] to determine success/failure
        log("API response received: ${response.right.toString()}");
        return Right(response.right);
      }
    } catch (e) {
      log("Unexpected error in updateStudentDocumentDetails: $e");
      return Left(
        MyError(
          key: AppError.unknown,
          message: 'An unexpected error occurred. Please try again.',
        ),
      );
    }
  }

  @override
  Future<Either<MyError, dynamic>> viewStudentRcpts({
    required String studCode,
    type,
    no,
  }) async {
    var userData = Hive.box<AuthModel>(USERDB);
    userData.values;
    AuthModel authModel = userData.get(0) as AuthModel;
    var data = FormData.fromMap({
      "token": authModel.token,
      "famcode": authModel.famcode,
      "studcode": studCode,
      "type": type,
      "no": no,
    });
    Dio dio = Dio();

    var response = await dio.post(ApiConstatns.viewFeeRcpt, data: data);
    log("response ${response.data}");
    return Right(response.data);
  }

  @override
  Future<Either<MyError, dynamic>> getReportNamesByClass({
    required String admissionNo,
  }) async {
    try {
      var userData = Hive.box<AuthModel>(USERDB);
      userData.values;
      AuthModel authModel = userData.get(0) as AuthModel;
      var data = FormData.fromMap({
        "token": authModel.token,
        "famcode": authModel.famcode,
        "admission_no": admissionNo,
      });
      log('[getReportNamesByClass] --> POST ${ApiConstatns.getReportNamesByClass}');
      log('[getReportNamesByClass]     params: admission_no=$admissionNo, famcode=${authModel.famcode}');
      Dio dio = Dio();
      var response = await dio.post(
        ApiConstatns.getReportNamesByClass,
        data: data,
      );
      log('[getReportNamesByClass] <-- statusCode: ${response.statusCode}');
      log('[getReportNamesByClass]     response (full): ${response.data}');
      return Right(response.data);
    } catch (e, st) {
      log('[getReportNamesByClass] ERROR: $e');
      log('[getReportNamesByClass] stackTrace: $st');
      if (e is DioException && e.response != null) {
        log('[getReportNamesByClass]     response.data: ${e.response?.data}');
        log('[getReportNamesByClass]     response.statusCode: ${e.response?.statusCode}');
      }
      return Left(
        MyError(
          key: AppError.unknown,
          message: toUserFriendlyErrorMessage(e),
        ),
      );
    }
  }

  @override
  Future<Either<MyError, dynamic>> getReportCardHtml({
    required String reportId,
    required String exmId,
    required String acYearId,
    required String admissionNo,
  }) async {
    log('[getReportCardHtml] --> POST ${ApiConstatns.getReportCardHtml}');
    log('[getReportCardHtml]     params: report_id=$reportId, exm_id=$exmId, ac_year_id=$acYearId, admission_no=$admissionNo');
    try {
      var userData = Hive.box<AuthModel>(USERDB);
      userData.values;
      AuthModel authModel = userData.get(0) as AuthModel;
      log('[getReportCardHtml]     famcode=${authModel.famcode}');
      var data = FormData.fromMap({
        "token": authModel.token,
        "famcode": authModel.famcode,
        "report_id": reportId,
        "exm_id": exmId,
        "ac_year_id": acYearId,
        "admission_no": admissionNo,
      });
      Dio dio = Dio();
      var response = await dio.post(
        ApiConstatns.getReportCardHtml,
        data: data,
      );
      log('[getReportCardHtml] <-- statusCode: ${response.statusCode}');
      final respData = response.data;
      if (respData is Map<String, dynamic>) {
        final status = respData['status'];
        final dataMap = respData['data'];
        final htmlLen = dataMap is Map ? (dataMap['html']?.toString().length ?? 0) : 0;
        log('[getReportCardHtml]     response: status=$status, data.html length=$htmlLen');
      } else {
        log('[getReportCardHtml]     response type: ${respData.runtimeType}');
      }
      return Right(response.data);
    } catch (e, st) {
      log('[getReportCardHtml] ERROR: $e');
      log('[getReportCardHtml] stackTrace: $st');
      if (e is DioException && e.response != null) {
        log('[getReportCardHtml]     response.data: ${e.response?.data}');
        log('[getReportCardHtml]     response.statusCode: ${e.response?.statusCode}');
      }
      return Left(
        MyError(
          key: AppError.unknown,
          message: toUserFriendlyErrorMessage(e),
        ),
      );
    }
  }

}

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
import 'package:school_app/core/services/api_post_logger.dart';
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
    final dio = ApiPostLogger.newDio();

    var response = await dio.post(
      ApiConstatns.availableProgrssReport,
      data: data,
    );
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
    final dio = ApiPostLogger.newDio();

    var response = await dio.post(ApiConstatns.progrssReport, data: data);
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
    final dio = ApiPostLogger.newDio();

    var response = await dio.post(ApiConstatns.viewFeeRcpt, data: data);
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
      final dio = ApiPostLogger.newDio();
      var response = await dio.post(
        ApiConstatns.getReportNamesByClass,
        data: data,
      );
      return Right(response.data);
    } catch (e) {
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
    try {
      var userData = Hive.box<AuthModel>(USERDB);
      userData.values;
      AuthModel authModel = userData.get(0) as AuthModel;
      var data = FormData.fromMap({
        "token": authModel.token,
        "famcode": authModel.famcode,
        "report_id": reportId,
        "exm_id": exmId,
        "ac_year_id": acYearId,
        "admission_no": admissionNo,
      });
      final dio = ApiPostLogger.newDio();
      var response = await dio.post(
        ApiConstatns.getReportCardHtml,
        data: data,
      );
      return Right(response.data);
    } catch (e) {
      return Left(
        MyError(
          key: AppError.unknown,
          message: toUserFriendlyErrorMessage(e),
        ),
      );
    }
  }

}

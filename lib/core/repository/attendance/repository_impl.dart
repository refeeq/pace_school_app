import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:hive/hive.dart';
import 'package:school_app/core/constants/api_constants.dart';
import 'package:school_app/core/constants/db_constants.dart';
import 'package:school_app/core/models/auth_model.dart';
import 'package:school_app/core/repository/attendance/repository.dart';
import 'package:school_app/core/services/api_services.dart';

import '../../error/error_exception.dart';

class AttendanceRepositoryImpl extends AttendanceRepository {
  final DioAPIServices apiServices;

  AttendanceRepositoryImpl(this.apiServices);
  @override
  Future<Either<MyError, dynamic>> getAttendance({
    required String month,
    required String year,
    String? studentId,
  }) async {
    var userData = Hive.box<AuthModel>(USERDB);
    userData.values;
    AuthModel authModel = userData.get(0) as AuthModel;

    var data = FormData.fromMap({
      "admission_no": studentId,
      "token": authModel.token,
      "famcode": authModel.famcode,
      "month": month,
      "year": year,
    });
    var response = await apiServices.postAPI(
      url: ApiConstatns.studentAttendance,
      body: data,
    );
    // response.fold((left) => MyError(key: left.key, message: left.message),
    //     (right) => AttendanceResponseModel.fromJson(right));
    if (response.isLeft) {
      log(response.left.message!);
      return Left(response.left);
    } else {
      log(response.right.toString());
      if (response.right['status']) {
        return Right(response.right);
      } else {
        // showToast(response.right['message'],context);
        return Right(response.right);
      }
    }
  }
}

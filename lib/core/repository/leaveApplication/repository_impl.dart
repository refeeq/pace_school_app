import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:school_app/core/constants/api_constants.dart';
import 'package:school_app/core/constants/db_constants.dart';
import 'package:school_app/core/error/error_exception.dart';
import 'package:school_app/core/models/auth_model.dart';
import 'package:school_app/core/repository/leaveApplication/repository.dart';

import '../../services/api_services.dart';

class LeaveApplicationRepositoryImpl implements LeaveApplicationRepository {
  final DioAPIServices apiServices;

  LeaveApplicationRepositoryImpl(this.apiServices);

  @override
  Future<Either<MyError, dynamic>> applyLeaveApplication({
    required String fromDate,
    required String endDate,
    required String reasonId,
    required String reason,
    required String studentId,
  }) async {
    var userData = Hive.box<AuthModel>(USERDB);
    userData.values;
    AuthModel authModel = userData.get(0) as AuthModel;

    var data = FormData.fromMap({
      "token": authModel.token,
      "famcode": authModel.famcode,
      "studcode": studentId,
      "leave_reason_id": reasonId,
      "leave_from": fromDate,
      "leave_to": endDate,
      "leave_reason": reason,
    });
    var response = await apiServices.postAPI(
      url: ApiConstatns.applyLeave,
      body: data,
    );

    if (response.isLeft) {
      log(response.left.message!);
      return Left(response.left);
    } else {
      if (response.right['status'] == false) {
        log(response.right.toString());
        log(response.right['message']);
        return Right(response.right);
      } else {
        //  showToast(response.right['message']);
        log(response.right.toString());

        return Right(response.right);
      }
    }
  }

  @override
  Future<Either<MyError, dynamic>> getLeaveList({
    required String studentId,
  }) async {
    var userData = Hive.box<AuthModel>(USERDB);
    userData.values;
    AuthModel authModel = userData.get(0) as AuthModel;

    var data = FormData.fromMap({
      "token": authModel.token,
      "famcode": authModel.famcode,
      "studcode": studentId,
    });
    var response = await apiServices.postAPI(
      url: ApiConstatns.getAllLeaveList,
      body: data,
    );

    if (response.isLeft) {
      log(response.left.message!);
      return Left(response.left);
    } else {
      if (response.right['status'] == false) {
        log(response.right.toString());
        log(response.right['message']);
        return Right(response.right);
      } else {
        log(response.right.toString());

        return Right(response.right);
      }
    }
  }

  @override
  Future<Either<MyError, dynamic>> getLeaveResonList() async {
    var userData = Hive.box<AuthModel>(USERDB);
    userData.values;
    AuthModel authModel = userData.get(0) as AuthModel;

    var data = FormData.fromMap({
      "token": authModel.token,
      "famcode": authModel.famcode,
    });
    var response = await apiServices.postAPI(
      url: ApiConstatns.getAllLeaveResons,
      body: data,
    );

    if (response.isLeft) {
      log(response.left.message!);
      return Left(response.left);
    } else {
      if (response.right['status'] == false) {
        log(response.right.toString());
        log(response.right['message']);
        return const Right([]);
      } else {
        log(response.right.toString());

        return Right(response.right);
      }
    }
  }
}

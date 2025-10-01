import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:school_app/core/constants/api_constants.dart';
import 'package:school_app/core/constants/db_constants.dart';
import 'package:school_app/core/error/error_exception.dart';
import 'package:school_app/core/models/auth_model.dart';
import 'package:school_app/core/repository/circular/repository.dart';
import 'package:school_app/core/services/api_services.dart';

class CircularRepositoryImpl implements CircularRepository {
  final DioAPIServices apiServices;

  CircularRepositoryImpl(this.apiServices);
  @override
  Future<Either<MyError, dynamic>> getCircular({String? studCode}) async {
    var userData = Hive.box<AuthModel>(USERDB);
    userData.values;
    AuthModel authModel = userData.get(0) as AuthModel;

    var data = FormData.fromMap({
      "admission_no": studCode,
      "token": authModel.token,
      "famcode": authModel.famcode,
    });
    var response = await apiServices.postAPI(
      url: ApiConstatns.getCircular,
      body: data,
    );
    log(response.right.toString());

    if (response.isLeft) {
      log(response.left.message!);
      return Left(response.left);
    } else {
      if (response.right['status']) {
        return Right(response.right);
      } else {
        //showToast(response.right["message"]);
        return Right(response.right);
      }
    }
  }

  @override
  Future<Either<MyError, dynamic>> getParentCircular() async {
    var userData = Hive.box<AuthModel>(USERDB);
    userData.values;
    AuthModel authModel = userData.get(0) as AuthModel;

    var data = FormData.fromMap({
      "token": authModel.token,
      "famcode": authModel.famcode,
    });
    var response = await apiServices.postAPI(
      url: ApiConstatns.getParentCircular,
      body: data,
    );
    log(response.right.toString());

    if (response.isLeft) {
      log(response.left.message!);
      return Left(response.left);
    } else {
      if (response.right['status']) {
        return Right(response.right);
      } else {
        // showToast(response.right["message"]);
        return Right(response.right);
      }
    }
  }
}

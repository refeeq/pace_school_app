import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:school_app/core/constants/api_constants.dart';
import 'package:school_app/core/constants/db_constants.dart';
import 'package:school_app/core/error/error_exception.dart';
import 'package:school_app/core/models/auth_model.dart';
import 'package:school_app/core/models/parent_profile_list_model.dart';
import 'package:school_app/core/models/parent_profile_model.dart';
import 'package:school_app/core/repository/parent/repository.dart';
import 'package:school_app/core/services/api_services.dart';

class ParentRepositoryimpl implements ParentRepository {
  final DioAPIServices apiServices;

  ParentRepositoryimpl(this.apiServices);

  @override
  Future<Either<MyError, ParentProfileModel>> getParentProfile() async {
    var userData = Hive.box<AuthModel>(USERDB);
    userData.values;
    AuthModel authModel = userData.get(0) as AuthModel;

    var data = FormData.fromMap({
      "token": authModel.token,
      "famcode": authModel.famcode,
    });
    var response = await apiServices.postAPI(
      url: ApiConstatns.getParentProfile,
      body: data,
    );
    response.fold(
      (left) => MyError(key: left.key, message: left.message),
      (right) => ParentProfileModel.fromJson(right),
    );
    if (response.isLeft) {
      log(response.left.message!);
      return Left(response.left);
    } else {
      log(response.right.toString());
      return Right(ParentProfileModel.fromJson(response.right));
    }
  }

  @override
  Future<Either<MyError, ParentProfileListModel>> getParentProfileList() async {
    var userData = Hive.box<AuthModel>(USERDB);
    userData.values;
    AuthModel authModel = userData.get(0) as AuthModel;

    var data = FormData.fromMap({
      "token": authModel.token,
      "famcode": authModel.famcode,
    });
    var response = await apiServices.postAPI(
      url: ApiConstatns.getParentProfileTab,
      body: data,
    );

    if (response.isLeft) {
      log(response.left.message!);
      return Left(response.left);
    } else {
      log(response.right.toString());
      return Right(ParentProfileListModel.fromJson(response.right));
    }
  }

  @override
  Future<Either<MyError, dynamic>> updateParentEmail({
    required String email,
    required String relation,
  }) async {
    var userData = Hive.box<AuthModel>(USERDB);
    userData.values;
    AuthModel authModel = userData.get(0) as AuthModel;

    var data = FormData.fromMap({
      "token": authModel.token,
      "famcode": authModel.famcode,
      "email_address": email,
      "relation": relation,
    });
    var response = await apiServices.postAPI(
      url: ApiConstatns.updateParentEmailOtp,
      body: data,
    );

    if (response.isLeft) {
      log(response.left.message!);
      return Left(response.left);
    } else {
      log(response.right.toString());
      return Right(response.right);
    }
  }

  @override
  Future<Either<MyError, dynamic>> updateParentEmailOtp({
    required String email,
    required String relation,
    required String otp,
  }) async {
    var userData = Hive.box<AuthModel>(USERDB);
    userData.values;
    AuthModel authModel = userData.get(0) as AuthModel;

    var data = FormData.fromMap({
      "token": authModel.token,
      "famcode": authModel.famcode,
      "email_address": email,
      "relation": relation,
      "otp": otp,
    });
    var response = await apiServices.postAPI(
      url: ApiConstatns.updateParentEmail,
      body: data,
    );

    if (response.isLeft) {
      log(response.left.message!);
      return Left(response.left);
    } else {
      log(response.right.toString());
      return Right(response.right);
    }
  }

  @override
  Future<Either<MyError, dynamic>> updateParentMobile({
    required String mobile,
    required String relation,
  }) async {
    var userData = Hive.box<AuthModel>(USERDB);
    userData.values;
    AuthModel authModel = userData.get(0) as AuthModel;

    var data = FormData.fromMap({
      "token": authModel.token,
      "famcode": authModel.famcode,
      "phone_number": mobile,
      "relation": relation,
    });
    var response = await apiServices.postAPI(
      url: ApiConstatns.updateParentMobileOtp,
      body: data,
    );

    if (response.isLeft) {
      log(response.left.message!);
      return Left(response.left);
    } else {
      log(response.right.toString());
      return Right(response.right);
    }
  }

  @override
  Future<Either<MyError, dynamic>> updateParentMobileOtp({
    required String mobile,
    required String relation,
    required String otp,
  }) async {
    var userData = Hive.box<AuthModel>(USERDB);
    userData.values;
    AuthModel authModel = userData.get(0) as AuthModel;

    var data = FormData.fromMap({
      "token": authModel.token,
      "famcode": authModel.famcode,
      "phone_number": mobile,
      "relation": relation,
      "otp": otp,
    });
    var response = await apiServices.postAPI(
      url: ApiConstatns.updateParentMobile,
      body: data,
    );

    if (response.isLeft) {
      log(response.left.message!);
      return Left(response.left);
    } else {
      log(response.right.toString());
      return Right(response.right);
    }
  }
}

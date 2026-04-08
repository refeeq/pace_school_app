// ignore_for_file: non_constant_identifier_names, duplicate_ignore

import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:school_app/core/constants/api_constants.dart';
import 'package:school_app/core/error/error_exception.dart';
import 'package:school_app/core/models/auth_model.dart';
import 'package:school_app/core/models/login_response_model.dart';
import 'package:school_app/core/models/otp_response_model.dart';
import 'package:school_app/core/repository/repository.dart';
import 'package:school_app/core/services/api_services.dart';

import '../constants/db_constants.dart';

class RepsitoryImpl implements Repository {
  final DioAPIServices dioAPIServices;

  RepsitoryImpl(this.dioAPIServices);
  @override
  Future<Either<MyError, LoginResponseModel>> login(
  // ignore: non_constant_identifier_names
  {required String admission_no, required String phone_no}) async {
    var data = FormData.fromMap({
      "admission_no": admission_no,
      "phone_no": phone_no,
    });
    var response = await dioAPIServices.postAPI(
      url: ApiConstatns.login,
      body: data,
    );
    response.fold(
      (left) => MyError(key: left.key, message: left.message),
      (right) => LoginResponseModel.fromJson(right),
    );
    if (response.isLeft) {
      log(response.left.message!);
      return Left(response.left);
    } else {
      log(response.right.toString());
      return Right(LoginResponseModel.fromJson(response.right));
    }
  }

  @override
  Future<Either<MyError, OtpResponseModel?>> setFcmToken() async {
    var userData = Hive.box<AuthModel>(USERDB);
    userData.values;
    AuthModel authModel = userData.get(0) as AuthModel;
    String? token;
    try {
      token = await FirebaseMessaging.instance.getToken();
    } catch (e) {
      print("Firebase Messaging error in repository: $e");
      token = "No Token Available";
    }
    var data = FormData.fromMap({
      "token": authModel.token,
      "famcode": authModel.famcode,
      "fcm_token": token,
    });
    var response = await dioAPIServices.postAPI(
      url: ApiConstatns.setFcmToken,
      body: data,
    );
    // response.fold((left) => MyError(key: left.key, message: left.message),
    //     (right) => LoginResponseModel.fromJson(right));
    if (response.isLeft) {
      return Left(response.left);
    } else {
      await Hive.box("notificationPermission").add("Success");
      await Hive.box('notification').put("notification", true);
      if (response.right['status'] == false) {
        log(response.right['message']);
        return Right(OtpResponseModel.fromJson(response.right));
      } else {
        log(response.right.toString());
        return Right(OtpResponseModel.fromJson(response.right));
      }
    }
  }

  @override
  Future<Either<MyError, OtpResponseModel?>> verifyOtp(
  // ignore: non_constant_identifier_names
  {
    required String phone_no,
    required String otp_code,
    required String token,
  }) async {
    var data = FormData.fromMap({
      "otp_code": otp_code,
      "phone_no": phone_no,
      "fcm_token": token,
    });
    var response = await dioAPIServices.postAPI(
      url: ApiConstatns.verifyOTP,
      body: data,
    );
    // response.fold((left) => MyError(key: left.key, message: left.message),
    //     (right) => LoginResponseModel.fromJson(right));
    if (response.isLeft) {
      return Left(response.left);
    } else {
      if (response.right['status'] == false) {
        log(response.right['message']);
        return Right(OtpResponseModel.fromJson(response.right));
      } else {
        log(response.right.toString());
        return Right(OtpResponseModel.fromJson(response.right));
      }
    }
  }
}

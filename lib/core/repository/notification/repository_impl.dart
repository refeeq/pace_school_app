import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:school_app/core/constants/api_constants.dart';
import 'package:school_app/core/constants/db_constants.dart';
import 'package:school_app/core/error/error_exception.dart';
import 'package:school_app/core/models/auth_model.dart';
import 'package:school_app/core/repository/notification/repository.dart';
import 'package:school_app/core/services/api_services.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final DioAPIServices apiServices;

  NotificationRepositoryImpl(this.apiServices);
  @override
  Future<Either<MyError, dynamic>> getAllNotifications(int pageNumber) async {
    var userData = Hive.box<AuthModel>(USERDB);
    userData.values;
    AuthModel authModel = userData.get(0) as AuthModel;

    var data = FormData.fromMap({
      "token": authModel.token,
      "famcode": authModel.famcode,
      "pageNo": pageNumber,
    });
    var response = await apiServices.postAPI(
      url: ApiConstatns.getAllNotifications,
      body: data,
    );

    if (response.isLeft) {
      return Left(response.left);
    } else {
      if (response.right['status'] == false) {
        log(response.right.toString());
        if (kDebugMode) {
          //   showToast(response.right['message']);
        }
        return const Right([]);
      } else {
        //  showToast(response.right['message']);
        log(response.right.toString());

        return Right(response.right);
      }
    }
  }

  @override
  Future<Either<MyError, dynamic>> readNotifiction(String id) async {
    var userData = Hive.box<AuthModel>(USERDB);
    userData.values;
    AuthModel authModel = userData.get(0) as AuthModel;

    var data = FormData.fromMap({
      "token": authModel.token,
      "famcode": authModel.famcode,
      "notificationId": id,
    });
    var response = await apiServices.postAPI(
      url: ApiConstatns.readNotification,
      body: data,
    );

    if (response.isLeft) {
      //  showToast(response.left.message!);
      return Left(response.left);
    } else {
      if (response.right['status'] == false) {
        log(response.right.toString());

        /// showToast(response.right['message']);
        return const Right([]);
      } else {
        //  showToast(response.right['message']);
        log(response.right.toString());

        return Right(response.right);
      }
    }
  }
}

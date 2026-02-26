import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:school_app/core/constants/api_constants.dart';
import 'package:school_app/core/constants/db_constants.dart';
import 'package:school_app/core/error/error_exception.dart';
import 'package:school_app/core/models/auth_model.dart';
import 'package:school_app/core/models/contact_us_history_model.dart';
import 'package:school_app/core/repository/contactUs/repository.dart';
import 'package:school_app/core/services/api_services.dart';

class ContactUsRepositoryImpl implements ContactUsRepository {
  final DioAPIServices apiServices;

  ContactUsRepositoryImpl(this.apiServices);
  @override
  Future<Either<MyError, dynamic>> submitContactForm({
    required String name,
    required String email,
    required String phone,
    required String message,
  }) async {
    var userData = Hive.box<AuthModel>(USERDB);
    userData.values;
    AuthModel authModel = userData.get(0) as AuthModel;

    var data = FormData.fromMap({
      "token": authModel.token,
      "famcode": authModel.famcode,
      'name': name,
      "email": email,
      "phone": phone,
      "message": message,
    });
    var response = await apiServices.postAPI(
      url: ApiConstatns.contactUs,
      body: data,
    );

    if (response.isLeft) {
      log(response.left.message!);
      return Left(response.left);
    } else {
      if (response.right['status'] == false) {
        log(response.right.toString());

        return Right(response.right);
      } else {
        //  showToast(response.right['message']);
        log(response.right.toString());

        return Right(response.right);
      }
    }
  }

  @override
  Future<Either<MyError, dynamic>> submitGuestContactForm({
    required String name,
    required String email,
    required String phone,
    required String message,
  }) async {
    var data = FormData.fromMap({
      // "token": authModel.token,
      // "famcode": authModel.famcode,
      'name': name,
      "email": email,
      "phone": phone,
      "message": message,
    });
    var response = await apiServices.postAPI(
      url: ApiConstatns.guestContactUs,
      body: data,
    );

    if (response.isLeft) {
      log(response.left.message!);
      return Left(response.left);
    } else {
      if (response.right['status'] == false) {
        log(response.right.toString());

        return Left(
          MyError(key: AppError.unknown, message: response.right["message"]),
        );
      } else {
        //  showToast(response.right['message']);
        log(response.right.toString());

        return Right(response.right);
      }
    }
  }

  @override
  Future<Either<MyError, List<ContactUsHistoryItem>>> getContactUsHistory() async {
    var userData = Hive.box<AuthModel>(USERDB);
    AuthModel authModel = userData.get(0) as AuthModel;

    var data = FormData.fromMap({
      "token": authModel.token,
      "famcode": authModel.famcode,
    });
    var response = await apiServices.postAPI(
      url: ApiConstatns.getContactUsHistory,
      body: data,
    );

    if (response.isLeft) {
      log(response.left.message!);
      return Left(response.left);
    }
    if (response.right['status'] != true) {
      log(response.right.toString());
      return Left(
        MyError(
          key: AppError.unknown,
          message: response.right['message']?.toString() ?? 'Failed to load history',
        ),
      );
    }
    final listData = response.right['data'];
    final list = ContactUsHistoryItem.listFromJson(listData);
    return Right(list);
  }
}

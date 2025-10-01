import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:school_app/core/constants/api_constants.dart';
import 'package:school_app/core/constants/db_constants.dart';
import 'package:school_app/core/error/error_exception.dart';
import 'package:school_app/core/models/auth_model.dart';
import 'package:school_app/core/services/api_services.dart';
import 'package:school_app/views/screens/open_house/model/active_open_house_model.dart';
import 'package:school_app/views/screens/open_house/model/add_open_house_model.dart';
import 'package:school_app/views/screens/open_house/model/open_house_model.dart';

class OpenHouseRepository {
  final DioAPIServices apiServices;

  OpenHouseRepository({required this.apiServices});
  Future<Either<MyError, String>> bookOpenHouse(
    String studCode,
    List<AddOpenHouseModel> booking,
    String ohMainId,
  ) async {
    var userData = Hive.box<AuthModel>(USERDB);
    userData.values;
    AuthModel authModel = userData.get(0) as AuthModel;
    var data = FormData.fromMap({
      "token": authModel.token,
      "admission_no": studCode,
      "ohMainId": int.parse(ohMainId),
      "famcode": authModel.famcode,
      "bookingArray": List<dynamic>.from(booking.map((e) => e.toJson())),
    });
    log(List<dynamic>.from(booking.map((e) => e.toJson())).toString());
    var response = await apiServices.postAPI(
      url: ApiConstatns.addOpenhouseApp,
      body: data,
    );

    if (response.isLeft) {
      log(response.left.message!);
      return Left(response.left);
    } else {
      log(response.right["message"]);
      if (response.right['status']) {
        return Right(response.right["message"]);
      } else {
        return Left(
          MyError(key: AppError.unknown, message: response.right["message"]),
        );
      }
    }
  }

  Future<Either<MyError, OpenHouseClass>> getOpenHouse(String studCode) async {
    var userData = Hive.box<AuthModel>(USERDB);
    userData.values;
    AuthModel authModel = userData.get(0) as AuthModel;
    var data = FormData.fromMap({
      "token": authModel.token,
      "admission_no": studCode,
      "famcode": authModel.famcode,
    });
    var response = await apiServices.postAPI(
      url: ApiConstatns.openHouse,
      body: data,
    );

    if (response.isLeft) {
      log(response.left.message!);
      return Left(response.left);
    } else {
      log(response.right.toString());
      if (response.right['status']) {
        List<OpenHouseModel> list = List<OpenHouseModel>.from(
          response.right["data"].map((x) => OpenHouseModel.fromJson(x)),
        );
        List<ActiveOpenHouseModel> activeList = List<ActiveOpenHouseModel>.from(
          response.right["appointments"].map(
            (x) => ActiveOpenHouseModel.fromJson(x),
          ),
        );

        var clss = OpenHouseClass(
          openHouseList: list,
          activeOpenHouseList: activeList,
        );
        return Right(clss);
      } else {
        return Left(
          MyError(key: AppError.unknown, message: response.right["message"]),
        );
      }
    }
  }
}

class OpenHouseClass {
  final List<OpenHouseModel> openHouseList;
  final List<ActiveOpenHouseModel> activeOpenHouseList;

  OpenHouseClass({
    required this.openHouseList,
    required this.activeOpenHouseList,
  });
}

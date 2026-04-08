import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:hive/hive.dart';
import 'package:school_app/core/constants/api_constants.dart';
import 'package:school_app/core/constants/db_constants.dart';
import 'package:school_app/core/error/error_exception.dart';
import 'package:school_app/core/models/auth_model.dart';
import 'package:school_app/core/services/api_services.dart';
import 'package:school_app/views/screens/family_fee/models/family_fee_item_model.dart';

import '../models/family_fee_model.dart';

class FamilyFeeRepository {
  final DioAPIServices dioAPIServices;

  FamilyFeeRepository({required this.dioAPIServices});
  Future<Either<MyError, FamilyFeeModel>> getFee() async {
    var userData = Hive.box<AuthModel>(USERDB);
    userData.values;
    AuthModel authModel = userData.get(0) as AuthModel;
    var data = FormData.fromMap({
      "token": authModel.token,
      "famcode": authModel.famcode,
    });
    var res = await dioAPIServices.postAPI(
      body: data,
      url: ApiConstatns.getFamilyFee,
    );
    if (res.isLeft) {
      return Left(res.left);
    } else {
      return Right(FamilyFeeModel.fromJson(res.right));
    }
  }

  Future<Either<MyError, dynamic>> submitFee(List<FamilyFeeItem> fees) async {
    var userData = Hive.box<AuthModel>(USERDB);
    userData.values;
    AuthModel authModel = userData.get(0) as AuthModel;
    var data0 = {
      "token": authModel.token,
      "famcode": authModel.famcode,
      "data": List<dynamic>.from(fees.map((x) => x.toJson())),
    };
    log(data0.toString());
    var data = FormData.fromMap(data0);
    var res = await dioAPIServices.postAPI(
      body: data,
      url: ApiConstatns.submitFamilyFee,
    );
    if (res.isLeft) {
      return Left(res.left);
    } else {
      return Right(res.right);
    }
  }
}

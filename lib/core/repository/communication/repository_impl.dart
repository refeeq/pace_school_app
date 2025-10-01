import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:either_dart/src/either.dart';
import 'package:hive/hive.dart';
import 'package:school_app/core/constants/api_constants.dart';
import 'package:school_app/core/constants/db_constants.dart';
import 'package:school_app/core/error/error_exception.dart';
import 'package:school_app/core/models/auth_model.dart';
import 'package:school_app/core/repository/communication/repository.dart';
import 'package:school_app/core/services/api_services.dart';

class CommunicationRepositoryImpl implements CommunicationRepository {
  final DioAPIServices apiServices;

  CommunicationRepositoryImpl(this.apiServices);

  @override
  Future<Either<MyError, dynamic>> getCommunicationDetails(
    String studentId,
    String id,
    int page,
  ) async {
    var userData = Hive.box<AuthModel>(USERDB);
    userData.values;
    AuthModel authModel = userData.get(0) as AuthModel;
    // var studCode = Hive.box<StudentModel>(STUDENTDB).get('current')!.studcode;
    var data = FormData.fromMap({
      "token": authModel.token,
      "famcode": authModel.famcode,
      "studcode": studentId,
      "type": id,
      "pageNo": page,
    });
    var response = await apiServices.postAPI(
      url: ApiConstatns.getCommunicationsBifur,
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
        //  showToast(response.right['message']);
        log(response.right.toString());

        return Right(response.right);
      }
    }
  }

  @override
  Future<Either<MyError, dynamic>> getCommunicationTileList(
    String studentId,
  ) async {
    var userData = Hive.box<AuthModel>(USERDB);
    userData.values;
    AuthModel authModel = userData.get(0) as AuthModel;
    // var studCode = Hive.box<StudentModel>(STUDENTDB).get('current')!.studcode;
    var data = FormData.fromMap({
      "token": authModel.token,
      "famcode": authModel.famcode,
      "studcode": studentId,
    });
    var response = await apiServices.postAPI(
      url: ApiConstatns.getCommunicationTileList,
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
        //  showToast(response.right['message']);
        log(response.right.toString());

        return Right(response.right);
      }
    }
  }

  @override
  Future<Either<MyError, dynamic>> getStudentList() async {
    var userData = Hive.box<AuthModel>(USERDB);
    userData.values;
    AuthModel authModel = userData.get(0) as AuthModel;

    var data = FormData.fromMap({
      "token": authModel.token,
      "famcode": authModel.famcode,
    });
    var response = await apiServices.postAPI(
      url: ApiConstatns.getCommunicationStudentList,
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
        //  showToast(response.right['message']);
        log(response.right.toString());

        return Right(response.right);
      }
    }
  }
}

import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:either_dart/src/either.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:school_app/core/constants/api_constants.dart';
import 'package:school_app/core/constants/db_constants.dart';
import 'package:school_app/core/error/error_exception.dart';
import 'package:school_app/core/models/admission_det_model.dart';
import 'package:school_app/core/models/auth_model.dart';
import 'package:school_app/core/models/siblinf_register_model.dart';
import 'package:school_app/core/repository/admission/repository.dart';
import 'package:school_app/core/services/api_services.dart';

class AdmissionRepositoryImpl implements AdmissionRepository {
  final DioAPIServices apiServices;

  AdmissionRepositoryImpl(this.apiServices);
  @override
  Future<Either<MyError, dynamic>> fetchRegistrations() async {
    var userData = Hive.box<AuthModel>(USERDB);
    userData.values;
    AuthModel authModel = userData.get(0) as AuthModel;

    var fdata = FormData.fromMap({
      "token": authModel.token,
      "famcode": authModel.famcode,
    });

    var response = await apiServices.postAPI(
      url: ApiConstatns.siblingRegistrationList,
      body: fdata,
    );

    if (response.isLeft) {
      log(response.left.message!);
      return Left(response.left);
    } else {
      return Right(response.right);
    }
  }

  @override
  Future<Either<MyError, dynamic>> getAdmissionData() async {
    var userData = Hive.box<AuthModel>(USERDB);
    userData.values;
    AuthModel authModel = userData.get(0) as AuthModel;

    var data = FormData.fromMap({
      "token": authModel.token,
      "famcode": authModel.famcode,
    });
    var response = await apiServices.postAPI(
      url: ApiConstatns.getAdmissionData,
      body: data,
    );

    if (response.isLeft) {
      log(response.left.message!);
      return Left(response.left);
    } else {
      if (response.right['status'] == false) {
        log(response.right['message']);
        return const Right(null);
      } else {
        log(response.right.toString());
        return Right(AdmissionResModel.fromJson(response.right['data']));
      }
    }
  }

  @override
  Future<Either<MyError, dynamic>> getGuestAdmissionData() async {
    var response = await apiServices.postAPI(url: ApiConstatns.guestGetRegDet);

    if (response.isLeft) {
      log(response.left.message!);
      return Left(response.left);
    } else {
      if (response.right['status'] == false) {
        log(response.right['message']);
        return const Right(null);
      } else {
        log(response.right.toString());
        return Right(AdmissionResModel.fromJson(response.right['data']));
      }
    }
  }

  @override
  Future<Either<MyError, dynamic>> submitGuestAdmission(
    SiblingRegisterModel siblingRegisterModel,
  ) async {
    var fdata = FormData.fromMap({
      "ac_year": siblingRegisterModel.acYear,
      "transport": siblingRegisterModel.transport,
      "prev_sch": siblingRegisterModel.prevSch,
      "syllabus": siblingRegisterModel.syllabus,
      "email_address": siblingRegisterModel.emailAddress,
      "phone2": siblingRegisterModel.phone2,
      "phone": siblingRegisterModel.phone,
      "fname": siblingRegisterModel.fname,
      "landmark": siblingRegisterModel.landmark,
      "location": siblingRegisterModel.location,
      "second_lang": siblingRegisterModel.secondLang,
      "adm_gr": siblingRegisterModel.admGr,
      "reside": siblingRegisterModel.reside,
      "dob": siblingRegisterModel.dob,
      "country": siblingRegisterModel.country,
      "sex": siblingRegisterModel.sex,
      "name": siblingRegisterModel.name,
      "ethnicity": siblingRegisterModel.ethnicity,
    });

    var response = await apiServices.postAPI(
      url: ApiConstatns.guestOnlineRegistration,
      body: fdata,
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
        // showToast(response.right['message']);
        log(response.right.toString());
        return Right(response.right);
      }
    }
  }

  @override
  Future<Either<MyError, dynamic>> submitSibilingAdmission(
    SiblingRegisterModel siblingRegisterModel,
  ) async {
    var userData = Hive.box<AuthModel>(USERDB);
    userData.values;
    AuthModel authModel = userData.get(0) as AuthModel;

    var fdata = FormData.fromMap({
      "token": authModel.token,
      "famcode": authModel.famcode,
      "ac_year": siblingRegisterModel.acYear,
      "transport": siblingRegisterModel.transport,
      "prev_sch": siblingRegisterModel.prevSch,
      "syllabus": siblingRegisterModel.syllabus,
      "email_address": siblingRegisterModel.emailAddress,
      "phone2": siblingRegisterModel.phone2,
      "phone": siblingRegisterModel.phone,
      "fname": siblingRegisterModel.fname,
      "landmark": siblingRegisterModel.landmark,
      "location": siblingRegisterModel.location,
      "second_lang": siblingRegisterModel.secondLang,
      "adm_gr": siblingRegisterModel.admGr,
      "reside": siblingRegisterModel.reside,
      "dob": siblingRegisterModel.dob,
      "country": siblingRegisterModel.country,
      "sex": siblingRegisterModel.sex,
      "name": siblingRegisterModel.name,
      "ethnicity": siblingRegisterModel.ethnicity,
    });

    var response = await apiServices.postAPI(
      url: ApiConstatns.siblingRegistration,
      body: fdata,
    );

    if (response.isLeft) {
      log(response.left.message!);
      return Left(response.left);
    } else {
      return Right(response.right);
    }
  }
}

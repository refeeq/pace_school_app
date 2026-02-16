import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:school_app/core/constants/api_constants.dart';
import 'package:school_app/core/constants/db_constants.dart';
import 'package:school_app/core/error/error_exception.dart';
import 'package:school_app/core/models/auth_model.dart';
import 'package:school_app/core/models/parent_update_request_model.dart';
import 'package:school_app/core/repository/parent_update/repository.dart';
import 'package:school_app/core/services/api_services.dart';

class ParentUpdateRepositoryImpl implements ParentUpdateRepository {
  final DioAPIServices apiServices;

  ParentUpdateRepositoryImpl(this.apiServices);

  AuthModel _getAuth() {
    final userData = Hive.box<AuthModel>(USERDB);
    return userData.get(0) as AuthModel;
  }

  Future<FormData> _buildBaseFormData() async {
    final authModel = _getAuth();
    return FormData.fromMap({
      'token': authModel.token,
      'famcode': authModel.famcode,
    });
  }

  Future<Either<MyError, dynamic>> _post({
    required String url,
    required FormData data,
  }) async {
    final response = await apiServices.postAPI(
      url: url,
      body: data,
    );

    if (response.isLeft) {
      log(response.left.message ?? 'Unknown error');
      return Left(response.left);
    } else {
      log(response.right.toString());
      return Right(response.right);
    }
  }

  @override
  Future<Either<MyError, dynamic>> requestStudentPassportUpdate({
    required String admissionNo,
    String? passportNumber,
    required String expiryDate,
    required String documentPath,
  }) async {
    try {
      final base = await _buildBaseFormData();
      base.fields.addAll([
        MapEntry('admission_no', admissionNo),
        MapEntry('expiry_date', expiryDate),
      ]);
      if (passportNumber != null && passportNumber.isNotEmpty) {
        base.fields.add(MapEntry('passport_number', passportNumber));
      }
      base.files.add(
        MapEntry(
          'document',
          await MultipartFile.fromFile(documentPath),
        ),
      );
      return _post(
        url: ApiConstatns.requestPassportUpdate,
        data: base,
      );
    } catch (e) {
      log('requestStudentPassportUpdate error: $e');
      return Left(
        MyError(
          key: AppError.unknown,
          message: 'Failed to submit passport update request.',
        ),
      );
    }
  }

  @override
  Future<Either<MyError, dynamic>> requestStudentEidUpdate({
    required String admissionNo,
    required String emiratesId,
    required String expiryDate,
    required String documentPath,
  }) async {
    try {
      final base = await _buildBaseFormData();
      base.fields.addAll([
        MapEntry('admission_no', admissionNo),
        MapEntry('emirates_id', emiratesId),
        MapEntry('expiry_date', expiryDate),
      ]);
      base.files.add(
        MapEntry(
          'document',
          await MultipartFile.fromFile(documentPath),
        ),
      );
      return _post(
        url: ApiConstatns.requestStudentEidUpdate,
        data: base,
      );
    } catch (e) {
      log('requestStudentEidUpdate error: $e');
      return Left(
        MyError(
          key: AppError.unknown,
          message: 'Failed to submit Emirates ID update request.',
        ),
      );
    }
  }

  @override
  Future<Either<MyError, dynamic>> requestStudentPhotoUpdate({
    required String admissionNo,
    required String photoPath,
  }) async {
    try {
      final base = await _buildBaseFormData();
      base.fields.add(
        MapEntry('admission_no', admissionNo),
      );
      base.files.add(
        MapEntry(
          'photo',
          await MultipartFile.fromFile(photoPath),
        ),
      );
      return _post(
        url: ApiConstatns.requestStudentPhotoUpdate,
        data: base,
      );
    } catch (e) {
      log('requestStudentPhotoUpdate error: $e');
      return Left(
        MyError(
          key: AppError.unknown,
          message: 'Failed to submit student photo update request.',
        ),
      );
    }
  }

  @override
  Future<Either<MyError, dynamic>> requestFatherPhotoUpdate({
    required String photoPath,
  }) async {
    try {
      final base = await _buildBaseFormData();
      base.files.add(
        MapEntry(
          'photo',
          await MultipartFile.fromFile(photoPath),
        ),
      );
      return _post(
        url: ApiConstatns.requestFatherPhotoUpdate,
        data: base,
      );
    } catch (e) {
      log('requestFatherPhotoUpdate error: $e');
      return Left(
        MyError(
          key: AppError.unknown,
          message: 'Failed to submit father photo update request.',
        ),
      );
    }
  }

  @override
  Future<Either<MyError, dynamic>> requestMotherPhotoUpdate({
    required String photoPath,
  }) async {
    try {
      final base = await _buildBaseFormData();
      base.files.add(
        MapEntry(
          'photo',
          await MultipartFile.fromFile(photoPath),
        ),
      );
      return _post(
        url: ApiConstatns.requestMotherPhotoUpdate,
        data: base,
      );
    } catch (e) {
      log('requestMotherPhotoUpdate error: $e');
      return Left(
        MyError(
          key: AppError.unknown,
          message: 'Failed to submit mother photo update request.',
        ),
      );
    }
  }

  @override
  Future<Either<MyError, dynamic>> requestFatherEmailUpdate({
    required String email,
  }) async {
    try {
      final base = await _buildBaseFormData();
      base.fields.add(
        MapEntry('email', email),
      );
      return _post(
        url: ApiConstatns.requestFatherEmailUpdate,
        data: base,
      );
    } catch (e) {
      log('requestFatherEmailUpdate error: $e');
      return Left(
        MyError(
          key: AppError.unknown,
          message: 'Failed to submit father email update request.',
        ),
      );
    }
  }

  @override
  Future<Either<MyError, dynamic>> requestFatherEidUpdate({
    required String emiratesId,
    required String expiryDate,
    required String documentPath,
  }) async {
    try {
      final base = await _buildBaseFormData();
      base.fields.addAll([
        MapEntry('emirates_id', emiratesId),
        MapEntry('expiry_date', expiryDate),
      ]);
      base.files.add(
        MapEntry(
          'document',
          await MultipartFile.fromFile(documentPath),
        ),
      );
      return _post(
        url: ApiConstatns.requestFatherEidUpdate,
        data: base,
      );
    } catch (e) {
      log('requestFatherEidUpdate error: $e');
      return Left(
        MyError(
          key: AppError.unknown,
          message: 'Failed to submit father Emirates ID update request.',
        ),
      );
    }
  }

  @override
  Future<Either<MyError, dynamic>> requestMotherEidUpdate({
    required String emiratesId,
    required String expiryDate,
    required String documentPath,
  }) async {
    try {
      final base = await _buildBaseFormData();
      base.fields.addAll([
        MapEntry('emirates_id', emiratesId),
        MapEntry('expiry_date', expiryDate),
      ]);
      base.files.add(
        MapEntry(
          'document',
          await MultipartFile.fromFile(documentPath),
        ),
      );
      return _post(
        url: ApiConstatns.requestMotherEidUpdate,
        data: base,
      );
    } catch (e) {
      log('requestMotherEidUpdate error: $e');
      return Left(
        MyError(
          key: AppError.unknown,
          message: 'Failed to submit mother Emirates ID update request.',
        ),
      );
    }
  }

  @override
  Future<Either<MyError, dynamic>> requestAddressUpdate({
    String? homeAddress,
    String? flatNo,
    String? buildingName,
    String? comNumber,
    int? communityId,
  }) async {
    try {
      final base = await _buildBaseFormData();
      if (homeAddress != null) {
        base.fields.add(MapEntry('homeadd', homeAddress));
      }
      if (flatNo != null) {
        base.fields.add(MapEntry('flat_no', flatNo));
      }
      if (buildingName != null) {
        base.fields.add(MapEntry('building_name', buildingName));
      }
      if (comNumber != null) {
        base.fields.add(MapEntry('com_number', comNumber));
      }
      if (communityId != null) {
        base.fields.add(MapEntry('community_id', communityId.toString()));
      }

      return _post(
        url: ApiConstatns.requestAddressUpdate,
        data: base,
      );
    } catch (e) {
      log('requestAddressUpdate error: $e');
      return Left(
        MyError(
          key: AppError.unknown,
          message: 'Failed to submit address update request.',
        ),
      );
    }
  }

  @override
  Future<Either<MyError, ParentUpdateRequestListModel>>
      getParentUpdateRequests() async {
    try {
      final base = await _buildBaseFormData();
      final response = await apiServices.postAPI(
        url: ApiConstatns.getParentUpdateRequests,
        body: base,
      );

      if (response.isLeft) {
        log(response.left.message ?? 'Unknown error');
        return Left(response.left);
      }
      final raw = response.right;
      if (raw is! Map<String, dynamic>) {
        log('getParentUpdateRequests: expected Map, got ${raw.runtimeType}');
        return Left(
          MyError(
            key: AppError.unknown,
            message: 'Invalid response format from server.',
          ),
        );
      }
      log(response.right.toString());
      return Right(ParentUpdateRequestListModel.fromJson(raw));
    } catch (e) {
      log('getParentUpdateRequests error: $e');
      return Left(
        MyError(
          key: AppError.unknown,
          message: 'Failed to fetch parent update requests.',
        ),
      );
    }
  }
}


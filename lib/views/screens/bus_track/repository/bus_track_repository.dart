import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:school_app/core/constants/api_constants.dart';
import 'package:school_app/core/constants/db_constants.dart';
import 'package:school_app/core/error/error_exception.dart';
import 'package:school_app/core/models/auth_model.dart';
import 'package:school_app/core/services/api_services.dart';
import 'package:school_app/views/screens/bus_track/models/bus_track_model.dart';

class BusTrackRepository {
  final DioAPIServices dioAPIServices;

  BusTrackRepository({required this.dioAPIServices});

  Future<Either<MyError, BusTrackModel>> getTracking({
    required String admissionNo,
  }) async {
    var userData = Hive.box<AuthModel>(USERDB);
    userData.values;
    AuthModel authModel = userData.get(0) as AuthModel;

    var data = FormData.fromMap({
      "token": authModel.token,
      "famcode": authModel.famcode,
      "admission_no": admissionNo,
    });

    // Log request details
    log('========== API REQUEST DETAILS ==========');
    log('URL: ${ApiConstatns.getTracking}');
    log('Method: POST');
    log('Request Headers:');
    log('  Content-Type: application/json');
    log('  Accept: application/json');
    log('  token: ${authModel.token}');
    log('Request Body (FormData Fields):');
    for (var field in data.fields) {
      log('  ${field.key}: ${field.value}');
    }
    if (data.files.isNotEmpty) {
      log('Request Files:');
      for (var file in data.files) {
        log('  ${file.key}: ${file.value.filename}');
      }
    }
    log('==========================================');

    // Make direct Dio call to capture full response details
    final dio = Dio();
    dio.options = BaseOptions(
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'token': authModel.token,
      },
    );

    try {
      final response = await dio.post(
        ApiConstatns.getTracking,
        data: data,
      );

      // Log full response details
      log('========== API RESPONSE DETAILS ==========');
      log('Status Code: ${response.statusCode}');
      log('Status Message: ${response.statusMessage}');
      log('Response Headers:');
      response.headers.forEach((key, values) {
        log('  $key: ${values.join(", ")}');
      });
      log('Response Body:');
      try {
        final responseData = jsonDecode(response.data);
        final prettyJson = const JsonEncoder.withIndent('  ').convert(responseData);
        log(prettyJson);
      } catch (e) {
        log('Raw Response: ${response.data}');
      }
      log('==========================================');

      // Parse response and return
      final responseData = jsonDecode(response.data);
      return Right(BusTrackModel.fromJson(responseData));
    } on DioException catch (e) {
      // Log error details
      log('========== API ERROR DETAILS ==========');
      log('Error Type: ${e.type}');
      log('Error Message: ${e.message}');
      if (e.response != null) {
        log('Response Status Code: ${e.response?.statusCode}');
        log('Response Status Message: ${e.response?.statusMessage}');
        log('Response Headers:');
        e.response?.headers.forEach((key, values) {
          log('  $key: ${values.join(", ")}');
        });
        log('Response Data: ${e.response?.data}');
      }
      log('Request Options:');
      log('  URI: ${e.requestOptions.uri}');
      log('  Method: ${e.requestOptions.method}');
      log('  Headers: ${e.requestOptions.headers}');
      log('  Data: ${e.requestOptions.data}');
      log('==========================================');

      // Handle error using the existing error handling
      return Left(_handleDioError(e));
    }
  }

  // Error handling method
  MyError _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const MyError(
          key: AppError.unknown,
          message: 'Connection Timeout',
        );
      case DioExceptionType.badResponse:
        switch (error.response?.statusCode) {
          case 400:
            return const MyError(
              key: AppError.badRequest,
              message: 'Bad Request',
            );
          case 401:
            Hive.box<AuthModel>(USERDB).clear();
            return const MyError(
              key: AppError.unauthorized,
              message: 'Unauthorized',
            );
          case 403:
            return const MyError(key: AppError.forbidden, message: 'Forbidden');
          case 404:
            return const MyError(key: AppError.notFound, message: 'Not Found');
          case 500:
            return const MyError(
              key: AppError.internalServerError,
              message: 'Internal Server Error',
            );
          default:
            return const MyError(
              key: AppError.unknown,
              message: 'Unknown Error',
            );
        }
      case DioExceptionType.cancel:
        return const MyError(
          key: AppError.unknown,
          message: 'Request Cancelled',
        );
      case DioExceptionType.unknown:
      default:
        return MyError(key: AppError.unknown, message: error.message);
    }
  }
}

import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:school_app/core/constants/db_constants.dart';
import 'package:school_app/core/error/error_exception.dart';
import 'package:school_app/core/models/auth_model.dart';

class DioAPIServices {
  final Dio _dio = Dio();

  // GET request
  Future<Either<MyError, dynamic>> getRequest(
    String endpoint,
    String? token, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      _dio.options = BaseOptions(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'token': token,
        },
      );
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );
      log(endpoint);
      return Right(json.decode(response.data));
    } on DioException catch (e) {
      return Left(_handleError(e));
    }
  }

  // POST request
  Future<Either<MyError, dynamic>> postAPI({
    dynamic body,
    String url = '',
    String authorization = '',
  }) async {
    try {
      _dio.options = BaseOptions(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'token': authorization,
        },
      );
      final response = await _dio.post(url, data: body);
      log(url);
      return Right(json.decode(response.data));
    } on DioException catch (e) {
      return Left(_handleError(e));
    }
  }

  // PUT request
  Future<Either<MyError, dynamic>> putRequest(
    String endpoint,
    String? token,
    dynamic data,
  ) async {
    try {
      _dio.options = BaseOptions(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'token': token,
        },
      );
      final response = await _dio.put(endpoint, data: data);
      return Right(json.decode(response.data));
    } on DioException catch (e) {
      return Left(_handleError(e));
    }
  }

  // DELETE request
  Future<Either<MyError, dynamic>> deleteRequest(
    String endpoint,
    String? token,
  ) async {
    try {
      _dio.options = BaseOptions(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'token': token,
        },
      );
      final response = await _dio.delete(endpoint);
      return Right(response.data);
    } on DioException catch (e) {
      return Left(_handleError(e));
    }
  }

  // Error handling method
  MyError _handleError(DioException error) {
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

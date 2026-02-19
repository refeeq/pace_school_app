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

  static const String _logTag = 'API';

  /// Converts request body to a loggable string (expands FormData fields/files).
  dynamic _bodyToLoggable(dynamic body) {
    if (body == null) return null;
    if (body is FormData) {
      final map = <String, dynamic>{};
      for (final e in body.fields) {
        map[e.key] = e.value;
      }
      for (final e in body.files) {
        final f = e.value;
        map[e.key] = '<file: ${f.filename ?? "unknown"} length=${f.length}>';
      }
      return map;
    }
    return body;
  }

  void _logRequest(String method, String url,
      {Map<String, dynamic>? queryParams, dynamic body}) {
    log('[$_logTag] --> $method $url', name: _logTag);
    if (queryParams != null && queryParams.isNotEmpty) {
      log('[$_logTag]     query: $queryParams', name: _logTag);
    }
    if (body != null) {
      log('[$_logTag]     body: ${_bodyToLoggable(body)}', name: _logTag);
    }
  }

  void _logResponse(String url, dynamic data, [int? statusCode]) {
    final status = statusCode != null ? ' [$statusCode]' : '';
    log('[$_logTag] <-- $url$status', name: _logTag);
    // Use short messages for verbose APIs instead of full response
    if (url.contains('getNotifications')) {
      log('[$_logTag]     getNotifications response fetched successfully', name: _logTag);
    } else if (url.contains('studentDetails')) {
      log('[$_logTag]     studentDetails response fetched successfully', name: _logTag);
    } else if (url.contains('studentProfile')) {
      log('[$_logTag]     studentProfile response fetched successfully', name: _logTag);
    } else if (url.contains('getCommunications')) {
      log('[$_logTag]     getCommunications response fetched successfully', name: _logTag);
    } else if (url.contains('studentMenu')) {
      log('[$_logTag]     studentMenu response fetched successfully', name: _logTag);
    } else if (url.contains('studentCircular')) {
      log('[$_logTag]     studentCircular response fetched successfully', name: _logTag);
    } else if (url.contains('progrssReport')) {
      log('[$_logTag]     progress report response fetched successfully', name: _logTag);
    } else {
      log('[$_logTag]     response: $data', name: _logTag);
    }
  }

  void _logError(String url, Object e, [dynamic responseData]) {
    log('[$_logTag] ERROR $url', name: _logTag);
    log('[$_logTag]     exception: $e', name: _logTag);
    if (responseData != null) {
      log('[$_logTag]     response: $responseData', name: _logTag);
    }
  }

  /// Decodes response.data whether it's already Map/List or a JSON String.
  dynamic _decodeResponse(dynamic data) {
    if (data is Map || data is List) return data;
    if (data is String) return json.decode(data);
    return data;
  }

  // GET request
  Future<Either<MyError, dynamic>> getRequest(
    String endpoint,
    String? token, {
    Map<String, dynamic>? queryParameters,
  }) async {
    _logRequest('GET', endpoint, queryParams: queryParameters);
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
      final decoded = _decodeResponse(response.data);
      _logResponse(endpoint, decoded, response.statusCode);
      return Right(decoded);
    } on DioException catch (e) {
      _logError(endpoint, e, e.response?.data);
      return Left(_handleError(e));
    }
  }

  // POST request
  Future<Either<MyError, dynamic>> postAPI({
    dynamic body,
    String url = '',
    String authorization = '',
  }) async {
    _logRequest('POST', url, body: body);
    try {
      final headers = <String, dynamic>{
        'Accept': 'application/json',
        if (authorization.isNotEmpty) 'token': authorization,
      };
      if (body is! FormData) {
        headers['Content-Type'] = 'application/json';
      }
      _dio.options = BaseOptions(headers: headers);
      final response = await _dio.post(url, data: body);
      final decoded = _decodeResponse(response.data);
      _logResponse(url, decoded, response.statusCode);
      return Right(decoded);
    } on DioException catch (e) {
      _logError(url, e, e.response?.data);
      return Left(_handleError(e));
    }
  }

  // PUT request
  Future<Either<MyError, dynamic>> putRequest(
    String endpoint,
    String? token,
    dynamic data,
  ) async {
    _logRequest('PUT', endpoint, body: data);
    try {
      _dio.options = BaseOptions(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'token': token,
        },
      );
      final response = await _dio.put(endpoint, data: data);
      final decoded = _decodeResponse(response.data);
      _logResponse(endpoint, decoded, response.statusCode);
      return Right(decoded);
    } on DioException catch (e) {
      _logError(endpoint, e, e.response?.data);
      return Left(_handleError(e));
    }
  }

  // DELETE request
  Future<Either<MyError, dynamic>> deleteRequest(
    String endpoint,
    String? token,
  ) async {
    _logRequest('DELETE', endpoint);
    try {
      _dio.options = BaseOptions(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'token': token,
        },
      );
      final response = await _dio.delete(endpoint);
      _logResponse(endpoint, response.data, response.statusCode);
      return Right(response.data);
    } on DioException catch (e) {
      _logError(endpoint, e, e.response?.data);
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

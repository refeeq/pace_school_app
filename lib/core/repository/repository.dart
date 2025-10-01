// ignore_for_file: non_constant_identifier_names

import 'package:either_dart/either.dart';
import 'package:school_app/core/error/error_exception.dart';
import 'package:school_app/core/models/login_response_model.dart';
import 'package:school_app/core/models/otp_response_model.dart';

abstract class Repository {
  Future<Either<MyError, LoginResponseModel>> login({
    required String admission_no,
    required String phone_no,
  });
  Future<Either<MyError, OtpResponseModel?>> setFcmToken();
  Future<Either<MyError, OtpResponseModel?>> verifyOtp({
    required String phone_no,
    required String otp_code,
    required String token,
  });
}

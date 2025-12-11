import 'package:either_dart/either.dart';
import 'package:school_app/core/error/error_exception.dart';

abstract class BaseAPIConfig {
  Future<Either<MyError, dynamic>> getAPI({String authorization, String url});

  Future<Either<MyError, dynamic>> postAPI({
    dynamic body,
    String url,
    String authorization,
  });
}

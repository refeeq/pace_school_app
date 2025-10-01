import 'package:either_dart/either.dart';
import 'package:school_app/core/error/error_exception.dart';
import 'package:school_app/core/models/school_info_model.dart';

abstract class SchoolRepository {
  Future<Either<MyError, SchoolInfoModel?>> getSchoolInfo();
}

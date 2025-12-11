import 'package:either_dart/either.dart';
import 'package:school_app/core/error/error_exception.dart';

abstract class AttendanceRepository {
  Future<Either<MyError, dynamic>> getAttendance({
    required String month,
    required String year,
    String? studentId,
  });
}

import 'package:either_dart/either.dart';
import 'package:school_app/core/error/error_exception.dart';

abstract class LeaveApplicationRepository {
  Future<Either<MyError, dynamic>> applyLeaveApplication({
    required String fromDate,
    required String endDate,
    required String reasonId,
    required String reason,
    required String studentId,
  });
  Future<Either<MyError, dynamic>> getLeaveList({required String studentId});
  Future<Either<MyError, dynamic>> getLeaveResonList();
}

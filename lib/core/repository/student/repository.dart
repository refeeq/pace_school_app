import 'package:either_dart/either.dart';
import 'package:school_app/core/error/error_exception.dart';
import 'package:school_app/core/models/fee_response_model.dart';
import 'package:school_app/core/models/fees_list_model.dart';
import 'package:school_app/core/models/fees_model.dart';
import 'package:school_app/core/models/student_detail_model.dart';
import 'package:school_app/core/models/student_menu_model.dart';
import 'package:school_app/core/models/students_model.dart';

abstract class StudentRepository {
  Future<Either<MyError, dynamic>> getProgressReport({
    required String studCode,
  });
  Future<Either<MyError, StudentDetailModel>> getStudentDetails({
    required String studCode,
  });
  Future<Either<MyError, FeeListModel>> getStudentFee({
    required String studCode,
  });
  Future<Either<MyError, dynamic>> getStudentFeeStatement({
    required String studCode,
    required int limitTwo,
  });
  Future<Either<MyError, FeeResponseModel>> getStudentFeeSubmit({
    required String studCode,
    required List<FeesModel> list,
  });
  Future<Either<MyError, StudentMenuModel>> getStudentMenu({
    required String studCode,
  });
  Future<Either<MyError, StudentsModel>> getStudents();
  Future<Either<MyError, dynamic>> progressReport({
    required String studCode,
    examId,
    accId,
  });
  Future<Either<MyError, dynamic>> updateStudentDocumentDetails({
    required String studCode,
    required String emiratesId,
    required String emiratesIdExp,
  });
  Future<Either<MyError, dynamic>> viewStudentRcpts({
    required String studCode,
    no,
    type,
  });
  Future<Either<MyError, dynamic>> getReportNamesByClass({
    required String admissionNo,
  });
  Future<Either<MyError, dynamic>> getReportCardHtml({
    required String reportId,
    required String exmId,
    required String acYearId,
    required String admissionNo,
  });
}

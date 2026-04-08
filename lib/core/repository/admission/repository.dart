import 'package:either_dart/either.dart';
import 'package:school_app/core/error/error_exception.dart';
import 'package:school_app/core/models/siblinf_register_model.dart';

abstract class AdmissionRepository {
  Future<Either<MyError, dynamic>> fetchRegistrations();
  Future<Either<MyError, dynamic>> getAdmissionData();
  Future<Either<MyError, dynamic>> getGuestAdmissionData();
  Future<Either<MyError, dynamic>> submitGuestAdmission(
    SiblingRegisterModel siblingRegisterModel,
  );
  Future<Either<MyError, dynamic>> submitSibilingAdmission(
    SiblingRegisterModel siblingRegisterModel,
  );
}

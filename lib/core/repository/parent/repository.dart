import 'package:either_dart/either.dart';
import 'package:school_app/core/error/error_exception.dart';
import 'package:school_app/core/models/parent_profile_list_model.dart';
import 'package:school_app/core/models/parent_profile_model.dart';

abstract class ParentRepository {
  Future<Either<MyError, ParentProfileModel>> getParentProfile();
  Future<Either<MyError, ParentProfileListModel>> getParentProfileList();
  Future<Either<MyError, dynamic>> updateParentEmail({
    required String email,
    required String relation,
  });
  Future<Either<MyError, dynamic>> updateParentEmailOtp({
    required String email,
    required String relation,
    required String otp,
  });
}

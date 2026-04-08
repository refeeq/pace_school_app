import 'package:either_dart/either.dart';
import 'package:school_app/core/error/error_exception.dart';
import 'package:school_app/core/models/parent_update_request_model.dart';

abstract class ParentUpdateRepository {
  Future<Either<MyError, dynamic>> requestStudentPassportUpdate({
    required String admissionNo,
    String? passportNumber,
    required String expiryDate,
    required String documentPath,
  });

  Future<Either<MyError, dynamic>> requestStudentEidUpdate({
    required String admissionNo,
    required String emiratesId,
    required String expiryDate,
    required String documentPath,
  });

  Future<Either<MyError, dynamic>> requestStudentPhotoUpdate({
    required String admissionNo,
    required String photoPath,
  });

  Future<Either<MyError, dynamic>> requestFatherPhotoUpdate({
    required String photoPath,
  });

  Future<Either<MyError, dynamic>> requestMotherPhotoUpdate({
    required String photoPath,
  });

  Future<Either<MyError, dynamic>> requestFatherEmailUpdate({
    required String email,
  });

  Future<Either<MyError, dynamic>> requestFatherEidUpdate({
    required String emiratesId,
    required String expiryDate,
    required String documentPath,
  });

  Future<Either<MyError, dynamic>> requestMotherEidUpdate({
    required String emiratesId,
    required String expiryDate,
    required String documentPath,
  });

  Future<Either<MyError, dynamic>> requestAddressUpdate({
    String? homeAddress,
    String? flatNo,
    String? buildingName,
    String? comNumber,
    int? communityId,
  });

  Future<Either<MyError, ParentUpdateRequestListModel>>
      getParentUpdateRequests();
}

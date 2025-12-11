import 'package:either_dart/either.dart';
import 'package:school_app/core/error/error_exception.dart';

abstract class CommunicationRepository {
  Future<Either<MyError, dynamic>> getStudentList();
  Future<Either<MyError, dynamic>> getCommunicationTileList(String studentId);
  Future<Either<MyError, dynamic>> getCommunicationDetails(
    String studentId,
    String id,
    int page,
  );
}

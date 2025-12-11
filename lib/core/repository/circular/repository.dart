import 'package:either_dart/either.dart';
import 'package:school_app/core/error/error_exception.dart';

abstract class CircularRepository {
  Future<Either<MyError, dynamic>> getCircular({String? studCode});
  Future<Either<MyError, dynamic>> getParentCircular();
}

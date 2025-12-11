import 'package:either_dart/either.dart';
import 'package:school_app/core/error/error_exception.dart';

abstract class GuestRepository {
  Future<Either<MyError, dynamic>> getGuestMenue();
}

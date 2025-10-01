import 'package:either_dart/either.dart';
import 'package:school_app/core/error/error_exception.dart';

abstract class NotificationRepository {
  Future<Either<MyError, dynamic>> getAllNotifications(int pageNumber);
  Future<Either<MyError, dynamic>> readNotifiction(String id);
}

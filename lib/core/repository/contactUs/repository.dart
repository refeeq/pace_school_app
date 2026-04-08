import 'package:either_dart/either.dart';
import 'package:school_app/core/error/error_exception.dart';
import 'package:school_app/core/models/contact_us_history_model.dart';

abstract class ContactUsRepository {
  Future<Either<MyError, dynamic>> submitContactForm({
    required String name,
    required String email,
    required String phone,
    required String message,
  });
  Future<Either<MyError, dynamic>> submitGuestContactForm({
    required String name,
    required String email,
    required String phone,
    required String message,
  });
  Future<Either<MyError, List<ContactUsHistoryItem>>> getContactUsHistory();
}

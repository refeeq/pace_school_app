import 'dart:developer';

import 'package:either_dart/either.dart';
import 'package:school_app/core/constants/api_constants.dart';
import 'package:school_app/core/error/error_exception.dart';
import 'package:school_app/core/repository/guest/repository.dart';
import 'package:school_app/core/services/api_services.dart';

class GuestRepositoryImpl implements GuestRepository {
  final DioAPIServices apiServices;

  GuestRepositoryImpl(this.apiServices);
  @override
  Future<Either<MyError, dynamic>> getGuestMenue() async {
    var response = await apiServices.postAPI(url: ApiConstatns.getGuestMenu);

    if (response.isLeft) {
      log(response.left.message!);
      return Left(response.left);
    } else {
      if (response.right['status'] == false) {
        log(response.right.toString());
        log(response.right['message']);
        return const Right([]);
      } else {
        //  showToast(response.right['message']);
        log(response.right.toString());

        return Right(response.right);
      }
    }
  }
}

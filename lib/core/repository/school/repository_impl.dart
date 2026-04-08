import 'dart:developer';

import 'package:either_dart/either.dart';
import 'package:school_app/core/constants/api_constants.dart';
import 'package:school_app/core/error/error_exception.dart';
import 'package:school_app/core/models/school_info_model.dart';
import 'package:school_app/core/repository/school/repository.dart';
import 'package:school_app/core/services/api_services.dart';

class SchoolRepositoyImpl implements SchoolRepository {
  final DioAPIServices apiServices;

  SchoolRepositoyImpl(this.apiServices);

  @override
  Future<Either<MyError, SchoolInfoModel?>> getSchoolInfo() async {
    var response = await apiServices.postAPI(url: ApiConstatns.getSchoolInfo);

    log(response.right.toString());

    if (response.isLeft) {
      log(response.left.message!);
      return Left(response.left);
    } else {
      if (response.right['status'] == true) {
        log(response.right.toString());
        return Right(SchoolInfoModel.fromJson(response.right['data']));
      } else {
        //  showToast(response.right['message']);
        return const Right(null);
      }
    }
  }
}

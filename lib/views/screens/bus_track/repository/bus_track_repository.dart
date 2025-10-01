import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:school_app/core/constants/api_constants.dart';
import 'package:school_app/core/constants/db_constants.dart';
import 'package:school_app/core/error/error_exception.dart';
import 'package:school_app/core/models/auth_model.dart';
import 'package:school_app/core/services/api_services.dart';
import 'package:school_app/views/screens/bus_track/models/bus_track_model.dart';

class BusTrackRepository {
  final DioAPIServices dioAPIServices;

  BusTrackRepository({required this.dioAPIServices});

  Future<Either<MyError, BusTrackModel>> getTracking({
    required String admissionNo,
  }) async {
    var userData = Hive.box<AuthModel>(USERDB);
    userData.values;
    AuthModel authModel = userData.get(0) as AuthModel;
    var data = FormData.fromMap({
      "token": authModel.token,
      "famcode": authModel.famcode,
      "admission_no": admissionNo,
    });
    var res = await dioAPIServices.postAPI(
      body: data,
      url: ApiConstatns.getTracking,
    );
    if (res.isLeft) {
      return Left(res.left);
    } else {
      return Right(BusTrackModel.fromJson(res.right));
    }
  }
}

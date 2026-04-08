import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:school_app/core/services/dependecyInjection.dart';
import 'package:school_app/views/screens/bus_track/models/bus_track_data_model.dart';
import 'package:school_app/views/screens/bus_track/repository/bus_track_repository.dart';

part 'bus_track_cubit.freezed.dart';
part 'bus_track_state.dart';

class BusTrackCubit extends Cubit<BusTrackState> {
  final BusTrackRepository busTrackRepository = locator<BusTrackRepository>();
  BusTrackCubit() : super(const BusTrackState.initial());

  Future<void> getTracking({required String admissionNo}) async {
    emit(const BusTrackState.loading());
    var res = await busTrackRepository.getTracking(admissionNo: admissionNo);
    if (res.isLeft) {
      emit(BusTrackState.failure(res.left.message ?? "Something went wrong"));
    } else {
      if (res.right.status!) {
        if (res.right.data != null) {
          log(res.right.data!.toJson().toString());
          emit(BusTrackState.success(res.right.data!));
        } else {
          emit(
            BusTrackState.failure(
              res.right.message ?? 'Something went wrong (no data)',
            ),
          );
        }
      } else {
        emit(
          BusTrackState.failure(res.right.message ?? "Something went wrong"),
        );
      }
    }
  }
}

import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_app/core/services/dependecyInjection.dart';
import 'package:school_app/views/screens/open_house/model/active_open_house_model.dart';
import 'package:school_app/views/screens/open_house/model/add_open_house_model.dart';
import 'package:school_app/views/screens/open_house/model/open_house_model.dart';
import 'package:school_app/views/screens/open_house/repository/open_house_repository.dart';

part 'open_house_event.dart';
part 'open_house_state.dart';

class OpenHouseBloc extends Bloc<OpenHouseEvent, OpenHouseState> {
  final OpenHouseRepository openHouseRepository =
      locator<OpenHouseRepository>();
  OpenHouseBloc() : super(OpenHouseInitial()) {
    on<OpenHouseEvent>((event, emit) {});
    on<OpenHouseLoadEvent>((event, emit) async {
      emit(OpenHouseLoadingState());
      var res = await openHouseRepository.getOpenHouse(event.studeCode);
      log(res.isLeft.toString());
      res.fold(
        (left) {
          emit(OpenHouseErrorState(message: left.message!));
        },
        (right) {
          log(right.toString());
          emit(
            OpenHouseLoadedState(
              activeOpenHouseList: right.activeOpenHouseList,
              openHouseList: right.openHouseList,
            ),
          );
        },
      );
    });
    on<AddOpenHouseEvent>((event, emit) async {
      emit(OpenHouseBookingLoadingState());
      var res = await openHouseRepository.bookOpenHouse(
        event.studeCode,
        event.openHouseModels,
        event.ohMainId,
      );
      log(res.isLeft.toString());
      res.fold(
        (left) => emit(OpenHouseErrorState(message: left.message!)),
        (right) => emit(OpenHouseBookingSuccessState(message: right)),
      );
    });
  }
}

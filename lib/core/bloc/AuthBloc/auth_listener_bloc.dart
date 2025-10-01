import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:school_app/core/error/error_exception.dart';
import 'package:school_app/core/repository/student/repository.dart';
import 'package:school_app/core/services/dependecyInjection.dart';

import '../../constants/db_constants.dart';
import '../../models/auth_model.dart';

part 'auth_listener_event.dart';
part 'auth_listener_state.dart';

class AuthListenerBloc extends Bloc<AuthListenerEvent, AuthListenerState> {
  StudentRepository repository = locator<StudentRepository>();

  AuthListenerBloc() : super(AuthInitial()) {
    on<AuthStateChanged>((event, emit) async {
      //await PushNotificationService().init();

      final isLoggedIn = Hive.box<AuthModel>(USERDB).isNotEmpty;
      if (isLoggedIn) {
        var response = await repository.getStudents();
        if (response.isLeft) {
          if (response.left.key == AppError.unauthorized) {
            await Hive.box<AuthModel>(USERDB).clear();
            emit(AuthLoggedOut());
            log("Token error. Logging out...");
            return; // Don't proceed to the next emit(AuthLoggedOut())
          }
        }
        log("response: $response");
        emit(AuthLoggedIn());
      } else {
        emit(AuthLoggedOut());
      }
    });

    on<AuthLoggedInEvent>((event, emit) {
      emit(AuthLoggedIn());
    });
    on<AuthLoggedOutEvent>(_mapLogoutButtonPressedToState);
  }

  void _mapLogoutButtonPressedToState(
    AuthLoggedOutEvent event,
    Emitter<AuthListenerState> emitter,
  ) async {
    await Hive.box<AuthModel>(USERDB).clear();
    log("_mapLogoutButtonPressedToState");
    emitter(AuthLoggedOut());
  }
}

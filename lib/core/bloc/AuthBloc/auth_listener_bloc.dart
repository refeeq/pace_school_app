import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:school_app/core/notification/fcm_topic_service.dart';

import '../../constants/db_constants.dart';
import '../../models/auth_model.dart';

part 'auth_listener_event.dart';
part 'auth_listener_state.dart';

class AuthListenerBloc extends Bloc<AuthListenerEvent, AuthListenerState> {
  AuthListenerBloc() : super(AuthInitial()) {
    on<AuthStateChanged>((event, emit) async {
      final isLoggedIn = Hive.box<AuthModel>(USERDB).isNotEmpty;
      if (isLoggedIn) {
        // Emit AuthLoggedIn immediately; token validation happens on first API call.
        // If any API returns 401, api_services clears Hive and ValueListenableBuilder
        // in AuthListener will show LoginScreen.
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
    // Unsubscribe from FCM topics before clearing auth data
    try {
      await FcmTopicService.unsubscribeFromAllTopics();
      log("FCM topics unsubscribed on logout");
    } catch (e) {
      log("Error unsubscribing from FCM topics on logout: $e");
      // Continue with logout even if topic unsubscription fails
    }
    
    await Hive.box<AuthModel>(USERDB).clear();
    log("_mapLogoutButtonPressedToState");
    emitter(AuthLoggedOut());
  }
}

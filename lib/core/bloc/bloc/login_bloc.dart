import 'dart:developer';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:school_app/core/repository/repository.dart';

import '../../constants/db_constants.dart';
import '../../models/auth_model.dart';
import '../../services/dependecyInjection.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  Repository repository = locator<Repository>();
  LoginBloc() : super(LoginInitial()) {
    on<LoginButtonPressEvent>(_mapLogginButtonClick);
    on<OtpVerifyingEvent>(_mapOTPButtonClick);
    on<OtpResendEvent>(_mapOtpResendButtonClick);
  }

  void _mapLogginButtonClick(
    LoginButtonPressEvent event,
    Emitter<LoginState> emitter,
  ) async {
    emitter(LoginLoading());
    var respon = await repository.login(
      admission_no: event.addmissionNumber,
      phone_no: event.number,
    );
    if (respon.isLeft) {
      emitter(
        LoginFailed(message: respon.left.message ?? "Something went wrong !"),
      );
      emitter(LoginInitial());
    } else {
      if (respon.right.status == true) {
        emitter(
          LoginSuccess(
            message: respon.right.message,
            adm: event.addmissionNumber,
            number: event.number,
          ),
        );
      } else {
        //   Navigator.of(event.context).pop();
        emitter(LoginFailed(message: respon.right.message));
        emitter(LoginInitial());
      }
    }
    // emitter(LoggedOut());
  }

  //
  void _mapOTPButtonClick(
    OtpVerifyingEvent event,
    Emitter<LoginState> emitter,
  ) async {
    emitter(OtpLoading());
    String? token;

    try {
      if (Platform.isAndroid) {
        final status = await Permission.notification.status;
        if (status.isGranted) {
          token = await FirebaseMessaging.instance.getToken();
        } else {
          await FirebaseMessaging.instance.requestPermission();
          token = await FirebaseMessaging.instance.getToken();
        }
      } else {
        // var settings = await FirebaseMessaging.instance.getNotificationSettings();
        // if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        //   token = await FirebaseMessaging.instance.getToken();
        // } else {
        //   await FirebaseMessaging.instance.requestPermission();
        //   token = await FirebaseMessaging.instance.getToken();
        // }
      }
    } catch (e) {
      log("Firebase Messaging error: $e");
      token = "No Token Available";
    }

    if (kDebugMode) {
      print("fcm token:$token");
    }
    log("fcm token:$token");
    var respon = await repository.verifyOtp(
      otp_code: event.otpNumber,
      phone_no: event.phonenumber,
      token: token ?? "No Token",
    );
    if (respon.isLeft) {
      emitter(
        OtpFailed(message: respon.left.message ?? "Something went wrong !"),
      );
      emitter(LoginInitial());
    } else {
      if (respon.right!.status == true) {
        Hive.box<AuthModel>(USERDB).add(
          AuthModel(respon.right!.data!.token, respon.right!.data!.famcode),
        );
        emitter(OtpSuccess(respon.right!.message));
      } else {
        emitter(OtpFailed(message: respon.right!.message));
        emitter(LoginInitial());
      }
    }
    // emitter(LoggedOut());
  }

  void _mapOtpResendButtonClick(
    OtpResendEvent event,
    Emitter<LoginState> emitter,
  ) async {
    emitter(LoginLoading());

    var respon = await repository.login(
      admission_no: event.addmissionNumber,
      phone_no: event.number,
    );
    if (respon.isLeft) {
      emitter(
        OtpFailed(message: respon.left.message ?? "Something went wrong !"),
      );
    } else {
      if (respon.right.status == true) {
        emitter(OtpResendSuccessState(message: respon.right.message));
      } else {
        //  Navigator.of(event.context).pop();
        emitter(
          OtpFailed(message: respon.left.message ?? "Something went wrong !"),
        );
      }
    }
    // emitter(LoggedOut());
  }
}

// need to integrate ths with the ui and other parts

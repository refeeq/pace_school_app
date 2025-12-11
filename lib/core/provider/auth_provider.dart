// ignore_for_file: constant_identifier_names, use_build_context_synchronously

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:school_app/core/constants/db_constants.dart';
import 'package:school_app/core/models/auth_model.dart';
import 'package:school_app/core/repository/repository.dart';
import 'package:school_app/core/services/dependecyInjection.dart';
import 'package:school_app/core/utils/utils.dart';
import 'package:school_app/views/screens/student/login_screen/otp_verify_screen.dart';

import '../../views/screens/home_screen/bottom_nav.dart';

class AuthProvider with ChangeNotifier {
  Repository repository = locator<Repository>();
  AuthState authState = AuthState.Unintialized;
  Future<void> login({
    required String admission,
    required String phone,
    required BuildContext context,
    required bool isResend,
  }) async {
    var respon = await repository.login(
      admission_no: admission,
      phone_no: phone,
    );
    if (respon.isLeft) {
      log(respon.left.message.toString());
      log(respon.left.key.toString());
    } else {
      if (respon.right.status == true) {
        authState = AuthState.OtpSended;
        // SnackBar(content: Text(respon.right.message));
        //   showToast(respon.right.message, context);
        Navigator.of(context).pop();
        if (!isResend) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  OTpVerify(phoneNumber: phone, admission: admission),
            ),
          );
        }

        log(respon.right.message);
      } else {
        log(respon.right.message);

        // Find the ScaffoldMessenger in the widget tree
        // and use it to show a SnackBar.
        showToast(respon.right.message, context);
        Navigator.of(context).pop();
      }

      // Hive.box<AuthModel>('userBox')
      //     .add(AuthModel(respon.right.data.token, respon.right.data.famcode));
    }

    notifyListeners();
  }

  Future<void> otpVerify({
    required String otpCode,
    required String phoneNo,
    required BuildContext context,
  }) async {
    var token = await Hive.box('token').get("firebaseToken");
    var respon = await repository.verifyOtp(
      otp_code: otpCode,
      phone_no: phoneNo,
      token: token,
    );
    if (respon.isLeft) {
      //  showToast(respon.left.message.toString());
      Navigator.pop(context);
      log(respon.left.message.toString());
      log(respon.left.key.toString());
    } else {
      Navigator.pop(context);
      if (respon.right != null) {
        //  showToast(respon.right!.message, context);
        Hive.box<AuthModel>(USERDB).add(
          AuthModel(respon.right!.data!.token, respon.right!.data!.famcode),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreenView()),
          (route) => false,
        );
        //  Navigator.push(
        // context,
      }
    }
  }
}

enum AuthState { Unintialized, OtpSended, VzerificationSucccess }

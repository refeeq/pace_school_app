// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:observe_internet_connectivity/observe_internet_connectivity.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/config/app_status.dart';
import 'package:school_app/core/models/admission_det_model.dart';
import 'package:school_app/core/models/siblinf_register_model.dart';
import 'package:school_app/core/repository/admission/repository.dart';
import 'package:school_app/core/utils/utils.dart';
import 'package:school_app/views/screens/sibilingRegister/cubit/sibiling_registration_cubit.dart';

import '../services/dependecyInjection.dart';

class AdmissionRegisterProvider with ChangeNotifier {
  String? residancy;
  String? sibiling;
  String? transportation;
  AdmissionRepository repository = locator<AdmissionRepository>();

  AppStates admissionFormState = AppStates.Unintialized;

  AdmissionResModel? admissionResModel;

  AppStates guestAdmissionFormState = AppStates.Unintialized;
  AdmissionResModel? guestAdmissionResModel;
  AppStates submitAdmissionFormState = AppStates.Unintialized;
  String error = '';

  AppStates submitGuestAdmissionFormState = AppStates.Unintialized;

  Future<void> admissionregister(
    SiblingRegisterModel registerModel,
    BuildContext context,
  ) async {
    error = '';
    showAlertLoader(context);
    submitAdmissionFormState = AppStates.Initial_Fetching;
    bool hasInternet = await InternetConnectivity().hasInternetConnection;
    if (!hasInternet) {
      submitAdmissionFormState = AppStates.NoInterNetConnectionState;
    } else {
      var respon = await repository.submitSibilingAdmission(registerModel);
      if (respon.isLeft) {
        Navigator.pop(context);
        log(respon.left.message.toString());
        log(respon.left.key.toString());
        error = "Something went wrong !";
        showToast(error, context);
        submitAdmissionFormState = AppStates.Error;
      } else {
        Navigator.pop(context);
        if (respon.right == null) {
          error = "Something went wrong !";
          showToast(error, context);
          submitGuestAdmissionFormState = AppStates.Error;
        } else {
          log("response ${respon.right}");
          if (respon.right['status'] == true) {
            error = respon.right["message"];

            submitAdmissionFormState = AppStates.Fetched;
            context.read<SibilingRegistrationCubit>().fetchUsers();
          } else {
            error = respon.right["message"];
            showToast(error, context);
            submitAdmissionFormState = AppStates.Error;
          }

          // showToast(respon.right.message);
          log(respon.right.toString());
          //  admissionResModel = respon.right;
        }
      }
    }
    notifyListeners();
  }

  Future<void> getAdmissionData() async {
    admissionFormState = AppStates.Initial_Fetching;
    bool hasInternet = await InternetConnectivity().hasInternetConnection;
    if (!hasInternet) {
      admissionFormState = AppStates.NoInterNetConnectionState;
    } else {
      var respon = await repository.getAdmissionData();
      if (respon.isLeft) {
        log(respon.left.message.toString());
        log(respon.left.key.toString());
        admissionFormState = AppStates.Error;
      } else {
        admissionFormState = AppStates.Fetched;
        if (respon.right == null) {
        } else {
          //  showToast(respon.right.message);
          log(respon.right.toString());
          admissionResModel = respon.right;
        }
      }
    }
    notifyListeners();
  }

  Future<void> getGuestAdmissionData() async {
    guestAdmissionFormState = AppStates.Initial_Fetching;
    bool hasInternet = await InternetConnectivity().hasInternetConnection;
    if (!hasInternet) {
      guestAdmissionFormState = AppStates.NoInterNetConnectionState;
    } else {
      var respon = await repository.getGuestAdmissionData();
      if (respon.isLeft) {
        log(respon.left.message.toString());
        log(respon.left.key.toString());
        guestAdmissionFormState = AppStates.Error;
      } else {
        guestAdmissionFormState = AppStates.Fetched;
        if (respon.right == null) {
        } else {
          //  showToast(respon.right.message);
          log(respon.right.toString());
          guestAdmissionResModel = respon.right;
        }
      }
    }
    notifyListeners();
  }

  Future<void> guestAdmissionregister(
    SiblingRegisterModel registerModel,
    BuildContext context,
  ) async {
    error = '';
    showAlertLoader(context);
    submitGuestAdmissionFormState = AppStates.Initial_Fetching;
    bool hasInternet = await InternetConnectivity().hasInternetConnection;
    if (!hasInternet) {
      submitGuestAdmissionFormState = AppStates.NoInterNetConnectionState;
    } else {
      var respon = await repository.submitGuestAdmission(registerModel);
      if (respon.isLeft) {
        Navigator.pop(context);
        log(respon.left.message.toString());
        log(respon.left.key.toString());
        error = "Something went wrong !";
        showToast(error, context);
        submitGuestAdmissionFormState = AppStates.Error;
      } else {
        Navigator.pop(context);

        if (respon.right == null) {
          error = "Something went wrong !";
          showToast(error, context);
          submitGuestAdmissionFormState = AppStates.Error;
        } else {
          if (respon.right['status'] == true) {
            error = error = respon.right["message"];

            submitGuestAdmissionFormState = AppStates.Fetched;
          } else {
            error = respon.right["message"];
            showToast(error, context);
            submitGuestAdmissionFormState = AppStates.Error;
          }

          // showToast(respon.right.message);
          log(respon.right.toString());
          //  admissionResModel = respon.right;
        }
      }
    }
    notifyListeners();
  }

  void updateResidency(String value) {
    residancy = value;
    notifyListeners();
  }

  void updateSate() {
    submitAdmissionFormState = AppStates.Unintialized;
    guestAdmissionFormState = AppStates.Unintialized;
    submitAdmissionFormState = AppStates.Unintialized;
    submitGuestAdmissionFormState = AppStates.Unintialized;
    notifyListeners();
  }

  void updateSibiling(String value) {
    sibiling = value;
    notifyListeners();
  }

  void updateTransportation(String value) {
    transportation = value;
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'package:observe_internet_connectivity/observe_internet_connectivity.dart';
import 'package:school_app/core/config/app_status.dart';
import 'package:school_app/core/repository/contactUs/repository.dart';
import 'package:school_app/core/services/dependecyInjection.dart';
import 'package:school_app/core/utils/utils.dart';

class ContactUsProvider with ChangeNotifier {
  ContactUsRepository repository = locator<ContactUsRepository>();
  AppStates contactUsState = AppStates.Unintialized;
  AppStates guestContactUsState = AppStates.Unintialized;

  Future<void> submitContactUs({
    required String name,
    required String email,
    required String phone,
    required String message,
    required BuildContext context,
  }) async {
    showAlertLoader(context);
    contactUsState = AppStates.Initial_Fetching;
    bool hasInternet = await InternetConnectivity().hasInternetConnection;

    if (!hasInternet) {
      contactUsState = AppStates.NoInterNetConnectionState;
    } else {
      var res = await repository.submitContactForm(
        name: name,
        email: email,
        phone: phone,
        message: message,
      );
      if (res.isLeft) {
        showToast(res.left.message.toString(), context);
        Navigator.pop(context);
        contactUsState = AppStates.Error;
      } else {
        Navigator.pop(context);
        contactUsState = AppStates.Fetched;
      }
    }
    notifyListeners();
  }

  Future<void> submitGuestContactUs({
    required String name,
    required String email,
    required String phone,
    required String message,
    required BuildContext context,
  }) async {
    showAlertLoader(context);
    guestContactUsState = AppStates.Initial_Fetching;
    bool hasInternet = await InternetConnectivity().hasInternetConnection;

    if (!hasInternet) {
      guestContactUsState = AppStates.NoInterNetConnectionState;
    } else {
      var res = await repository.submitGuestContactForm(
        name: name,
        email: email,
        phone: phone,
        message: message,
      );
      if (res.isLeft) {
        showToast(res.left.message.toString(), context);
        Navigator.pop(context);
        guestContactUsState = AppStates.Error;
      } else {
        Navigator.pop(context);
        guestContactUsState = AppStates.Fetched;
      }
    }
    notifyListeners();
  }

  void updatesubmitContactUs() {
    contactUsState = AppStates.Unintialized;
    guestContactUsState = AppStates.Unintialized;
    notifyListeners();
  }
}

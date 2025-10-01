import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:observe_internet_connectivity/observe_internet_connectivity.dart';
import 'package:school_app/core/repository/contactUs/repository.dart';
import 'package:school_app/core/services/dependecyInjection.dart';

part 'contact_us_state.dart';

class ContactUsCubit extends Cubit<ContactUsState> {
  ContactUsRepository repository = locator<ContactUsRepository>();
  ContactUsCubit() : super(ContactUsInitial());

  Future<void> submitContactUs({
    required String name,
    required String email,
    required String phone,
    required String message,
  }) async {
    emit(ContactUsLoading());
    bool hasInternet = await InternetConnectivity().hasInternetConnection;
    if (!hasInternet) {
      emit(const ContactUsFailure(message: "No Internet connection"));
    }
    var res = await repository.submitContactForm(
      name: name,
      email: email,
      phone: phone,
      message: message,
    );
    if (res.isLeft) {
      emit(
        ContactUsFailure(
          message: res.left.message ?? "Something is went wrong",
        ),
      );
    } else {
      emit(ContactUsSuccess(message: res.right["message"]));
    }
  }

  Future<void> submitContactUsGuest({
    required String name,
    required String email,
    required String phone,
    required String message,
  }) async {
    emit(ContactUsLoading());
    bool hasInternet = await InternetConnectivity().hasInternetConnection;
    if (!hasInternet) {
      emit(const ContactUsFailure(message: "No Internet connection"));
    }
    var res = await repository.submitGuestContactForm(
      name: name,
      email: email,
      phone: phone,
      message: message,
    );
    if (res.isLeft) {
      emit(
        ContactUsFailure(
          message: res.left.message ?? "Something is went wrong",
        ),
      );
    } else {
      emit(ContactUsSuccess(message: res.right["message"]));
    }
  }
}

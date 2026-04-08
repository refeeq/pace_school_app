import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:observe_internet_connectivity/observe_internet_connectivity.dart';
import 'package:school_app/core/models/contact_us_history_model.dart';
import 'package:school_app/core/repository/contactUs/repository.dart';
import 'package:school_app/core/services/dependecyInjection.dart';

part 'contact_us_state.dart';

class ContactUsCubit extends Cubit<ContactUsState> {
  ContactUsRepository repository = locator<ContactUsRepository>();
  ContactUsCubit() : super(ContactUsState.initial);

  Future<void> loadContactUsHistory() async {
    emit(state.copyWith(historyLoading: true, historyError: null));
    bool hasInternet = await InternetConnectivity().hasInternetConnection;
    if (!hasInternet) {
      emit(state.copyWith(
        historyLoading: false,
        historyError: 'No Internet connection',
      ));
      return;
    }
    var res = await repository.getContactUsHistory();
    if (res.isLeft) {
      emit(state.copyWith(
        historyLoading: false,
        historyError: res.left.message ?? 'Failed to load history',
      ));
    } else {
      emit(ContactUsState(
        submissionLoading: state.submissionLoading,
        submissionSuccessMessage: null,
        submissionFailureMessage: null,
        historyLoading: false,
        historyList: res.right,
        historyError: null,
      ));
    }
  }

  Future<void> submitContactUs({
    required String name,
    required String email,
    required String phone,
    required String message,
  }) async {
    emit(state.copyWith(
      submissionLoading: true,
      submissionSuccessMessage: null,
      submissionFailureMessage: null,
    ));
    bool hasInternet = await InternetConnectivity().hasInternetConnection;
    if (!hasInternet) {
      emit(state.copyWith(
        submissionLoading: false,
        submissionFailureMessage: 'No Internet connection',
      ));
      return;
    }
    var res = await repository.submitContactForm(
      name: name,
      email: email,
      phone: phone,
      message: message,
    );
    if (res.isLeft) {
      emit(state.copyWith(
        submissionLoading: false,
        submissionFailureMessage:
            res.left.message ?? 'Something went wrong',
      ));
    } else {
      emit(state.copyWith(
        submissionLoading: false,
        submissionSuccessMessage: res.right['message']?.toString(),
      ));
      await loadContactUsHistory();
    }
  }

  Future<void> submitContactUsGuest({
    required String name,
    required String email,
    required String phone,
    required String message,
  }) async {
    emit(state.copyWith(
      submissionLoading: true,
      submissionSuccessMessage: null,
      submissionFailureMessage: null,
    ));
    bool hasInternet = await InternetConnectivity().hasInternetConnection;
    if (!hasInternet) {
      emit(state.copyWith(
        submissionLoading: false,
        submissionFailureMessage: 'No Internet connection',
      ));
      return;
    }
    var res = await repository.submitGuestContactForm(
      name: name,
      email: email,
      phone: phone,
      message: message,
    );
    if (res.isLeft) {
      emit(state.copyWith(
        submissionLoading: false,
        submissionFailureMessage:
            res.left.message ?? 'Something went wrong',
      ));
    } else {
      emit(state.copyWith(
        submissionLoading: false,
        submissionSuccessMessage: res.right['message']?.toString(),
      ));
    }
  }
}

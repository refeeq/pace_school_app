part of 'login_bloc.dart';

class LoginButtonPressEvent extends LoginEvent {
  final String number;
  final BuildContext context;
  final String addmissionNumber;

  const LoginButtonPressEvent({
    required this.number,
    required this.addmissionNumber,
    required this.context,
  });
  @override
  List<Object?> get props => [number, addmissionNumber, context];
}

class LoginCheckEvent extends LoginEvent {}

@immutable
class LoginEvent extends Equatable {
  const LoginEvent();
  @override
  List<Object?> get props => throw UnimplementedError();
}

class LogoutButtonPressEvent extends LoginEvent {}

class OtpResendEvent extends LoginEvent {
  final String number;
  final BuildContext context;
  final String addmissionNumber;

  const OtpResendEvent({
    required this.number,
    required this.addmissionNumber,
    required this.context,
  });
  @override
  List<Object?> get props => [number, addmissionNumber, context];
}

class OtpVerifyingEvent extends LoginEvent {
  final String otpNumber;
  final String phonenumber;
  final BuildContext buildContext;

  const OtpVerifyingEvent(
      {required this.otpNumber,
      required this.phonenumber,
      required this.buildContext});
  @override
  List<Object?> get props => [otpNumber, phonenumber, buildContext];
}

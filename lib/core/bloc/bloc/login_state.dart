part of 'login_bloc.dart';

class LoggedIn extends LoginState {}

class LoggedOut extends LoginState {}

class LoginFailed extends LoginState {
  final String message;

  const LoginFailed({required this.message});
  @override
  List<Object?> get props => [message];
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

@immutable
abstract class LoginState extends Equatable {
  const LoginState();
  @override
  List<Object?> get props => [];
}

class LoginSuccess extends LoginState {
  final String message;
  final String number;
  final String adm;
  const LoginSuccess(
      {required this.message, required this.number, required this.adm});
  @override
  List<Object?> get props => [
        message,
        number,
        adm,
      ];
}

class OtpFailed extends LoginState {
  final String message;

  const OtpFailed({required this.message});
  @override
  List<Object?> get props => [message];
}

class OtpLoading extends LoginState {}

class OtpResendState extends LoginState {}

class OtpResendSuccessState extends LoginState {
  final String message;

  const OtpResendSuccessState({required this.message});
  @override
  List<Object?> get props => [];
}

class OtpSuccess extends LoginState {
  final String message;

  const OtpSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

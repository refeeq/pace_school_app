part of 'auth_listener_bloc.dart';

abstract class AuthListenerEvent extends Equatable {
  const AuthListenerEvent();

  @override
  List<Object> get props => [];
}

class AuthLoggedInEvent extends AuthListenerEvent {
  // final Admin admin;

  // const AuthLoggedInEvent(this.admin);
  // @override
  // List<Object> get props => [admin];
}

class AuthLoggedOutEvent extends AuthListenerEvent {}

class AuthStateChanged extends AuthListenerEvent {
  const AuthStateChanged();

  @override
  List<Object> get props => [];
}

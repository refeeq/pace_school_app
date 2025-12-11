part of 'auth_listener_bloc.dart';

class AllowdNotificationPermissionState extends AuthListenerState {}

class AuthInitial extends AuthListenerState {}

abstract class AuthListenerState extends Equatable {
  const AuthListenerState();

  @override
  List<Object> get props => [];
}

class AuthLoggedIn extends AuthListenerState {}

class AuthLoggedOut extends AuthListenerState {}

class DeniedNotificationPermissionState extends AuthListenerState {}

part of 'sibiling_registration_cubit.dart';

final class SibilingRegistrationInitial extends SibilingRegistrationState {}

final class SibilingRegistrationListError extends SibilingRegistrationState {
  final String message;

  const SibilingRegistrationListError({required this.message});
}

final class SibilingRegistrationListFetched extends SibilingRegistrationState {
  final List<SiblingRegisterModel> list;

  const SibilingRegistrationListFetched({required this.list});
}

final class SibilingRegistrationListLoading extends SibilingRegistrationState {}

sealed class SibilingRegistrationState extends Equatable {
  const SibilingRegistrationState();

  @override
  List<Object> get props => [];
}

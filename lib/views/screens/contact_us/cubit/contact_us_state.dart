part of 'contact_us_cubit.dart';

final class ContactUsFailure extends ContactUsState {
  final String message;

  const ContactUsFailure({required this.message});
}

final class ContactUsInitial extends ContactUsState {}

final class ContactUsLoading extends ContactUsState {}

sealed class ContactUsState extends Equatable {
  const ContactUsState();

  @override
  List<Object> get props => [];
}

final class ContactUsSuccess extends ContactUsState {
  final String message;

  const ContactUsSuccess({required this.message});
}

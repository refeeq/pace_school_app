part of 'open_house_bloc.dart';

final class OpenHouseBookedState extends OpenHouseState {}

final class OpenHouseBookingErrorState extends OpenHouseState {
  final String message;

  const OpenHouseBookingErrorState({required this.message});
}

final class OpenHouseBookingLoadingState extends OpenHouseState {}

final class OpenHouseBookingSuccessState extends OpenHouseState {
  final String message;

  const OpenHouseBookingSuccessState({required this.message});
}

final class OpenHouseErrorState extends OpenHouseState {
  final String message;

  const OpenHouseErrorState({required this.message});
}

final class OpenHouseInitial extends OpenHouseState {}

final class OpenHouseLoadedState extends OpenHouseState {
  final List<OpenHouseModel> openHouseList;
  final List<ActiveOpenHouseModel> activeOpenHouseList;

  const OpenHouseLoadedState({
    required this.openHouseList,
    required this.activeOpenHouseList,
  });
}

final class OpenHouseLoadingState extends OpenHouseState {}

sealed class OpenHouseState extends Equatable {
  const OpenHouseState();

  @override
  List<Object> get props => [];
}

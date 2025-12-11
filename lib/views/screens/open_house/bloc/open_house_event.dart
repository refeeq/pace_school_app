part of 'open_house_bloc.dart';

final class AddOpenHouseEvent extends OpenHouseEvent {
  final String studeCode;
  final String ohMainId;
  final List<AddOpenHouseModel> openHouseModels;

  const AddOpenHouseEvent(
      {required this.studeCode,
      required this.openHouseModels,
      required this.ohMainId});
}

sealed class OpenHouseEvent extends Equatable {
  const OpenHouseEvent();

  @override
  List<Object> get props => [];
}

final class OpenHouseLoadEvent extends OpenHouseEvent {
  final String studeCode;

  const OpenHouseLoadEvent({required this.studeCode});
}

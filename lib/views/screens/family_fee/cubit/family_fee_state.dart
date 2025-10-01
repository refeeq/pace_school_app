part of 'family_fee_cubit.dart';

sealed class FamilyFeeState extends Equatable {
  final FamilyFeeModel? family;
  final bool status;

  const FamilyFeeState({
    this.family,
    required this.status,
  });

  @override
  List<Object> get props => [];
}

final class FamilyFeeInitial extends FamilyFeeState {
  const FamilyFeeInitial({
    super.family,
    required super.status,
  });
}

final class FamilyFeeFetchLoading extends FamilyFeeState {
  const FamilyFeeFetchLoading({
    super.family,
    required super.status,
  });
}

// ignore: must_be_immutable
final class FamilyFeeFetchSuccess extends FamilyFeeState {
  const FamilyFeeFetchSuccess({
    super.family,
    required super.status,
  });
}

final class FamilyFeeFetchError extends FamilyFeeState {
  final String message;

  const FamilyFeeFetchError({
    required this.message,
    super.family,
    required super.status,
  });
}

final class AmountUpdateState extends FamilyFeeState {
  const AmountUpdateState({
    super.family,
    required super.status,
  });
}

final class AmountUpdatesState extends FamilyFeeState {
  const AmountUpdatesState({
    super.family,
    required super.status,
  });
}

final class FamilyFeePay extends FamilyFeeState {
  const FamilyFeePay({
    required super.status,
    required super.family,
  });
}

final class FamilyFeePaySuccess extends FamilyFeeState {
  final String message;
  final String data;
  const FamilyFeePaySuccess({
    required super.status,
    super.family,
    required this.message,
    required this.data,
  });
}

final class FamilyFeePayError extends FamilyFeeState {
  final String message;
  const FamilyFeePayError({
    required super.status,
    required this.message,
  });
}

part of 'payment_cubit.dart';

@freezed
class PaymentState with _$PaymentState {
  const factory PaymentState.initial() = _Initial;
  const factory PaymentState.startPayment() = _Start;
  const factory PaymentState.paymentSdkSuccess() = _SuccessSdk;
  const factory PaymentState.paymentSdkFailure() = _FailureSdk;
}

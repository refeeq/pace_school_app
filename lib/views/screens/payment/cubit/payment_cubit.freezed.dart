// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PaymentState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() startPayment,
    required TResult Function() paymentSdkSuccess,
    required TResult Function() paymentSdkFailure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? startPayment,
    TResult? Function()? paymentSdkSuccess,
    TResult? Function()? paymentSdkFailure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? startPayment,
    TResult Function()? paymentSdkSuccess,
    TResult Function()? paymentSdkFailure,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Start value) startPayment,
    required TResult Function(_SuccessSdk value) paymentSdkSuccess,
    required TResult Function(_FailureSdk value) paymentSdkFailure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Start value)? startPayment,
    TResult? Function(_SuccessSdk value)? paymentSdkSuccess,
    TResult? Function(_FailureSdk value)? paymentSdkFailure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Start value)? startPayment,
    TResult Function(_SuccessSdk value)? paymentSdkSuccess,
    TResult Function(_FailureSdk value)? paymentSdkFailure,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaymentStateCopyWith<$Res> {
  factory $PaymentStateCopyWith(
          PaymentState value, $Res Function(PaymentState) then) =
      _$PaymentStateCopyWithImpl<$Res, PaymentState>;
}

/// @nodoc
class _$PaymentStateCopyWithImpl<$Res, $Val extends PaymentState>
    implements $PaymentStateCopyWith<$Res> {
  _$PaymentStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PaymentState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$InitialImplCopyWith<$Res> {
  factory _$$InitialImplCopyWith(
          _$InitialImpl value, $Res Function(_$InitialImpl) then) =
      __$$InitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$InitialImplCopyWithImpl<$Res>
    extends _$PaymentStateCopyWithImpl<$Res, _$InitialImpl>
    implements _$$InitialImplCopyWith<$Res> {
  __$$InitialImplCopyWithImpl(
      _$InitialImpl _value, $Res Function(_$InitialImpl) _then)
      : super(_value, _then);

  /// Create a copy of PaymentState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$InitialImpl implements _Initial {
  const _$InitialImpl();

  @override
  String toString() {
    return 'PaymentState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$InitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() startPayment,
    required TResult Function() paymentSdkSuccess,
    required TResult Function() paymentSdkFailure,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? startPayment,
    TResult? Function()? paymentSdkSuccess,
    TResult? Function()? paymentSdkFailure,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? startPayment,
    TResult Function()? paymentSdkSuccess,
    TResult Function()? paymentSdkFailure,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Start value) startPayment,
    required TResult Function(_SuccessSdk value) paymentSdkSuccess,
    required TResult Function(_FailureSdk value) paymentSdkFailure,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Start value)? startPayment,
    TResult? Function(_SuccessSdk value)? paymentSdkSuccess,
    TResult? Function(_FailureSdk value)? paymentSdkFailure,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Start value)? startPayment,
    TResult Function(_SuccessSdk value)? paymentSdkSuccess,
    TResult Function(_FailureSdk value)? paymentSdkFailure,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _Initial implements PaymentState {
  const factory _Initial() = _$InitialImpl;
}

/// @nodoc
abstract class _$$StartImplCopyWith<$Res> {
  factory _$$StartImplCopyWith(
          _$StartImpl value, $Res Function(_$StartImpl) then) =
      __$$StartImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$StartImplCopyWithImpl<$Res>
    extends _$PaymentStateCopyWithImpl<$Res, _$StartImpl>
    implements _$$StartImplCopyWith<$Res> {
  __$$StartImplCopyWithImpl(
      _$StartImpl _value, $Res Function(_$StartImpl) _then)
      : super(_value, _then);

  /// Create a copy of PaymentState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$StartImpl implements _Start {
  const _$StartImpl();

  @override
  String toString() {
    return 'PaymentState.startPayment()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$StartImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() startPayment,
    required TResult Function() paymentSdkSuccess,
    required TResult Function() paymentSdkFailure,
  }) {
    return startPayment();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? startPayment,
    TResult? Function()? paymentSdkSuccess,
    TResult? Function()? paymentSdkFailure,
  }) {
    return startPayment?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? startPayment,
    TResult Function()? paymentSdkSuccess,
    TResult Function()? paymentSdkFailure,
    required TResult orElse(),
  }) {
    if (startPayment != null) {
      return startPayment();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Start value) startPayment,
    required TResult Function(_SuccessSdk value) paymentSdkSuccess,
    required TResult Function(_FailureSdk value) paymentSdkFailure,
  }) {
    return startPayment(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Start value)? startPayment,
    TResult? Function(_SuccessSdk value)? paymentSdkSuccess,
    TResult? Function(_FailureSdk value)? paymentSdkFailure,
  }) {
    return startPayment?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Start value)? startPayment,
    TResult Function(_SuccessSdk value)? paymentSdkSuccess,
    TResult Function(_FailureSdk value)? paymentSdkFailure,
    required TResult orElse(),
  }) {
    if (startPayment != null) {
      return startPayment(this);
    }
    return orElse();
  }
}

abstract class _Start implements PaymentState {
  const factory _Start() = _$StartImpl;
}

/// @nodoc
abstract class _$$SuccessSdkImplCopyWith<$Res> {
  factory _$$SuccessSdkImplCopyWith(
          _$SuccessSdkImpl value, $Res Function(_$SuccessSdkImpl) then) =
      __$$SuccessSdkImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SuccessSdkImplCopyWithImpl<$Res>
    extends _$PaymentStateCopyWithImpl<$Res, _$SuccessSdkImpl>
    implements _$$SuccessSdkImplCopyWith<$Res> {
  __$$SuccessSdkImplCopyWithImpl(
      _$SuccessSdkImpl _value, $Res Function(_$SuccessSdkImpl) _then)
      : super(_value, _then);

  /// Create a copy of PaymentState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$SuccessSdkImpl implements _SuccessSdk {
  const _$SuccessSdkImpl();

  @override
  String toString() {
    return 'PaymentState.paymentSdkSuccess()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$SuccessSdkImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() startPayment,
    required TResult Function() paymentSdkSuccess,
    required TResult Function() paymentSdkFailure,
  }) {
    return paymentSdkSuccess();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? startPayment,
    TResult? Function()? paymentSdkSuccess,
    TResult? Function()? paymentSdkFailure,
  }) {
    return paymentSdkSuccess?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? startPayment,
    TResult Function()? paymentSdkSuccess,
    TResult Function()? paymentSdkFailure,
    required TResult orElse(),
  }) {
    if (paymentSdkSuccess != null) {
      return paymentSdkSuccess();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Start value) startPayment,
    required TResult Function(_SuccessSdk value) paymentSdkSuccess,
    required TResult Function(_FailureSdk value) paymentSdkFailure,
  }) {
    return paymentSdkSuccess(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Start value)? startPayment,
    TResult? Function(_SuccessSdk value)? paymentSdkSuccess,
    TResult? Function(_FailureSdk value)? paymentSdkFailure,
  }) {
    return paymentSdkSuccess?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Start value)? startPayment,
    TResult Function(_SuccessSdk value)? paymentSdkSuccess,
    TResult Function(_FailureSdk value)? paymentSdkFailure,
    required TResult orElse(),
  }) {
    if (paymentSdkSuccess != null) {
      return paymentSdkSuccess(this);
    }
    return orElse();
  }
}

abstract class _SuccessSdk implements PaymentState {
  const factory _SuccessSdk() = _$SuccessSdkImpl;
}

/// @nodoc
abstract class _$$FailureSdkImplCopyWith<$Res> {
  factory _$$FailureSdkImplCopyWith(
          _$FailureSdkImpl value, $Res Function(_$FailureSdkImpl) then) =
      __$$FailureSdkImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$FailureSdkImplCopyWithImpl<$Res>
    extends _$PaymentStateCopyWithImpl<$Res, _$FailureSdkImpl>
    implements _$$FailureSdkImplCopyWith<$Res> {
  __$$FailureSdkImplCopyWithImpl(
      _$FailureSdkImpl _value, $Res Function(_$FailureSdkImpl) _then)
      : super(_value, _then);

  /// Create a copy of PaymentState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$FailureSdkImpl implements _FailureSdk {
  const _$FailureSdkImpl();

  @override
  String toString() {
    return 'PaymentState.paymentSdkFailure()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$FailureSdkImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() startPayment,
    required TResult Function() paymentSdkSuccess,
    required TResult Function() paymentSdkFailure,
  }) {
    return paymentSdkFailure();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? startPayment,
    TResult? Function()? paymentSdkSuccess,
    TResult? Function()? paymentSdkFailure,
  }) {
    return paymentSdkFailure?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? startPayment,
    TResult Function()? paymentSdkSuccess,
    TResult Function()? paymentSdkFailure,
    required TResult orElse(),
  }) {
    if (paymentSdkFailure != null) {
      return paymentSdkFailure();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Start value) startPayment,
    required TResult Function(_SuccessSdk value) paymentSdkSuccess,
    required TResult Function(_FailureSdk value) paymentSdkFailure,
  }) {
    return paymentSdkFailure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Start value)? startPayment,
    TResult? Function(_SuccessSdk value)? paymentSdkSuccess,
    TResult? Function(_FailureSdk value)? paymentSdkFailure,
  }) {
    return paymentSdkFailure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Start value)? startPayment,
    TResult Function(_SuccessSdk value)? paymentSdkSuccess,
    TResult Function(_FailureSdk value)? paymentSdkFailure,
    required TResult orElse(),
  }) {
    if (paymentSdkFailure != null) {
      return paymentSdkFailure(this);
    }
    return orElse();
  }
}

abstract class _FailureSdk implements PaymentState {
  const factory _FailureSdk() = _$FailureSdkImpl;
}

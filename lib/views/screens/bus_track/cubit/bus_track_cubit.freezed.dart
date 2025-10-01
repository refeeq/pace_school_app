// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bus_track_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$BusTrackState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(BusTrackDataModel busTrackDataModel) success,
    required TResult Function(String error) failure,
    required TResult Function() tracking,
    required TResult Function() trackingSuccess,
    required TResult Function(String error) trackingFailure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(BusTrackDataModel busTrackDataModel)? success,
    TResult? Function(String error)? failure,
    TResult? Function()? tracking,
    TResult? Function()? trackingSuccess,
    TResult? Function(String error)? trackingFailure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(BusTrackDataModel busTrackDataModel)? success,
    TResult Function(String error)? failure,
    TResult Function()? tracking,
    TResult Function()? trackingSuccess,
    TResult Function(String error)? trackingFailure,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Success value) success,
    required TResult Function(_Failure value) failure,
    required TResult Function(_Tracking value) tracking,
    required TResult Function(_TrackingSuccess value) trackingSuccess,
    required TResult Function(_TrackingFailure value) trackingFailure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Success value)? success,
    TResult? Function(_Failure value)? failure,
    TResult? Function(_Tracking value)? tracking,
    TResult? Function(_TrackingSuccess value)? trackingSuccess,
    TResult? Function(_TrackingFailure value)? trackingFailure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Success value)? success,
    TResult Function(_Failure value)? failure,
    TResult Function(_Tracking value)? tracking,
    TResult Function(_TrackingSuccess value)? trackingSuccess,
    TResult Function(_TrackingFailure value)? trackingFailure,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BusTrackStateCopyWith<$Res> {
  factory $BusTrackStateCopyWith(
          BusTrackState value, $Res Function(BusTrackState) then) =
      _$BusTrackStateCopyWithImpl<$Res, BusTrackState>;
}

/// @nodoc
class _$BusTrackStateCopyWithImpl<$Res, $Val extends BusTrackState>
    implements $BusTrackStateCopyWith<$Res> {
  _$BusTrackStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BusTrackState
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
    extends _$BusTrackStateCopyWithImpl<$Res, _$InitialImpl>
    implements _$$InitialImplCopyWith<$Res> {
  __$$InitialImplCopyWithImpl(
      _$InitialImpl _value, $Res Function(_$InitialImpl) _then)
      : super(_value, _then);

  /// Create a copy of BusTrackState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$InitialImpl implements _Initial {
  const _$InitialImpl();

  @override
  String toString() {
    return 'BusTrackState.initial()';
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
    required TResult Function() loading,
    required TResult Function(BusTrackDataModel busTrackDataModel) success,
    required TResult Function(String error) failure,
    required TResult Function() tracking,
    required TResult Function() trackingSuccess,
    required TResult Function(String error) trackingFailure,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(BusTrackDataModel busTrackDataModel)? success,
    TResult? Function(String error)? failure,
    TResult? Function()? tracking,
    TResult? Function()? trackingSuccess,
    TResult? Function(String error)? trackingFailure,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(BusTrackDataModel busTrackDataModel)? success,
    TResult Function(String error)? failure,
    TResult Function()? tracking,
    TResult Function()? trackingSuccess,
    TResult Function(String error)? trackingFailure,
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
    required TResult Function(_Loading value) loading,
    required TResult Function(_Success value) success,
    required TResult Function(_Failure value) failure,
    required TResult Function(_Tracking value) tracking,
    required TResult Function(_TrackingSuccess value) trackingSuccess,
    required TResult Function(_TrackingFailure value) trackingFailure,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Success value)? success,
    TResult? Function(_Failure value)? failure,
    TResult? Function(_Tracking value)? tracking,
    TResult? Function(_TrackingSuccess value)? trackingSuccess,
    TResult? Function(_TrackingFailure value)? trackingFailure,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Success value)? success,
    TResult Function(_Failure value)? failure,
    TResult Function(_Tracking value)? tracking,
    TResult Function(_TrackingSuccess value)? trackingSuccess,
    TResult Function(_TrackingFailure value)? trackingFailure,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _Initial implements BusTrackState {
  const factory _Initial() = _$InitialImpl;
}

/// @nodoc
abstract class _$$LoadingImplCopyWith<$Res> {
  factory _$$LoadingImplCopyWith(
          _$LoadingImpl value, $Res Function(_$LoadingImpl) then) =
      __$$LoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoadingImplCopyWithImpl<$Res>
    extends _$BusTrackStateCopyWithImpl<$Res, _$LoadingImpl>
    implements _$$LoadingImplCopyWith<$Res> {
  __$$LoadingImplCopyWithImpl(
      _$LoadingImpl _value, $Res Function(_$LoadingImpl) _then)
      : super(_value, _then);

  /// Create a copy of BusTrackState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LoadingImpl implements _Loading {
  const _$LoadingImpl();

  @override
  String toString() {
    return 'BusTrackState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(BusTrackDataModel busTrackDataModel) success,
    required TResult Function(String error) failure,
    required TResult Function() tracking,
    required TResult Function() trackingSuccess,
    required TResult Function(String error) trackingFailure,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(BusTrackDataModel busTrackDataModel)? success,
    TResult? Function(String error)? failure,
    TResult? Function()? tracking,
    TResult? Function()? trackingSuccess,
    TResult? Function(String error)? trackingFailure,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(BusTrackDataModel busTrackDataModel)? success,
    TResult Function(String error)? failure,
    TResult Function()? tracking,
    TResult Function()? trackingSuccess,
    TResult Function(String error)? trackingFailure,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Success value) success,
    required TResult Function(_Failure value) failure,
    required TResult Function(_Tracking value) tracking,
    required TResult Function(_TrackingSuccess value) trackingSuccess,
    required TResult Function(_TrackingFailure value) trackingFailure,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Success value)? success,
    TResult? Function(_Failure value)? failure,
    TResult? Function(_Tracking value)? tracking,
    TResult? Function(_TrackingSuccess value)? trackingSuccess,
    TResult? Function(_TrackingFailure value)? trackingFailure,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Success value)? success,
    TResult Function(_Failure value)? failure,
    TResult Function(_Tracking value)? tracking,
    TResult Function(_TrackingSuccess value)? trackingSuccess,
    TResult Function(_TrackingFailure value)? trackingFailure,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _Loading implements BusTrackState {
  const factory _Loading() = _$LoadingImpl;
}

/// @nodoc
abstract class _$$SuccessImplCopyWith<$Res> {
  factory _$$SuccessImplCopyWith(
          _$SuccessImpl value, $Res Function(_$SuccessImpl) then) =
      __$$SuccessImplCopyWithImpl<$Res>;
  @useResult
  $Res call({BusTrackDataModel busTrackDataModel});
}

/// @nodoc
class __$$SuccessImplCopyWithImpl<$Res>
    extends _$BusTrackStateCopyWithImpl<$Res, _$SuccessImpl>
    implements _$$SuccessImplCopyWith<$Res> {
  __$$SuccessImplCopyWithImpl(
      _$SuccessImpl _value, $Res Function(_$SuccessImpl) _then)
      : super(_value, _then);

  /// Create a copy of BusTrackState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? busTrackDataModel = null,
  }) {
    return _then(_$SuccessImpl(
      null == busTrackDataModel
          ? _value.busTrackDataModel
          : busTrackDataModel // ignore: cast_nullable_to_non_nullable
              as BusTrackDataModel,
    ));
  }
}

/// @nodoc

class _$SuccessImpl implements _Success {
  const _$SuccessImpl(this.busTrackDataModel);

  @override
  final BusTrackDataModel busTrackDataModel;

  @override
  String toString() {
    return 'BusTrackState.success(busTrackDataModel: $busTrackDataModel)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SuccessImpl &&
            (identical(other.busTrackDataModel, busTrackDataModel) ||
                other.busTrackDataModel == busTrackDataModel));
  }

  @override
  int get hashCode => Object.hash(runtimeType, busTrackDataModel);

  /// Create a copy of BusTrackState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SuccessImplCopyWith<_$SuccessImpl> get copyWith =>
      __$$SuccessImplCopyWithImpl<_$SuccessImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(BusTrackDataModel busTrackDataModel) success,
    required TResult Function(String error) failure,
    required TResult Function() tracking,
    required TResult Function() trackingSuccess,
    required TResult Function(String error) trackingFailure,
  }) {
    return success(busTrackDataModel);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(BusTrackDataModel busTrackDataModel)? success,
    TResult? Function(String error)? failure,
    TResult? Function()? tracking,
    TResult? Function()? trackingSuccess,
    TResult? Function(String error)? trackingFailure,
  }) {
    return success?.call(busTrackDataModel);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(BusTrackDataModel busTrackDataModel)? success,
    TResult Function(String error)? failure,
    TResult Function()? tracking,
    TResult Function()? trackingSuccess,
    TResult Function(String error)? trackingFailure,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(busTrackDataModel);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Success value) success,
    required TResult Function(_Failure value) failure,
    required TResult Function(_Tracking value) tracking,
    required TResult Function(_TrackingSuccess value) trackingSuccess,
    required TResult Function(_TrackingFailure value) trackingFailure,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Success value)? success,
    TResult? Function(_Failure value)? failure,
    TResult? Function(_Tracking value)? tracking,
    TResult? Function(_TrackingSuccess value)? trackingSuccess,
    TResult? Function(_TrackingFailure value)? trackingFailure,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Success value)? success,
    TResult Function(_Failure value)? failure,
    TResult Function(_Tracking value)? tracking,
    TResult Function(_TrackingSuccess value)? trackingSuccess,
    TResult Function(_TrackingFailure value)? trackingFailure,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class _Success implements BusTrackState {
  const factory _Success(final BusTrackDataModel busTrackDataModel) =
      _$SuccessImpl;

  BusTrackDataModel get busTrackDataModel;

  /// Create a copy of BusTrackState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SuccessImplCopyWith<_$SuccessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FailureImplCopyWith<$Res> {
  factory _$$FailureImplCopyWith(
          _$FailureImpl value, $Res Function(_$FailureImpl) then) =
      __$$FailureImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String error});
}

/// @nodoc
class __$$FailureImplCopyWithImpl<$Res>
    extends _$BusTrackStateCopyWithImpl<$Res, _$FailureImpl>
    implements _$$FailureImplCopyWith<$Res> {
  __$$FailureImplCopyWithImpl(
      _$FailureImpl _value, $Res Function(_$FailureImpl) _then)
      : super(_value, _then);

  /// Create a copy of BusTrackState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? error = null,
  }) {
    return _then(_$FailureImpl(
      null == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$FailureImpl implements _Failure {
  const _$FailureImpl(this.error);

  @override
  final String error;

  @override
  String toString() {
    return 'BusTrackState.failure(error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FailureImpl &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  /// Create a copy of BusTrackState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FailureImplCopyWith<_$FailureImpl> get copyWith =>
      __$$FailureImplCopyWithImpl<_$FailureImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(BusTrackDataModel busTrackDataModel) success,
    required TResult Function(String error) failure,
    required TResult Function() tracking,
    required TResult Function() trackingSuccess,
    required TResult Function(String error) trackingFailure,
  }) {
    return failure(error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(BusTrackDataModel busTrackDataModel)? success,
    TResult? Function(String error)? failure,
    TResult? Function()? tracking,
    TResult? Function()? trackingSuccess,
    TResult? Function(String error)? trackingFailure,
  }) {
    return failure?.call(error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(BusTrackDataModel busTrackDataModel)? success,
    TResult Function(String error)? failure,
    TResult Function()? tracking,
    TResult Function()? trackingSuccess,
    TResult Function(String error)? trackingFailure,
    required TResult orElse(),
  }) {
    if (failure != null) {
      return failure(error);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Success value) success,
    required TResult Function(_Failure value) failure,
    required TResult Function(_Tracking value) tracking,
    required TResult Function(_TrackingSuccess value) trackingSuccess,
    required TResult Function(_TrackingFailure value) trackingFailure,
  }) {
    return failure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Success value)? success,
    TResult? Function(_Failure value)? failure,
    TResult? Function(_Tracking value)? tracking,
    TResult? Function(_TrackingSuccess value)? trackingSuccess,
    TResult? Function(_TrackingFailure value)? trackingFailure,
  }) {
    return failure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Success value)? success,
    TResult Function(_Failure value)? failure,
    TResult Function(_Tracking value)? tracking,
    TResult Function(_TrackingSuccess value)? trackingSuccess,
    TResult Function(_TrackingFailure value)? trackingFailure,
    required TResult orElse(),
  }) {
    if (failure != null) {
      return failure(this);
    }
    return orElse();
  }
}

abstract class _Failure implements BusTrackState {
  const factory _Failure(final String error) = _$FailureImpl;

  String get error;

  /// Create a copy of BusTrackState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FailureImplCopyWith<_$FailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$TrackingImplCopyWith<$Res> {
  factory _$$TrackingImplCopyWith(
          _$TrackingImpl value, $Res Function(_$TrackingImpl) then) =
      __$$TrackingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$TrackingImplCopyWithImpl<$Res>
    extends _$BusTrackStateCopyWithImpl<$Res, _$TrackingImpl>
    implements _$$TrackingImplCopyWith<$Res> {
  __$$TrackingImplCopyWithImpl(
      _$TrackingImpl _value, $Res Function(_$TrackingImpl) _then)
      : super(_value, _then);

  /// Create a copy of BusTrackState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$TrackingImpl implements _Tracking {
  const _$TrackingImpl();

  @override
  String toString() {
    return 'BusTrackState.tracking()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$TrackingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(BusTrackDataModel busTrackDataModel) success,
    required TResult Function(String error) failure,
    required TResult Function() tracking,
    required TResult Function() trackingSuccess,
    required TResult Function(String error) trackingFailure,
  }) {
    return tracking();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(BusTrackDataModel busTrackDataModel)? success,
    TResult? Function(String error)? failure,
    TResult? Function()? tracking,
    TResult? Function()? trackingSuccess,
    TResult? Function(String error)? trackingFailure,
  }) {
    return tracking?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(BusTrackDataModel busTrackDataModel)? success,
    TResult Function(String error)? failure,
    TResult Function()? tracking,
    TResult Function()? trackingSuccess,
    TResult Function(String error)? trackingFailure,
    required TResult orElse(),
  }) {
    if (tracking != null) {
      return tracking();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Success value) success,
    required TResult Function(_Failure value) failure,
    required TResult Function(_Tracking value) tracking,
    required TResult Function(_TrackingSuccess value) trackingSuccess,
    required TResult Function(_TrackingFailure value) trackingFailure,
  }) {
    return tracking(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Success value)? success,
    TResult? Function(_Failure value)? failure,
    TResult? Function(_Tracking value)? tracking,
    TResult? Function(_TrackingSuccess value)? trackingSuccess,
    TResult? Function(_TrackingFailure value)? trackingFailure,
  }) {
    return tracking?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Success value)? success,
    TResult Function(_Failure value)? failure,
    TResult Function(_Tracking value)? tracking,
    TResult Function(_TrackingSuccess value)? trackingSuccess,
    TResult Function(_TrackingFailure value)? trackingFailure,
    required TResult orElse(),
  }) {
    if (tracking != null) {
      return tracking(this);
    }
    return orElse();
  }
}

abstract class _Tracking implements BusTrackState {
  const factory _Tracking() = _$TrackingImpl;
}

/// @nodoc
abstract class _$$TrackingSuccessImplCopyWith<$Res> {
  factory _$$TrackingSuccessImplCopyWith(_$TrackingSuccessImpl value,
          $Res Function(_$TrackingSuccessImpl) then) =
      __$$TrackingSuccessImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$TrackingSuccessImplCopyWithImpl<$Res>
    extends _$BusTrackStateCopyWithImpl<$Res, _$TrackingSuccessImpl>
    implements _$$TrackingSuccessImplCopyWith<$Res> {
  __$$TrackingSuccessImplCopyWithImpl(
      _$TrackingSuccessImpl _value, $Res Function(_$TrackingSuccessImpl) _then)
      : super(_value, _then);

  /// Create a copy of BusTrackState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$TrackingSuccessImpl implements _TrackingSuccess {
  const _$TrackingSuccessImpl();

  @override
  String toString() {
    return 'BusTrackState.trackingSuccess()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$TrackingSuccessImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(BusTrackDataModel busTrackDataModel) success,
    required TResult Function(String error) failure,
    required TResult Function() tracking,
    required TResult Function() trackingSuccess,
    required TResult Function(String error) trackingFailure,
  }) {
    return trackingSuccess();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(BusTrackDataModel busTrackDataModel)? success,
    TResult? Function(String error)? failure,
    TResult? Function()? tracking,
    TResult? Function()? trackingSuccess,
    TResult? Function(String error)? trackingFailure,
  }) {
    return trackingSuccess?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(BusTrackDataModel busTrackDataModel)? success,
    TResult Function(String error)? failure,
    TResult Function()? tracking,
    TResult Function()? trackingSuccess,
    TResult Function(String error)? trackingFailure,
    required TResult orElse(),
  }) {
    if (trackingSuccess != null) {
      return trackingSuccess();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Success value) success,
    required TResult Function(_Failure value) failure,
    required TResult Function(_Tracking value) tracking,
    required TResult Function(_TrackingSuccess value) trackingSuccess,
    required TResult Function(_TrackingFailure value) trackingFailure,
  }) {
    return trackingSuccess(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Success value)? success,
    TResult? Function(_Failure value)? failure,
    TResult? Function(_Tracking value)? tracking,
    TResult? Function(_TrackingSuccess value)? trackingSuccess,
    TResult? Function(_TrackingFailure value)? trackingFailure,
  }) {
    return trackingSuccess?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Success value)? success,
    TResult Function(_Failure value)? failure,
    TResult Function(_Tracking value)? tracking,
    TResult Function(_TrackingSuccess value)? trackingSuccess,
    TResult Function(_TrackingFailure value)? trackingFailure,
    required TResult orElse(),
  }) {
    if (trackingSuccess != null) {
      return trackingSuccess(this);
    }
    return orElse();
  }
}

abstract class _TrackingSuccess implements BusTrackState {
  const factory _TrackingSuccess() = _$TrackingSuccessImpl;
}

/// @nodoc
abstract class _$$TrackingFailureImplCopyWith<$Res> {
  factory _$$TrackingFailureImplCopyWith(_$TrackingFailureImpl value,
          $Res Function(_$TrackingFailureImpl) then) =
      __$$TrackingFailureImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String error});
}

/// @nodoc
class __$$TrackingFailureImplCopyWithImpl<$Res>
    extends _$BusTrackStateCopyWithImpl<$Res, _$TrackingFailureImpl>
    implements _$$TrackingFailureImplCopyWith<$Res> {
  __$$TrackingFailureImplCopyWithImpl(
      _$TrackingFailureImpl _value, $Res Function(_$TrackingFailureImpl) _then)
      : super(_value, _then);

  /// Create a copy of BusTrackState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? error = null,
  }) {
    return _then(_$TrackingFailureImpl(
      null == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$TrackingFailureImpl implements _TrackingFailure {
  const _$TrackingFailureImpl(this.error);

  @override
  final String error;

  @override
  String toString() {
    return 'BusTrackState.trackingFailure(error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrackingFailureImpl &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  /// Create a copy of BusTrackState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrackingFailureImplCopyWith<_$TrackingFailureImpl> get copyWith =>
      __$$TrackingFailureImplCopyWithImpl<_$TrackingFailureImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(BusTrackDataModel busTrackDataModel) success,
    required TResult Function(String error) failure,
    required TResult Function() tracking,
    required TResult Function() trackingSuccess,
    required TResult Function(String error) trackingFailure,
  }) {
    return trackingFailure(error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(BusTrackDataModel busTrackDataModel)? success,
    TResult? Function(String error)? failure,
    TResult? Function()? tracking,
    TResult? Function()? trackingSuccess,
    TResult? Function(String error)? trackingFailure,
  }) {
    return trackingFailure?.call(error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(BusTrackDataModel busTrackDataModel)? success,
    TResult Function(String error)? failure,
    TResult Function()? tracking,
    TResult Function()? trackingSuccess,
    TResult Function(String error)? trackingFailure,
    required TResult orElse(),
  }) {
    if (trackingFailure != null) {
      return trackingFailure(error);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Success value) success,
    required TResult Function(_Failure value) failure,
    required TResult Function(_Tracking value) tracking,
    required TResult Function(_TrackingSuccess value) trackingSuccess,
    required TResult Function(_TrackingFailure value) trackingFailure,
  }) {
    return trackingFailure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Success value)? success,
    TResult? Function(_Failure value)? failure,
    TResult? Function(_Tracking value)? tracking,
    TResult? Function(_TrackingSuccess value)? trackingSuccess,
    TResult? Function(_TrackingFailure value)? trackingFailure,
  }) {
    return trackingFailure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Success value)? success,
    TResult Function(_Failure value)? failure,
    TResult Function(_Tracking value)? tracking,
    TResult Function(_TrackingSuccess value)? trackingSuccess,
    TResult Function(_TrackingFailure value)? trackingFailure,
    required TResult orElse(),
  }) {
    if (trackingFailure != null) {
      return trackingFailure(this);
    }
    return orElse();
  }
}

abstract class _TrackingFailure implements BusTrackState {
  const factory _TrackingFailure(final String error) = _$TrackingFailureImpl;

  String get error;

  /// Create a copy of BusTrackState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrackingFailureImplCopyWith<_$TrackingFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

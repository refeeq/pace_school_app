part of 'bus_track_cubit.dart';

@freezed
class BusTrackState with _$BusTrackState {
  const factory BusTrackState.initial() = _Initial;
  const factory BusTrackState.loading() = _Loading;
  const factory BusTrackState.success(BusTrackDataModel busTrackDataModel) =
      _Success;
  const factory BusTrackState.failure(String error) = _Failure;

  // tracking
  const factory BusTrackState.tracking() = _Tracking;
  const factory BusTrackState.trackingSuccess() = _TrackingSuccess;
  const factory BusTrackState.trackingFailure(String error) = _TrackingFailure;
}

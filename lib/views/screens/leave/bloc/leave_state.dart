part of 'leave_bloc.dart';

final class ApplyLeaveApplicationFailureState extends LeaveState {
  final String message;

  const ApplyLeaveApplicationFailureState({
    required this.message,
  });
}

final class ApplyLeaveApplicationLoadingstate extends LeaveState {}

final class ApplyLeaveApplicationSuccessState extends LeaveState {
  final String message;
  final bool isSuccess;

  const ApplyLeaveApplicationSuccessState(
      {required this.message, required this.isSuccess});
}

final class LeaveApplicationLoadingstate extends LeaveState {}

final class LeaveInitial extends LeaveState {}

sealed class LeaveState extends Equatable {
  const LeaveState();

  @override
  List<Object> get props => [];
}

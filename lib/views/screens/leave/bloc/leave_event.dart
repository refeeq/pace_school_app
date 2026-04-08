part of 'leave_bloc.dart';

final class LeaveApplyEvent extends LeaveEvent {
  final String fromDate;
  final String endDate;
  final String reasonId;
  final String reason;
  final String studentId;

  const LeaveApplyEvent(
      {required this.fromDate,
      required this.endDate,
      required this.reasonId,
      required this.reason,
      required this.studentId});
}

sealed class LeaveEvent extends Equatable {
  const LeaveEvent();

  @override
  List<Object> get props => [];
}

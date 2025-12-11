import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_app/core/repository/leaveApplication/repository.dart';
import 'package:school_app/core/services/dependecyInjection.dart';

part 'leave_event.dart';
part 'leave_state.dart';

class LeaveBloc extends Bloc<LeaveEvent, LeaveState> {
  LeaveApplicationRepository repository = locator<LeaveApplicationRepository>();
  LeaveBloc() : super(LeaveInitial()) {
    on<LeaveEvent>((event, emit) {
      // TODO: implement event handler
    });
    on<LeaveApplyEvent>((event, emit) async {
      emit(ApplyLeaveApplicationLoadingstate());

      var res = await repository.applyLeaveApplication(
        fromDate: event.fromDate,
        endDate: event.endDate,
        reasonId: event.reasonId,
        reason: event.reason,
        studentId: event.studentId,
      );
      res.fold(
        (left) =>
            emit(ApplyLeaveApplicationFailureState(message: left.message!)),
        (right) => emit(
          ApplyLeaveApplicationSuccessState(
            message: right['message'],
            isSuccess: right['status'],
          ),
        ),
      );
    });
  }
}

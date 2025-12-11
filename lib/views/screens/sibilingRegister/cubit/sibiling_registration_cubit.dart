import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_app/core/repository/admission/repository.dart';
import 'package:school_app/core/services/dependecyInjection.dart';
import 'package:school_app/views/screens/sibilingRegister/models/sibling_register_model.dart';

part 'sibiling_registration_state.dart';

class SibilingRegistrationCubit extends Cubit<SibilingRegistrationState> {
  AdmissionRepository repository = locator<AdmissionRepository>();
  SibilingRegistrationCubit() : super(SibilingRegistrationInitial());
  Future<void> fetchUsers() async {
    emit(SibilingRegistrationListLoading());

    final res = await repository.fetchRegistrations();
    res.fold(
      (left) => emit(SibilingRegistrationListError(message: "message")),
      (right) => emit(
        SibilingRegistrationListFetched(
          list: List<SiblingRegisterModel>.from(
            right['data'].map((x) => SiblingRegisterModel.fromJson(x)),
          ),
        ),
      ),
    );
  }
}

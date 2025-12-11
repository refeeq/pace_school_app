import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_app/views/screens/open_house/model/add_open_house_model.dart';
import 'package:school_app/views/screens/open_house/model/slot_model.dart';

class SlotSelectionCubit extends Cubit<List<AddOpenHouseModel>> {
  SlotSelectionCubit() : super([]);

  void addOrRemoveData(
    int teacherCode,
    String slotId,
    int bookingStatus,
    String ohMainId,
    String regNo,
  ) {
    // Find the existing model with the given teacherCode, if any
    var existingModel = state.firstWhere(
      (model) => model.teacherCode == teacherCode,
      orElse: () => AddOpenHouseModel(
        teacherCode: teacherCode,
        ohMainId: "",
        regNo: "",
        slotId: '',
        bookingStatus: '',
      ),
    );

    // If the model already exists in the state, remove it
    if (state.contains(existingModel)) {
      state.remove(existingModel);
    }

    // Add the new model with the teacherCode and slotId
    state.add(
      AddOpenHouseModel(
        teacherCode: teacherCode,
        ohMainId: ohMainId,
        regNo: regNo,
        slotId: slotId,
        bookingStatus: bookingStatus == 1 ? "0" : "1",
      ),
    );

    // Emit a new state with the updated data
    emit(List<AddOpenHouseModel>.from(state));
  }

  void clearData() {
    state.clear();
    emit(
      List<AddOpenHouseModel>.from(state),
    ); // Emit a new state with the same data
  }

  List<SlotDetail> dataPresentWithTeacherCode(
    int teacherCode,
    List<SlotDetail> list,
  ) {
    try {
      var teacherCodeExistsInState = state.firstWhere(
        (model) => model.teacherCode == teacherCode,
      );

      return list
          .where(
            (model) =>
                model.slotId.toString() == teacherCodeExistsInState.slotId,
          )
          .toList();
    } catch (e) {
      // Handle the case where the teacher code is not found in the state
      return [];
    }
  }

  bool isDataNotEmpty() {
    return state.isNotEmpty;
  }

  bool isDataPresent(int teacherCode, String slotId) {
    return state.any(
      (model) => model.teacherCode == teacherCode && model.slotId == slotId,
    );
  }

  bool isDataPresentWithTeacherCode(int teacherCode) {
    return state.any((model) => model.teacherCode == teacherCode);
  }

  AddOpenHouseModel slotReturn(int teacherCode, int slotId) {
    return state.firstWhere(
      (model) =>
          model.teacherCode == teacherCode && model.slotId == slotId.toString(),
    );
  }

  // New function: Get slots booked by the current user
  List<AddOpenHouseModel> getBookedSlotsByMe(int teacherCode) {
    return state
        .where(
          (model) =>
              model.teacherCode == teacherCode && model.bookingStatus == "1",
        )
        .toList();
  }
}

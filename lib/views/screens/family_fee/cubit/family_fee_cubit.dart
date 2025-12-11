import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_app/core/services/dependecyInjection.dart';
import 'package:school_app/views/screens/family_fee/models/family_fee_item_fee_model.dart';
import 'package:school_app/views/screens/family_fee/models/family_fee_item_model.dart';
import 'package:school_app/views/screens/family_fee/models/family_fee_model.dart';
import 'package:school_app/views/screens/family_fee/repository/family_fee_repository.dart';

part 'family_fee_state.dart';

class FamilyFeeCubit extends Cubit<FamilyFeeState> {
  final FamilyFeeRepository familyFeeRepository =
      locator<FamilyFeeRepository>();
  FamilyFeeCubit() : super(const FamilyFeeInitial(status: true));
  Future<void> fetchfee() async {
    emit(const FamilyFeeFetchLoading(status: true));

    var res = await familyFeeRepository.getFee();

    if (res.isLeft) {
      emit(const FamilyFeeFetchError(message: "", status: false));
    } else {
      emit(FamilyFeeFetchSuccess(family: res.right, status: false));
    }
  }

  // void updateOrAddFeeAmount(List<FamilyFeeItem> family, String studcode,
  //     FamilyFeeItemFee item, bool status, int index) {
  //   // Emit the initial state before any updates
  //   emit(AmountUpdatesState(
  //     family: family,
  //     status: false,
  //     list: amountList,
  //     totalAmount: totalAmount,
  //   ));

  //   // Check if the family.data[existingIndex] already exists in the list
  //   int existingIndex =
  //       amountList.indexWhere((entry) => entry.studcode == studcode);

  //   if (existingIndex != -1) {
  //     // Get the existing FamilyFeeAmountModel
  //     FamilyFeeAmountModel existingModel = amountList[existingIndex];

  //     // Check if the fee item already exists in the fees list
  //     bool feeExists = existingModel.fees.any((element) =>
  //         element.feeItemId == item.feeItemId &&
  //         element.acYear == item.acYear &&
  //         element.feeAmt == item.feeAmt);

  //     if (feeExists) {
  //       log("Fee item found, removing ");
  //       FamilyFeeItemFee _family = existingModel.fees.firstWhere((element) =>
  //           element.feeItemId == item.feeItemId &&
  //           element.acYear == item.acYear &&
  //           element.feeAmt == item.feeAmt);
  //       double amountToRemove = double.parse(_family.feeAmt);
  //       existingModel.amount -= amountToRemove;
  //       totalAmount -= amountToRemove;

  //       existingModel.fees.removeWhere(
  //         (element) =>
  //             element.feeItemId == item.feeItemId &&
  //             element.acYear == item.acYear &&
  //             element.feeAmt == item.feeAmt,
  //       );
  //     } else {
  //       log("Fee item not found, adding it");
  //       // If the fee item does not exist, add the amount and fee item

  //       existingModel.fees.insert(index, item);
  //       existingModel.amount += double.parse(item.feeAmt);
  //       totalAmount += double.parse(item.feeAmt);
  //     }
  //   }

  //   // Emit the updated state after changes
  //   emit(AmountUpdateState(
  //     family: family,
  //     status: status,
  //     list: amountList,
  //     totalAmount: totalAmount,
  //   ));
  // }

  // Function to update or add fee amount
  void updateOrAddFeeAmount(
    FamilyFeeModel family,
    String studcode,
    FamilyFeeItemFee item,
    bool status,
    int index,
  ) {
    // Emit the initial state before any updates
    emit(AmountUpdatesState(family: family, status: false));

    // Check if the family.data[existingIndex] already exists in the list
    int existingIndex = family.data.indexWhere(
      (entry) => entry.studcode == studcode,
    );

    if (existingIndex == -1) {
      return; // Exit if family.data[existingIndex] does not exist
    }

    // Check if the fee is already selected
    if (family.data[existingIndex].fee[index].isSelected) {
      log("Fee is selected and will be removed");

      // Deselect subsequent fees if needed
      for (int i = index; i < family.data[existingIndex].fee.length; i++) {
        if (family.data[existingIndex].fee[i].isSelected) {
          log("Deselecting subsequent fee at index $i");
          family.data[existingIndex].fee[i].isSelected = false;
        }
      }
    } else {
      // Select fees up to the given index
      for (int i = 0; i < index + 1; i++) {
        if (!family.data[existingIndex].fee[i].isSelected) {
          log("Selecting fee at index $i");
          family.data[existingIndex].fee[i].isSelected = true;
        }
      }
      log("Fee is selected");
    }

    // Calculate the amount for the current family.data[existingIndex]
    family.data[existingIndex].amount = FamilyFeeItem.calculateAmount(
      family.data[existingIndex].fee,
    );

    // Recalculate total amount for all family.data[existingIndex]s
    family.totalAmount = FamilyFeeModel.calculateTotalAmount(family.data);

    // Emit the updated state after changes
    emit(AmountUpdateState(family: family, status: status));
  }

  Future<void> submitFee() async {
    emit(FamilyFeePay(status: false, family: state.family));
    // Call the repository function to submit the fee
    var res = await familyFeeRepository.submitFee(state.family!.data);

    // Handle the response from the repository
    res.fold(
      (failure) {
        // Handle failure (Left side of Either)
        debugPrint('Error occurred: ${failure.message}');
      },
      (successData) {
        // Handle success (Right side of Either)
        emit(
          FamilyFeePaySuccess(
            status: true,
            family: state.family,
            message: "Fee submitted successfully",
            data: successData["data"],
          ),
        );
      },
    );
  }
}

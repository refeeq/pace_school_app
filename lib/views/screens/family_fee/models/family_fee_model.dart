// To parse this JSON data, do
//
//     final familyFeeModel = familyFeeModelFromJson(jsonString);

import 'dart:convert';

import 'package:school_app/views/screens/family_fee/models/family_fee_item_model.dart';

FamilyFeeModel familyFeeModelFromJson(String str) =>
    FamilyFeeModel.fromJson(json.decode(str));

String familyFeeModelToJson(FamilyFeeModel data) => json.encode(data.toJson());

class FamilyFeeModel {
  List<FamilyFeeItem> data;
  bool status;
  double totalAmount;
  String message;

  FamilyFeeModel({
    required this.data,
    required this.status,
    this.totalAmount = 0,
    required this.message,
  });

  factory FamilyFeeModel.fromJson(Map<String, dynamic> json) {
    List<FamilyFeeItem> data = List<FamilyFeeItem>.from(
      json["data"].map((x) => FamilyFeeItem.fromJson(x)),
    );
    // Calculate the total amount based on the fees
    double calculatedAmount = calculateTotalAmount(data);
    return FamilyFeeModel(
      data: data,
      status: json["status"],
      message: json["message"],
      totalAmount: calculatedAmount,
    );
  }
  static double calculateTotalAmount(List<FamilyFeeItem> fees) {
    double am = 0;
    for (var item in fees) {
      for (var i in item.fee) {
        if (i.isSelected) {
          am += double.parse(i.feeAmt);
        }
      }
    }
    // Calculate the total amount by summing up the fee amounts
    return am;
  }

  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "status": status,
    "message": message,
  };
}

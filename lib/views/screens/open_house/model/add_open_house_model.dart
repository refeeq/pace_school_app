// To parse this JSON data, do
//
//     final addOpenHouseModel = addOpenHouseModelFromJson(jsonString);

import 'dart:convert';

String addOpenHouseModelToJson(AddOpenHouseModel data) =>
    json.encode(data.toJson());

class AddOpenHouseModel {
  final int teacherCode;
  final String slotId;
  final String regNo;
  final String ohMainId;
  final String bookingStatus;

  AddOpenHouseModel({
    required this.teacherCode,
    required this.slotId,
    required this.bookingStatus,
    required this.ohMainId,
    required this.regNo,
  });

  Map<String, dynamic> toJson() => {
        "empId": teacherCode,
        "regNo": regNo,
        "ohMainId": ohMainId,
        "slotId": slotId,
        "bookStat": bookingStatus,
      };
}

// To parse this JSON data, do
//
//     final openHouseModel = openHouseModelFromJson(jsonString);

import 'dart:convert';

import 'package:school_app/views/screens/open_house/model/teacher_model.dart';

OpenHouseModel openHouseModelFromJson(String str) =>
    OpenHouseModel.fromJson(json.decode(str));

String openHouseModelToJson(OpenHouseModel data) => json.encode(data.toJson());

class OpenHouseModel {
  final String openHouseId;
  final String ohDate;
  final String timeFrom;
  final String timeTo;
  final String ohStat;
  final String ohStstMsg;
  final List<TeacherModel> trSlotDetails;

  OpenHouseModel({
    required this.openHouseId,
    required this.ohDate,
    required this.timeFrom,
    required this.timeTo,
    required this.ohStat,
    required this.ohStstMsg,
    required this.trSlotDetails,
  });

  factory OpenHouseModel.fromJson(Map<String, dynamic> json) => OpenHouseModel(
    openHouseId: json["openHouseId"].toString(),
    ohDate: json["oh_date"],
    timeFrom: json["time_from"],
    timeTo: json["time_to"],
    ohStat: json["oh_stat"],
    ohStstMsg: json["oh_stst_msg"],
    trSlotDetails: List<TeacherModel>.from(
      json["trSlotDetails"].map((x) => TeacherModel.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "ohMainId": openHouseId,
    "oh_date": ohDate,
    "time_from": timeFrom,
    "time_to": timeTo,
    "oh_stat": ohStat,
    "oh_stst_msg": ohStstMsg,
    "trSlotDetails": List<dynamic>.from(trSlotDetails.map((x) => x.toJson())),
  };
}

// To parse this JSON data, do
//
//     final activeOpenHouseModel = activeOpenHouseModelFromJson(jsonString);

import 'dart:convert';

List<ActiveOpenHouseModel> activeOpenHouseModelFromJson(String str) =>
    List<ActiveOpenHouseModel>.from(
        json.decode(str).map((x) => ActiveOpenHouseModel.fromJson(x)));

String activeOpenHouseModelToJson(List<ActiveOpenHouseModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ActiveOpenHouseModel {
  final String teacher;
  final String photo;
  final String from;
  final String to;
  final DateTime ohDate;
  final String subject;
  final String slotId;

  ActiveOpenHouseModel({
    required this.teacher,
    required this.from,
    required this.to,
    required this.photo,
    required this.ohDate,
    required this.subject,
    required this.slotId,
  });

  factory ActiveOpenHouseModel.fromJson(Map<String, dynamic> json) =>
      ActiveOpenHouseModel(
          teacher: json["teacher"],
          from: json["from"],
          to: json["to"],
          photo: json["photo"],
          ohDate: DateTime.parse(json["oh_date"]),
          subject: json['subjects'],
          slotId: json['slot_id']);

  Map<String, dynamic> toJson() => {
        "teacher": teacher,
        "from": from,
        "to": to,
        "oh_date":
            "${ohDate.year.toString().padLeft(4, '0')}-${ohDate.month.toString().padLeft(2, '0')}-${ohDate.day.toString().padLeft(2, '0')}",
      };
}

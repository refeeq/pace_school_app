// To parse this JSON data, do
//
//     final communicationDetailModel = communicationDetailModelFromJson(jsonString);

import 'dart:convert';

CommunicationDetailModel communicationDetailModelFromJson(String str) =>
    CommunicationDetailModel.fromJson(json.decode(str));

String communicationDetailModelToJson(CommunicationDetailModel data) =>
    json.encode(data.toJson());

class CommunicationDetailModel {
  CommunicationDetailModel({
    required this.id,
    required this.studcode,
    required this.notification,
    required this.page,
    required this.head,
    required this.dateAdded,
    required this.readStat,
  });

  final String id;
  final String studcode;
  final String notification;
  final dynamic page;
  final String head;
  final String dateAdded;
  final String readStat;

  factory CommunicationDetailModel.fromJson(Map<String, dynamic> json) =>
      CommunicationDetailModel(
        id: json["id"],
        studcode: json["studcode"],
        notification: json["notification"],
        page: json["page"],
        head: json["head"],
        dateAdded: json["date_added"],
        readStat: json["read_stat"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "studcode": studcode,
        "notification": notification,
        "page": page,
        "head": head,
        "date_added": dateAdded,
        "read_stat": readStat,
      };
}

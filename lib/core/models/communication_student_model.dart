// To parse this JSON data, do
//
//     final communicationStudentModel = communicationStudentModelFromJson(jsonString);

import 'dart:convert';

CommunicationStudentModel communicationStudentModelFromJson(String str) =>
    CommunicationStudentModel.fromJson(json.decode(str));

String communicationStudentModelToJson(CommunicationStudentModel data) =>
    json.encode(data.toJson());

class CommunicationStudentModel {
  CommunicationStudentModel({
    required this.studcode,
    required this.fullname,
    required this.communicationStudentModelClass,
    required this.section,
    required this.studStat,
    required this.acdyear,
    required this.acYearId,
    required this.photo,
    required this.unread,
    required this.lastMessage,
  });

  final String studcode;
  final String fullname;
  final String communicationStudentModelClass;
  final String section;
  final String studStat;
  final String acdyear;
  final String acYearId;
  final String photo;
  final String lastMessage;
  final int unread;

  factory CommunicationStudentModel.fromJson(Map<String, dynamic> json) {
    final unread = json["unread"];
    final int unreadCount = unread is int
        ? unread
        : (unread is String ? int.tryParse(unread) ?? 0 : 0);
    return CommunicationStudentModel(
      studcode: json["studcode"],
      fullname: json["fullname"],
      communicationStudentModelClass: json["class"],
      section: json["section"],
      studStat: json["stud_stat"],
      acdyear: json["acdyear"],
      acYearId: json["ac_year_id"],
      photo: json["photo"],
      unread: unreadCount,
      lastMessage: json["last_msg"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "studcode": studcode,
        "fullname": fullname,
        "class": communicationStudentModelClass,
        "section": section,
        "stud_stat": studStat,
        "acdyear": acdyear,
        "ac_year_id": acYearId,
        "photo": photo,
        "unread": unread,
      };
}

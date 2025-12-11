// To parse this JSON data, do
//
//     final leaveListModel = leaveListModelFromJson(jsonString);

import 'dart:convert';

LeaveListModel leaveListModelFromJson(String str) =>
    LeaveListModel.fromJson(json.decode(str));

String leaveListModelToJson(LeaveListModel data) => json.encode(data.toJson());

class LeaveListModel {
  final DateTime leaveFrom;

  final DateTime leaveTo;
  final String leaveReasonType;
  final String leaveReason;
  final DateTime dateAdded;
  final String leaveStatus;
  final String color;
  final String changeMark;
  LeaveListModel({
    required this.leaveFrom,
    required this.leaveTo,
    required this.leaveReasonType,
    required this.leaveReason,
    required this.dateAdded,
    required this.leaveStatus,
    required this.color,
    required this.changeMark,
  });

  factory LeaveListModel.fromJson(Map<String, dynamic> json) => LeaveListModel(
      leaveFrom: DateTime.parse(json["leave_from"]),
      leaveTo: DateTime.parse(json["leave_to"]),
      leaveReasonType: json["leave_reason_type"],
      leaveReason: json["leave_reason"],
      dateAdded: DateTime.parse(json["date_added"]),
      leaveStatus: json["leave_status"],
      color: json["color"],
      changeMark: json['change_remark'].toString());

  Map<String, dynamic> toJson() => {
        "leave_from":
            "${leaveFrom.year.toString().padLeft(4, '0')}-${leaveFrom.month.toString().padLeft(2, '0')}-${leaveFrom.day.toString().padLeft(2, '0')}",
        "leave_to":
            "${leaveTo.year.toString().padLeft(4, '0')}-${leaveTo.month.toString().padLeft(2, '0')}-${leaveTo.day.toString().padLeft(2, '0')}",
        "leave_reason_type": leaveReasonType,
        "leave_reason": leaveReason,
        "date_added": dateAdded.toIso8601String(),
        "leave_status": leaveStatus,
        "color": color,
      };
}

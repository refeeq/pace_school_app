import 'dart:convert';

AttendanceResponseModel attendanceResponseModelFromJson(String str) =>
    AttendanceResponseModel.fromJson(json.decode(str));

String attendanceResponseModelToJson(AttendanceResponseModel data) =>
    json.encode(data.toJson());

class AttendanceResponseModel {
  AttendanceResponseModel({
    required this.status,
    required this.message,
    required this.data,
  });

  final bool status;
  final String message;
  final List<AttendanceModel> data;

  factory AttendanceResponseModel.fromJson(Map<String, dynamic> json) =>
      AttendanceResponseModel(
        status: json["status"],
        message: json["message"],
        data: List<AttendanceModel>.from(
            json["data"].map((x) => AttendanceModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class AttendanceModel {
  AttendanceModel({
    required this.fromDate,
    required this.toDate,
    required this.att,
    required this.remark,
    required this.color,
  });

  final DateTime fromDate;
  final DateTime toDate;
  final String att;
  final String remark;
  final String color;

  factory AttendanceModel.fromJson(Map<String, dynamic> json) =>
      AttendanceModel(
        fromDate: DateTime.parse(json["fromDate"]),
        toDate: DateTime.parse(json["toDate"]),
        att: json["att"],
        remark: json["remark"],
        color: json["color"],
      );

  Map<String, dynamic> toJson() => {
        "fromDate":
            "${fromDate.year.toString().padLeft(4, '0')}-${fromDate.month.toString().padLeft(2, '0')}-${fromDate.day.toString().padLeft(2, '0')}",
        "toDate":
            "${toDate.year.toString().padLeft(4, '0')}-${toDate.month.toString().padLeft(2, '0')}-${toDate.day.toString().padLeft(2, '0')}",
        "att": att,
        "remark": remark,
        "color": color,
      };
}

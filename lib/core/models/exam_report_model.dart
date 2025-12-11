// To parse this JSON data, do
//
//     final examReportModel = examReportModelFromJson(jsonString);

import 'dart:convert';

import 'package:school_app/core/config/app_status.dart';

ExamReportModel examReportModelFromJson(String str) =>
    ExamReportModel.fromJson(json.decode(str));

String examReportModelToJson(ExamReportModel data) =>
    json.encode(data.toJson());

class ExamReport {
  final String acYearId;
  final List<ExamReportListElement> list;

  ExamReport({required this.acYearId, required this.list});

  factory ExamReport.fromJson(Map<String, dynamic> json) => ExamReport(
    acYearId: json["ac_year"],
    list: List<ExamReportListElement>.from(
      json["list"].map((x) => ExamReportListElement.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "ac_year": acYearId,
    "list": List<dynamic>.from(list.map((x) => x.toJson())),
  };
}

class ExamReportListElement {
  final String acYearId;
  final String acdYr;
  final String grade;
  final String dispGrade;
  final String sec;
  final String trmId;
  final String termName;
  final String exmId;
  final String examName;

  ExamReportListElement({
    required this.acYearId,
    required this.acdYr,
    required this.grade,
    required this.dispGrade,
    required this.sec,
    required this.trmId,
    required this.termName,
    required this.exmId,
    required this.examName,
  });

  factory ExamReportListElement.fromJson(Map<String, dynamic> json) =>
      ExamReportListElement(
        acYearId: json["ac_year_id"],
        acdYr: json["acdYr"],
        grade: json["grade"],
        dispGrade: json["dispGrade"],
        sec: json["sec"],
        trmId: json["trm_id"],
        termName: json["termName"],
        exmId: json["exm_id"],
        examName: json["examName"],
      );

  Map<String, dynamic> toJson() => {
    "ac_year_id": acYearId,
    "acdYr": acdYr,
    "grade": grade,
    "dispGrade": dispGrade,
    "sec": sec,
    "trm_id": trmId,
    "termName": termName,
    "exm_id": exmId,
    "examName": examName,
  };
}

class ExamReportModel {
  AppStates? status;
  final String? message;
  final List<ExamReport>? data;

  ExamReportModel({this.status, this.message, this.data});

  factory ExamReportModel.fromJson(Map<String, dynamic> json) =>
      ExamReportModel(
        message: json["message"],
        data: json['data'] == null
            ? []
            : List<ExamReport>.from(
                json["live_trips"]!.map((x) => ExamReport.fromJson(x)),
              ),
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

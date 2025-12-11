// To parse this JSON data, do
//
//     final feeListModel = feeListModelFromJson(jsonString);

import 'dart:convert';

import 'package:school_app/core/models/fees_model.dart';
import 'package:school_app/core/models/students_model.dart';

FeeListModel feeListModelFromJson(String str) =>
    FeeListModel.fromJson(json.decode(str));

String feeListModelToJson(FeeListModel data) => json.encode(data.toJson());

class FeeListModel {
  FeeListModel({
    required this.status,
    required this.message,
    required this.data,
    required this.chkboxReadOnly,
    required this.studentModel,
  });

  final bool status;
  final String message;
  final List<FeesModel> data;
  final bool chkboxReadOnly;
  final StudentModel studentModel;

  factory FeeListModel.fromJson(Map<String, dynamic> json) => FeeListModel(
    status: json["status"],
    message: json["message"],
    data: List<FeesModel>.from(json["data"].map((x) => FeesModel.fromJson(x))),
    chkboxReadOnly: json["chkbox_read_only"],
    studentModel: StudentModel.fromJson(json["studentDetails"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "chkbox_read_only": chkboxReadOnly,
  };
}

// To parse this JSON data, do
//
//     final feeResponseModel = feeResponseModelFromJson(jsonString);

import 'dart:convert';

FeeResponseModel feeResponseModelFromJson(String str) =>
    FeeResponseModel.fromJson(json.decode(str));

String feeResponseModelToJson(FeeResponseModel data) =>
    json.encode(data.toJson());

class FeeResponseModel {
  final bool status;

  final String message;
  final dynamic data;
  FeeResponseModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory FeeResponseModel.fromJson(Map<String, dynamic> json) =>
      FeeResponseModel(
        status: json["status"],
        message: json["message"],
        data: json["data"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data,
      };
}

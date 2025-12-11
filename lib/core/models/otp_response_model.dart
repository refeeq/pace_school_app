import 'dart:convert';

OtpResponseModel otpResponseModelFromJson(String str) =>
    OtpResponseModel.fromJson(json.decode(str));

String otpResponseModelToJson(OtpResponseModel data) =>
    json.encode(data.toJson());

class Data {
  final String token;

  final String famcode;
  Data({
    required this.token,
    required this.famcode,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        token: json["token"] ?? "",
        famcode: json["famcode"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "token": token,
        "famcode": famcode,
      };
}

class OtpResponseModel {
  final bool status;

  final String message;
  final Data? data;
  OtpResponseModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory OtpResponseModel.fromJson(Map<String, dynamic> json) =>
      OtpResponseModel(
        status: json["status"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data!.toJson(),
      };
}

import 'dart:convert';

LoginResponseModel loginResponseModelFromJson(String str) =>
    LoginResponseModel.fromJson(json.decode(str));

String loginResponseModelToJson(LoginResponseModel data) =>
    json.encode(data.toJson());

class LoginResponseModel {
  LoginResponseModel({
    required this.status,
    required this.message,
  });

  final bool status;
  final String message;

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
      LoginResponseModel(
        status: json["status"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
      };
}

class Data {
  Data({
    required this.token,
    required this.famcode,
  });

  final String token;
  final String famcode;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        token: json["token"],
        famcode: json["famcode"],
      );

  Map<String, dynamic> toJson() => {
        "token": token,
        "famcode": famcode,
      };
}

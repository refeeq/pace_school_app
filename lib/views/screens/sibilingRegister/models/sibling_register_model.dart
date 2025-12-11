// To parse this JSON data, do
//
//     final siblingRegisterModel = siblingRegisterModelFromJson(jsonString);

import 'dart:convert';

SiblingRegisterModel siblingRegisterModelFromJson(String str) =>
    SiblingRegisterModel.fromJson(json.decode(str));

String siblingRegisterModelToJson(SiblingRegisterModel data) =>
    json.encode(data.toJson());

class SiblingRegisterModel {
  final String? name;
  final String? acYear;
  final String? refNo;
  final String? sex;
  final String? appStateNo;
  final DateTime? dob;
  final String? siblingRegisterModelClass;
  final String? appStat;

  SiblingRegisterModel({
    this.name,
    this.acYear,
    this.refNo,
    this.sex,
    this.dob,
    this.appStateNo,
    this.siblingRegisterModelClass,
    this.appStat,
  });

  factory SiblingRegisterModel.fromJson(Map<String, dynamic> json) =>
      SiblingRegisterModel(
        name: json["name"],
        acYear: json["ac_year"],
        refNo: json["ref_no"],
        sex: json["sex"],
        appStateNo: json["app_status_id"],
        dob: json["dob"] == null ? null : DateTime.parse(json["dob"]),
        siblingRegisterModelClass: json["class"],
        appStat: json["app_stat"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "ac_year": acYear,
        "ref_no": refNo,
        "sex": sex,
        "dob":
            "${dob!.year.toString().padLeft(4, '0')}-${dob!.month.toString().padLeft(2, '0')}-${dob!.day.toString().padLeft(2, '0')}",
        "class": siblingRegisterModelClass,
        "app_stat": appStat,
      };
}

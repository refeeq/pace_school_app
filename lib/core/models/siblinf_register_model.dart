// To parse this JSON data, do
//
//     final siblingRegisterModel = siblingRegisterModelFromJson(jsonString);

import 'dart:convert';

SiblingRegisterModel siblingRegisterModelFromJson(String str) =>
    SiblingRegisterModel.fromJson(json.decode(str));

String siblingRegisterModelToJson(SiblingRegisterModel data) =>
    json.encode(data.toJson());

class SiblingRegisterModel {
  final String acYear;

  final String transport;
  final String prevSch;
  final String syllabus;
  final String emailAddress;
  final String phone2;
  final String phone;
  final String fname;
  final String landmark;
  final String location;
  final String secondLang;
  final String admGr;
  final String reside;
  final String dob;
  final String country;
  final String sex;
  final String name;
  final String ethnicity;
  SiblingRegisterModel({
    required this.acYear,
    required this.transport,
    required this.prevSch,
    required this.syllabus,
    required this.emailAddress,
    required this.phone2,
    required this.phone,
    required this.fname,
    required this.landmark,
    required this.location,
    required this.secondLang,
    required this.admGr,
    required this.reside,
    required this.dob,
    required this.country,
    required this.sex,
    required this.name,
    required this.ethnicity,
  });

  factory SiblingRegisterModel.fromJson(Map<String, dynamic> json) =>
      SiblingRegisterModel(
        acYear: json["ac_year"],
        transport: json["transport"],
        prevSch: json["prev_sch"],
        syllabus: json["syllabus"],
        emailAddress: json["email_address"],
        phone2: json["phone2"],
        phone: json["phone"],
        fname: json["fname"],
        landmark: json["landmark"],
        location: json["location"],
        secondLang: json["second_lang"],
        admGr: json["adm_gr"],
        reside: json["reside"],
        dob: json["dob"],
        country: json["country"],
        sex: json["sex"],
        name: json["name"],
        ethnicity: json["ethnicity"],
      );

  Map<String, dynamic> toJson() => {
        "ac_year": acYear,
        "transport": transport,
        "prev_sch": prevSch,
        "syllabus": syllabus,
        "email_address": emailAddress,
        "phone2": phone2,
        "phone": phone,
        "fname": fname,
        "landmark": landmark,
        "location": location,
        "second_lang": secondLang,
        "adm_gr": admGr,
        "reside": reside,
        "dob": dob,
        "country": country,
        "sex": sex,
        "name": name,
        "ethnicity": ethnicity,
      };
}

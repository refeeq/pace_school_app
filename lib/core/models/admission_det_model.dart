import 'dart:convert';

AdmissionResModel AdmissionResModelFromJson(String str) =>
    AdmissionResModel.fromJson(json.decode(str));

String AdmissionResModelToJson(AdmissionResModel data) =>
    json.encode(data.toJson());

class AdmissionResModel {
  AdmissionResModel({
    required this.grades,
    required this.sl,
    required this.acYear,
    required this.family,
    required this.ethnicity,
    required this.nationality,
  });

  final List<Grade> grades;
  final Family? family;
  final List<Grade> sl;
  final List<Grade> acYear;
  final List<Grade> nationality;
  final List<Grade> ethnicity;
  factory AdmissionResModel.fromJson(Map<String, dynamic> json) =>
      AdmissionResModel(
        grades: List<Grade>.from(json["grades"].map((x) => Grade.fromJson(x))),
        sl: List<Grade>.from(json["sl"].map((x) => Grade.fromJson(x))),
        acYear: List<Grade>.from(json["acYear"].map((x) => Grade.fromJson(x))),
        ethnicity:
            List<Grade>.from(json["ethnicity"].map((x) => Grade.fromJson(x))),
        nationality:
            List<Grade>.from(json["country"].map((x) => Grade.fromJson(x))),
        family: json["family"] == null ? null : Family.fromJson(json["family"]),
      );

  Map<String, dynamic> toJson() => {
        "grades": List<dynamic>.from(grades.map((x) => x.toJson())),
        "sl": List<dynamic>.from(sl.map((x) => x.toJson())),
      };
}

class Grade {
  Grade({
    required this.listKey,
    required this.listValue,
  });

  final String listKey;
  final String listValue;

  factory Grade.fromJson(Map<String, dynamic> json) => Grade(
        listKey: json["list_key"],
        listValue: json["list_value"],
      );

  Map<String, dynamic> toJson() => {
        "list_key": listKey,
        "list_value": listValue,
      };
}

class Family {
  Family({
    required this.fname,
    required this.gname,
    required this.mobile,
    required this.primaryContact,
    required this.email,
    required this.homeadd,
  });

  final String fname;
  final String gname;
  final String mobile;
  final String primaryContact;
  final String email;
  final String homeadd;

  factory Family.fromJson(Map<String, dynamic> json) => Family(
        fname: json["fname"],
        gname: json["gname"],
        mobile: json["mobile"],
        primaryContact: json["primary_contact"],
        email: json["email"],
        homeadd: json["homeadd"],
      );

  Map<String, dynamic> toJson() => {
        "fname": fname,
        "gname": gname,
        "mobile": mobile,
        "primary_contact": primaryContact,
        "email": email,
        "homeadd": homeadd,
      };
}

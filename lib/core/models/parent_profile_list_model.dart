// To parse this JSON data, do
//
//     final parentProfileListModel = parentProfileListModelFromJson(jsonString);

import 'dart:convert';

ParentProfileListModel parentProfileListModelFromJson(String str) =>
    ParentProfileListModel.fromJson(json.decode(str));

String parentProfileListModelToJson(ParentProfileListModel data) =>
    json.encode(data.toJson());

class Common {
  final String famcode;

  final String fname;
  final String gname;
  final String province;
  final String occupa;
  final String company;
  final String companyadd;
  final String pobox;
  final String offcity;
  final String restel;
  final String offtel;
  final String mobile;
  final String homeadd;
  final String rescity;
  final String mname;
  final String moccup;
  final String mmob;
  final String email;
  final String comNumber;
  final String mcomp;
  final String memail;
  final String memirate;
  final String mofficetel;
  final String mpobox;
  final String primaryContact;
  final dynamic fEid;
  final dynamic mEid;
  final dynamic communityId;
  final dynamic flatNo;
  final dynamic buildingName;

  Common({
    required this.famcode,
    required this.fname,
    required this.gname,
    required this.province,
    required this.occupa,
    required this.company,
    required this.companyadd,
    required this.pobox,
    required this.offcity,
    required this.restel,
    required this.offtel,
    required this.mobile,
    required this.homeadd,
    required this.rescity,
    required this.mname,
    required this.moccup,
    required this.mmob,
    required this.email,
    required this.comNumber,
    required this.mcomp,
    required this.memail,
    required this.memirate,
    required this.mofficetel,
    required this.mpobox,
    required this.primaryContact,
    required this.fEid,
    required this.mEid,
    required this.communityId,
    required this.flatNo,
    required this.buildingName,
  });

  factory Common.fromJson(Map<String, dynamic> json) => Common(
        famcode: json["famcode"] ?? "",
        fname: json["fname"] ?? "",
        gname: json["gname"] ?? "",
        province: json["province"] ?? "",
        occupa: json["occupa"] ?? "",
        company: json["company"] ?? "",
        companyadd: json["companyadd"] ?? "",
        pobox: json["pobox"] ?? "",
        offcity: json["offcity"] ?? "",
        restel: json["restel"] ?? "",
        offtel: json["offtel"] ?? "",
        mobile: json["mobile"] ?? "",
        homeadd: json["homeadd"] ?? "",
        rescity: json["rescity"] ?? "",
        mname: json["mname"] ?? "",
        moccup: json["moccup"] ?? "",
        mmob: json["mmob"] ?? "",
        email: json["email"] ?? "",
        comNumber: json["com_number"] ?? "",
        mcomp: json["mcomp"] ?? "",
        memail: json["memail"] ?? "",
        memirate: json["memirate"] ?? "",
        mofficetel: json["mofficetel"] ?? "",
        mpobox: json["mpobox"] ?? "",
        primaryContact: json["primary_contact"] ?? "",
        fEid: json["f_eid"] ?? "",
        mEid: json["m_eid"] ?? "",
        communityId: json["community_id"] ?? "",
        flatNo: json["flat_no"] ?? "",
        buildingName: json["building_name"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "famcode": famcode,
        "fname": fname,
        "gname": gname,
        "province": province,
        "occupa": occupa,
        "company": company,
        "companyadd": companyadd,
        "pobox": pobox,
        "offcity": offcity,
        "restel": restel,
        "offtel": offtel,
        "mobile": mobile,
        "homeadd": homeadd,
        "rescity": rescity,
        "mname": mname,
        "moccup": moccup,
        "mmob": mmob,
        "email": email,
        "com_number": comNumber,
        "mcomp": mcomp,
        "memail": memail,
        "memirate": memirate,
        "mofficetel": mofficetel,
        "mpobox": mpobox,
        "primary_contact": primaryContact,
        "f_eid": fEid,
        "m_eid": mEid,
        "community_id": communityId,
        "flat_no": flatNo,
        "building_name": buildingName,
      };
}

class Datum {
  final String name;
  final String photo;
  final String famcode;
  final String mobile;
  final String email;
  final String occupation;
  final String company;
  final String offcity;
  final String rescity;
  final String relation;
  Datum({
    required this.name,
    required this.famcode,
    required this.mobile,
    required this.email,
    required this.occupation,
    required this.company,
    required this.offcity,
    required this.rescity,
    required this.relation,
    required this.photo,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        name: json["name"] ?? "",
        famcode: json["famcode"] ?? "",
        mobile: json["mobile"] ?? "",
        photo: json["photo"] ?? "",
        email: json["email"] ?? "",
        occupation: json["occupation"] ?? "",
        company: json["company"] ?? "",
        offcity: json["offcity"] ?? "",
        rescity: json["rescity"] ?? "",
        relation: json["relation"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "famcode": famcode,
        "mobile": mobile,
        "email": email,
        "occupation": occupation,
        "company": company,
        "offcity": offcity,
        "rescity": rescity,
        "relation": relation,
      };
}

class ParentProfileListModel {
  final bool status;

  final String message;
  final List<Datum> data;
  final Common common;
  ParentProfileListModel({
    required this.status,
    required this.message,
    required this.data,
    required this.common,
  });

  factory ParentProfileListModel.fromJson(Map<String, dynamic> json) =>
      ParentProfileListModel(
        status: json["status"] ?? "",
        message: json["message"] ?? "",
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
        common: Common.fromJson(json["common"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "common": common.toJson(),
      };
}

// To parse this JSON data, do
//
//     final parentProfileListModel = parentProfileListModelFromJson(jsonString);

import 'dart:convert';

ParentProfileListModel parentProfileListModelFromJson(String str) =>
    ParentProfileListModel.fromJson(json.decode(str));

String parentProfileListModelToJson(ParentProfileListModel data) =>
    json.encode(data.toJson());

class Emirate {
  final int id;
  final String emirate;

  Emirate({
    required this.id,
    required this.emirate,
  });

  factory Emirate.fromJson(Map<String, dynamic> json) => Emirate(
        id: json["id"] ?? 0,
        emirate: json["emirate"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "emirate": emirate,
      };
}

class Community {
  final int id;
  final int emirateId;
  final String communityName;

  Community({
    required this.id,
    required this.emirateId,
    required this.communityName,
  });

  factory Community.fromJson(Map<String, dynamic> json) => Community(
        id: json["id"] ?? 0,
        emirateId: json["emirate_id"] ?? 0,
        communityName: json["community_name"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "emirate_id": emirateId,
        "community_name": communityName,
      };
}

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
  final dynamic fEidExp;
  final dynamic mEidExp;
  final dynamic communityId;
  final dynamic flatNo;
  final dynamic buildingName;
  final String communityName;

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
    required this.fEidExp,
    required this.mEidExp,
    required this.communityId,
    required this.flatNo,
    required this.buildingName,
    required this.communityName,
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
        fEidExp: json["f_eid_exp"] ?? "",
        mEidExp: json["m_eid_exp"] ?? "",
        communityId: json["community_id"] ?? "",
        flatNo: json["flat_no"] ?? "",
        buildingName: json["building_name"] ?? "",
        communityName: json["community_name"] ?? "",
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
        "f_eid_exp": fEidExp,
        "m_eid_exp": mEidExp,
        "community_id": communityId,
        "flat_no": flatNo,
        "building_name": buildingName,
        "community_name": communityName,
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
        "photo": photo,
      };
}

class ParentProfileListModel {
  final List<Emirate> emirate;
  final List<Community> community;
  final bool status;
  final String message;
  final List<Datum> data;
  final Common common;

  ParentProfileListModel({
    required this.emirate,
    required this.community,
    required this.status,
    required this.message,
    required this.data,
    required this.common,
  });

  factory ParentProfileListModel.fromJson(Map<String, dynamic> json) =>
      ParentProfileListModel(
        emirate: json["emirate"] != null
            ? List<Emirate>.from(
                json["emirate"].map((x) => Emirate.fromJson(x)))
            : [],
        community: json["community"] != null
            ? List<Community>.from(
                json["community"].map((x) => Community.fromJson(x)))
            : [],
        status: json["status"] == true,
        message: json["message"] ?? "",
        data: json["data"] != null
            ? List<Datum>.from(json["data"].map((x) => Datum.fromJson(x)))
            : [],
        common: Common.fromJson(json["common"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "emirate": List<dynamic>.from(emirate.map((x) => x.toJson())),
        "community": List<dynamic>.from(community.map((x) => x.toJson())),
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "common": common.toJson(),
      };
}

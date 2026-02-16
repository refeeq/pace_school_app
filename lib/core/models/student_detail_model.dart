// To parse this JSON data, do
//
//     final studentDetailModel = studentDetailModelFromJson(jsonString);

import 'dart:convert';

StudentDetailModel studentDetailModelFromJson(String str) =>
    StudentDetailModel.fromJson(json.decode(str));

String studentDetailModelToJson(StudentDetailModel data) =>
    json.encode(data.toJson());

class Data {
  final String studcode;

  final String fullname;
  final String entdate;
  final String dataClass;
  final String section;
  final String studStat;
  final String acdyear;
  final String acYearId;
  final String stdsex;
  final String datbirth;
  final String nationality;
  final String birthplac;
  final String passno;
  final String ppIssueDate;
  final String ppExpDate;
  final String visano;
  final String visaIssueDate;
  final String visaExpDate;
  final String emiratesId;
  final String emiratesIdExp;
  final String photo;
  final String statusLabel;
  final String statusShortcode;
  final String statusColour;
  final String statusFinalStat;
  final dynamic studentReregistered;
  final String studentReregStat;
  final String studentReregLabel;
  Data({
    required this.studcode,
    required this.fullname,
    required this.entdate,
    required this.dataClass,
    required this.section,
    required this.studStat,
    required this.acdyear,
    required this.acYearId,
    required this.stdsex,
    required this.datbirth,
    required this.nationality,
    required this.birthplac,
    required this.passno,
    required this.ppIssueDate,
    required this.ppExpDate,
    required this.visano,
    required this.visaIssueDate,
    required this.visaExpDate,
    required this.emiratesId,
    required this.emiratesIdExp,
    required this.photo,
    this.statusLabel = "",
    this.statusShortcode = "",
    this.statusColour = "",
    this.statusFinalStat = "0",
    this.studentReregistered,
    this.studentReregStat = "",
    this.studentReregLabel = "",
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        studcode: json["studcode"] ?? "",
        fullname: json["fullname"] ?? "",
        entdate: json["ENTDATE"] ?? "",
        dataClass: json["class"] ?? "",
        section: json["section"] ?? "",
        studStat: json["stud_stat"] ?? "",
        acdyear: json["acdyear"] ?? "",
        acYearId: json["ac_year_id"] ?? "",
        stdsex: json["STDSEX"] ?? "",
        datbirth: json["DATBIRTH"] ?? "",
        nationality: json["nationality"] ?? "",
        birthplac: json["birthplac"] ?? "",
        passno: json["passno"] ?? "",
        ppIssueDate: json["pp_issue_date"] ?? "",
        ppExpDate: json["pp_exp_date"] ?? "",
        visano: json["visano"] ?? "",
        visaIssueDate: json["visa_issue_date"] ?? "",
        visaExpDate: json["visa_exp_date"] ?? "",
        emiratesId: json["emirates_id"] ?? "",
        emiratesIdExp: json["emirates_id_exp"] ?? "",
        photo: json["photo"] ?? "",
        statusLabel: json["status_label"] ?? "",
        statusShortcode: json["status_shortcode"] ?? "",
        statusColour: json["status_colour"] ?? "",
        statusFinalStat: json["status_final_stat"]?.toString() ?? "0",
        studentReregistered: json["student_reregistered"],
        studentReregStat: json["student_rereg_stat"]?.toString() ?? "",
        studentReregLabel: json["student_rereg_label"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "studcode": studcode,
        "fullname": fullname,
        "ENTDATE": entdate,
        "class": dataClass,
        "section": section,
        "stud_stat": studStat,
        "acdyear": acdyear,
        "ac_year_id": acYearId,
        "STDSEX": stdsex,
        "DATBIRTH": datbirth,
        "nationality": nationality,
        "birthplac": birthplac,
        "passno": passno,
        "pp_issue_date": ppIssueDate,
        "pp_exp_date": ppExpDate,
        "visano": visano,
        "visa_issue_date": visaIssueDate,
        "visa_exp_date": visaExpDate,
        "emirates_id": emiratesId,
        "emirates_id_exp": emiratesIdExp,
        "photo": photo,
        "status_label": statusLabel,
        "status_shortcode": statusShortcode,
        "status_colour": statusColour,
        "status_final_stat": statusFinalStat,
        "student_reregistered": studentReregistered,
        "student_rereg_stat": studentReregStat,
        "student_rereg_label": studentReregLabel,
      };
}

class Parent {
  final String name;

  final String famcode;
  final String mobile;
  final String email;
  final String relation;
  Parent({
    required this.name,
    required this.famcode,
    required this.mobile,
    required this.email,
    required this.relation,
  });

  factory Parent.fromJson(Map<String, dynamic> json) => Parent(
        name: json["name"] ?? "",
        famcode: json["famcode"] ?? "",
        mobile: json["mobile"] ?? "",
        email: json["email"] ?? "",
        relation: json["relation"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "famcode": famcode,
        "mobile": mobile,
        "email": email,
        "relation": relation,
      };
}

class ParentData {
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

  final String primaryContact;
  final dynamic fEid;
  final dynamic mEid;
  final dynamic communityId;
  final dynamic flatNo;
  final dynamic buildingName;
  ParentData({
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
    required this.primaryContact,
    required this.fEid,
    required this.mEid,
    required this.communityId,
    required this.flatNo,
    required this.buildingName,
  });

  factory ParentData.fromJson(Map<String, dynamic> json) => ParentData(
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
        homeadd: json["homeadd"] ?? '',
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
        primaryContact: json["primary_contact"] ?? "",
        fEid: json["f_eid"] ?? "",
        mEid: json["m_eid"] ?? "",
        communityId: json["community_id"] ?? "",
        flatNo: json["flat_no"] ?? '',
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
        "primary_contact": primaryContact,
        "f_eid": fEid,
        "m_eid": mEid,
        "community_id": communityId,
        "flat_no": flatNo,
        "building_name": buildingName,
      };
}

class StudentDetailModel {
  final ParentData parentData;

  final Parent parent;
  final bool status;
  final String message;
  final Data data;
  StudentDetailModel({
    required this.parentData,
    required this.parent,
    required this.status,
    required this.message,
    required this.data,
  });

  factory StudentDetailModel.fromJson(Map<String, dynamic> json) =>
      StudentDetailModel(
        parentData: ParentData.fromJson(json["parent_data"]),
        parent: Parent.fromJson(json["parent"]),
        status: json["status"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "parent_data": parentData.toJson(),
        "parent": parent.toJson(),
        "status": status,
        "message": message,
        "data": data.toJson(),
      };
}

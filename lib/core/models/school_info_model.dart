// To parse this JSON data, do
//
//     final schoolInfoModel = schoolInfoModelFromJson(jsonString);

// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

SchoolInfoModel schoolInfoModelFromJson(String str) =>
    SchoolInfoModel.fromJson(json.decode(str));

String schoolInfoModelToJson(SchoolInfoModel data) =>
    json.encode(data.toJson());

// class SchoolInfoModel {
//   SchoolInfoModel({
//     required this.status,
//     required this.message,
//     required this.data,
//   });

//   final bool status;
//   final String message;
//   final Data? data;

//   factory SchoolInfoModel.fromJson(Map<String, dynamic> json) =>
//       SchoolInfoModel(
//         status: json["status"],
//         message: json["message"],
//         data: Data.fromJson(json["data"]),
//       );

//   Map<String, dynamic> toJson() => {
//         "status": status,
//         "message": message,
//         "data": data!.toJson(),
//       };
// }

class SchoolInfoModel {
  final String? name;

  final String? address;
  final String? description;
  final String logo;
  final String? facebook;
  final String? youtube;
  final String? instagram;
  final String? website;
  final String? contact;
  final String? whatsapp;
  final String? email;
  final String? location_iframe;
  final String? location_lat;
  final String? location_long;
  final String? curriculum;
  SchoolInfoModel({
    required this.name,
    required this.address,
    required this.description,
    required this.logo,
    required this.facebook,
    required this.youtube,
    required this.instagram,
    required this.website,
    required this.contact,
    required this.whatsapp,
    required this.email,
    required this.location_iframe,
    required this.location_lat,
    required this.location_long,
    required this.curriculum,
  });

  factory SchoolInfoModel.fromJson(Map<String, dynamic> json) =>
      SchoolInfoModel(
        name: json["Name"],
        address: json["Address"],
        description: json["Description"],
        logo: json["Logo"],
        facebook: json["Facebook"],
        youtube: json["Youtube"],
        instagram: json["Instagram"],
        website: json["Website"],
        contact: json["Contact"],
        whatsapp: json["Whatsapp"],
        email: json["Email"] ?? "",
        location_iframe: json["location_iframe"] ?? "",
        location_lat: json["location_lat"] ?? "",
        location_long: json["location_long"] ?? "",
        curriculum: json['curriculum'] ?? "",
      );

  Map<String, dynamic> toJson() => {
    "Name": name,
    "Address": address,
    "Description": description,
    "Logo": logo,
    "Facebook": facebook,
    "Youtube": youtube,
    "Instagram": instagram,
    "Website": website,
    "Contact": contact,
    "Whatsapp": whatsapp,
    "Email": email,
  };
}

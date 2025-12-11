// To parse this JSON data, do
//
//     final studentsModel = studentsModelFromJson(jsonString);

import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:school_app/core/models/parent_model.dart';
import 'package:school_app/core/models/slider_model.dart';
import 'package:school_app/core/models/transaction_model.dart';

part 'students_model.g.dart';

StudentsModel studentsModelFromJson(String str) =>
    StudentsModel.fromJson(json.decode(str));

String studentsModelToJson(StudentsModel data) => json.encode(data.toJson());

class Menu {
  final String id;

  final String menuKey;
  final String menuValue;
  final String webUrl;
  final String iconUrl;
  Menu({
    required this.id,
    required this.webUrl,
    required this.iconUrl,
    required this.menuKey,
    required this.menuValue,
  });
  factory Menu.fromJson(Map<String, dynamic> json) => Menu(
    id: json["id"],
    iconUrl: json["icon_url"] ?? "",
    webUrl: json["web_url"] ?? '',
    menuKey: json["menu_key"],
    menuValue: json["menu_val"],
  );

  Map<String, dynamic> toJson() => {"id": id};
}

@HiveType(typeId: 2)
class StudentModel {
  @HiveField(0)
  final String studcode;
  @HiveField(1)
  final String fullname;
  @HiveField(2)
  final String datumClass;
  @HiveField(3)
  final String section;
  @HiveField(4)
  final String studStat;
  @HiveField(5)
  final String acdyear;
  @HiveField(6)
  final String acYearId;
  @HiveField(7)
  final String photo;
  StudentModel({
    required this.studcode,
    required this.fullname,
    required this.datumClass,
    required this.section,
    required this.studStat,
    required this.acdyear,
    required this.acYearId,
    required this.photo,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) => StudentModel(
    studcode: json["studcode"],
    fullname: json["fullname"],
    datumClass: json["class"],
    section: json["section"],
    studStat: json["stud_stat"],
    acdyear: json["acdyear"],
    acYearId: json["ac_year_id"],
    photo: json["photo"],
  );

  Map<String, dynamic> toJson() => {
    "studcode": studcode,
    "fullname": fullname,
    "class": datumClass,
    "section": section,
    "stud_stat": studStat,
    "acdyear": acdyear,
    "ac_year_id": acYearId,
    "photo": photo,
  };
}

class StudentsModel {
  final bool status;

  final String message;
  final List<StudentModel> data;
  final ParentModel parent;
  final List<Menu> menu;
  final List<Transaction> transactions;
  final List<SliderModel> sliderModel;
  StudentsModel({
    required this.status,
    required this.message,
    required this.data,
    required this.parent,
    required this.menu,
    required this.transactions,
    required this.sliderModel,
  });
  factory StudentsModel.fromJson(Map<String, dynamic> json) {
    //adding notification count to badge
    // if (json['notify_count'] != null || json['notify_count'] != 0) {
    //   log("all notoification Count ${json['notify_count']}");
    //   NotificationServices.addNotification(json['notify_count']);
    // }
    return StudentsModel(
      status: json["status"],
      message: json["message"],
      data: List<StudentModel>.from(
        json["data"].map((x) => StudentModel.fromJson(x)),
      ),
      parent: ParentModel.fromJson(json["parent"]),
      menu: List<Menu>.from(json["menu"].map((x) => Menu.fromJson(x))),
      transactions: List<Transaction>.from(
        json["transactions"].map((x) => Transaction.fromJson(x)),
      ),
      sliderModel: List<SliderModel>.from(
        json["slider"].map((x) => SliderModel.fromJson(x)),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

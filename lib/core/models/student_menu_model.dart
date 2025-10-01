// To parse this JSON data, do
//
//     final studentMenuModel = studentMenuModelFromJson(jsonString);

import 'dart:convert';

StudentMenuModel studentMenuModelFromJson(String str) =>
    StudentMenuModel.fromJson(json.decode(str));

String studentMenuModelToJson(StudentMenuModel data) =>
    json.encode(data.toJson());

class StudentMenu {
  final String id;
  final String menuKey;
  final String menuValue;

  final String iconUrl;
  final String? weburl;
  final List<StudentMenu>? subMenu;
  StudentMenu({
    required this.id,
    required this.iconUrl,
    required this.subMenu,
    required this.weburl,
    required this.menuKey,
    required this.menuValue,
  });

  factory StudentMenu.fromJson(Map<String, dynamic> json) => StudentMenu(
        id: json["id"],
        iconUrl: json["icon_url"] ?? "",
        weburl: json['url'],
        subMenu: json["sub_menu"] == null
            ? null
            : List<StudentMenu>.from(
                json["sub_menu"].map((x) => StudentMenu.fromJson(x))),
        menuKey: json["menu_key"],
        menuValue: json["menu_val"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "icon_url": iconUrl,
        "sub_menu": subMenu == null
            ? null
            : List<dynamic>.from(subMenu!.map((x) => x.toJson())),
      };
}

class StudentMenuModel {
  final bool status;

  final String message;
  final List<StudentMenu> data;
  StudentMenuModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory StudentMenuModel.fromJson(Map<String, dynamic> json) =>
      StudentMenuModel(
        status: json["status"],
        message: json["message"],
        data: List<StudentMenu>.from(
            json["data"].map((x) => StudentMenu.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

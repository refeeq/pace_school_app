import 'dart:convert';
import 'dart:developer';

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

/// Minimum version requirements for a single platform (iOS or Android).
class AppVersionInfo {
  final String minimumVersion;
  final int minimumBuild;

  AppVersionInfo({
    required this.minimumVersion,
    required this.minimumBuild,
  });

  factory AppVersionInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return AppVersionInfo(minimumVersion: '', minimumBuild: 0);
    }
    return AppVersionInfo(
      minimumVersion: (json['minimumVersion'] ?? json['minimum_version'] ?? '')
          .toString()
          .trim(),
      minimumBuild: _parseInt(json['minimumBuild'] ?? json['minimum_build'], 0),
    );
  }

  static int _parseInt(dynamic value, int fallback) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is String) return int.tryParse(value.trim()) ?? fallback;
    return fallback;
  }
}

/// App version requirements for both platforms and force-update flag.
class AppVersionData {
  final AppVersionInfo ios;
  final AppVersionInfo android;
  final bool forceUpdate;

  AppVersionData({
    required this.ios,
    required this.android,
    required this.forceUpdate,
  });

  factory AppVersionData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return AppVersionData(
        ios: AppVersionInfo.fromJson(null),
        android: AppVersionInfo.fromJson(null),
        forceUpdate: false,
      );
    }
    final rawIos = json['ios'];
    final rawAndroid = json['android'];
    return AppVersionData(
      ios: AppVersionInfo.fromJson(
        rawIos is Map<String, dynamic> ? rawIos : null,
      ),
      android: AppVersionInfo.fromJson(
        rawAndroid is Map<String, dynamic> ? rawAndroid : null,
      ),
      forceUpdate: json['forceUpdate'] == true ||
          json['force_update'] == true,
    );
  }
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
  @HiveField(8)
  final String statusLabel;
  @HiveField(9)
  final String statusColour;
  StudentModel({
    required this.studcode,
    required this.fullname,
    required this.datumClass,
    required this.section,
    required this.studStat,
    required this.acdyear,
    required this.acYearId,
    required this.photo,
    this.statusLabel = "",
    this.statusColour = "",
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
        statusLabel: json["status_label"] ?? "",
        statusColour: json["status_colour"] ?? "",
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
        "status_label": statusLabel,
        "status_colour": statusColour,
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
  final List<String>? topics;
  final AppVersionData? appVersion;

  StudentsModel({
    required this.status,
    required this.message,
    required this.data,
    required this.parent,
    required this.menu,
    required this.transactions,
    required this.sliderModel,
    this.topics,
    this.appVersion,
  });

  factory StudentsModel.fromJson(Map<String, dynamic> json) {
    List<String>? topics;
    try {
      if (json["topics"] != null && json["topics"] is List) {
        topics = List<String>.from(
          (json["topics"] as List).map((x) => x.toString()),
        );
      }
    } catch (e) {
      log('[FORCE_UPDATE] Error parsing topics: $e');
      topics = null;
    }

    AppVersionData? appVersion;
    try {
      final raw = json["appVersion"] ?? json["app_version"];
      if (raw != null && raw is Map<String, dynamic>) {
        appVersion = AppVersionData.fromJson(raw);
        log('[FORCE_UPDATE] 📋 Parsed appVersion from API response');
      } else {
        log('[FORCE_UPDATE] 📋 No appVersion field found in API response');
      }
    } catch (e) {
      log('[FORCE_UPDATE] ❌ Error parsing appVersion: $e');
      appVersion = null;
    }

    // Safe parsing with fallbacks
    List<StudentModel> data = [];
    try {
      if (json["data"] is List) {
        data = List<StudentModel>.from(
          (json["data"] as List<dynamic>).map((x) {
            if (x is Map<String, dynamic>) {
              return StudentModel.fromJson(x);
            }
            return null;
          }).whereType<StudentModel>(),
        );
      }
    } catch (e) {
      log('Error parsing student data: $e');
      data = [];
    }

    ParentModel parent;
    try {
      if (json["parent"] is Map<String, dynamic>) {
        parent = ParentModel.fromJson(json["parent"] as Map<String, dynamic>);
      } else {
        throw Exception('Parent data is not a valid map');
      }
    } catch (e) {
      log('Error parsing parent data: $e');
      rethrow; // Parent is required, so we rethrow
    }

    List<Menu> menu = [];
    try {
      if (json["menu"] is List) {
        menu = List<Menu>.from(
          (json["menu"] as List<dynamic>).map((x) {
            if (x is Map<String, dynamic>) {
              return Menu.fromJson(x);
            }
            return null;
          }).whereType<Menu>(),
        );
      }
    } catch (e) {
      log('Error parsing menu data: $e');
      menu = [];
    }

    List<Transaction> transactions = [];
    try {
      if (json["transactions"] is List) {
        transactions = List<Transaction>.from(
          (json["transactions"] as List<dynamic>).map((x) {
            if (x is Map<String, dynamic>) {
              return Transaction.fromJson(x);
            }
            return null;
          }).whereType<Transaction>(),
        );
      }
    } catch (e) {
      log('Error parsing transactions: $e');
      transactions = [];
    }

    List<SliderModel> sliderModel = [];
    try {
      if (json["slider"] is List) {
        sliderModel = List<SliderModel>.from(
          (json["slider"] as List<dynamic>).map((x) {
            if (x is Map<String, dynamic>) {
              return SliderModel.fromJson(x);
            }
            return null;
          }).whereType<SliderModel>(),
        );
      }
    } catch (e) {
      log('Error parsing slider data: $e');
      sliderModel = [];
    }

    return StudentsModel(
      status: json["status"] == true,
      message: (json["message"] ?? '').toString(),
      data: data,
      parent: parent,
      menu: menu,
      transactions: transactions,
      sliderModel: sliderModel,
      topics: topics,
      appVersion: appVersion,
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

import 'package:school_app/core/models/students_model.dart';

class NotificationModel {
  final String id;

  final String studcode;
  final String notification;
  final dynamic page;
  final String head;
  final String dateAdded;
  final String action;
  final String actionStatus;
  final String? link;
  final StudentModel? student;
  String readStatus;
  NotificationModel({
    required this.id,
    required this.studcode,
    required this.notification,
    required this.page,
    required this.head,
    required this.dateAdded,
    required this.readStatus,
    required this.action,
    required this.actionStatus,
    this.student,
    this.link,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json["id"],
        studcode: json["studcode"],
        notification: json["notification"],
        page: json["page"],
        head: json["head"],
        dateAdded: json["time_ago"],
        readStatus: json["read_stat"],
        action: json["action"] ?? "",
        link: json["link"],
        student: json['student'] == null
            ? null
            : StudentModel.fromJson(json["student"]),
        actionStatus: json['action_name'] ?? "",
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "studcode": studcode,
    "notification": notification,
    "page": page,
    "head": head,
    "date_added": dateAdded,
  };
}

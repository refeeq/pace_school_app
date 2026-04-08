// To parse this JSON data, do
//
//     final communicationTileModel = communicationTileModelFromJson(jsonString);

import 'dart:convert';

CommunicationTileModel communicationTileModelFromJson(String str) =>
    CommunicationTileModel.fromJson(json.decode(str));

String communicationTileModelToJson(CommunicationTileModel data) =>
    json.encode(data.toJson());

class CommunicationTileModel {
  CommunicationTileModel({
    required this.id,
    required this.type,
    required this.iconUrl,
    required this.cnt,
    required this.lastMessage,
    required this.dateAdded,
  });

  final String id;
  final String type;
  final String iconUrl;
  final String lastMessage;
  int cnt;
  final String dateAdded;

  factory CommunicationTileModel.fromJson(Map<String, dynamic> json) =>
      CommunicationTileModel(
        id: json["id"],
        type: json["type"],
        iconUrl: json["icon_url"],
        dateAdded: json["date_added"] ?? "",
        cnt: json["cnt"],
        lastMessage: json["last_msg"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
        "icon_url": iconUrl,
        "cnt": cnt,
      };
}

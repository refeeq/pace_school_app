// To parse this JSON data, do
//
//     final busTrackModel = busTrackModelFromJson(jsonString);

import 'dart:convert';

import 'package:school_app/views/screens/bus_track/models/bus_track_data_model.dart';

BusTrackModel busTrackModelFromJson(String str) =>
    BusTrackModel.fromJson(json.decode(str));

String busTrackModelToJson(BusTrackModel data) => json.encode(data.toJson());

class BusTrackModel {
  final bool? status;
  final String? message;
  final BusTrackDataModel? data;

  BusTrackModel({this.status, this.message, this.data});

  factory BusTrackModel.fromJson(Map<String, dynamic> json) => BusTrackModel(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null
        ? null
        : BusTrackDataModel.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

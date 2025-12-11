import 'package:school_app/views/screens/bus_track/models/live_trip.dart';
import 'package:school_app/views/screens/bus_track/models/student_track_model.dart';
import 'package:school_app/views/screens/bus_track/models/transport_data_model.dart';

class BusTrackDataModel {
  final TransportDataModel? transportData;
  final List<StudentTrackModel>? studentTrack;
  final List<LiveTrip>? liveTrips;
  final String type;
  BusTrackDataModel({
    this.transportData,
    this.studentTrack,
    required this.type,
    this.liveTrips,
  });

  factory BusTrackDataModel.fromJson(Map<String, dynamic> json) =>
      BusTrackDataModel(
        liveTrips: json["live_trips"] == null
            ? []
            : List<LiveTrip>.from(
                json["live_trips"]!.map((x) => LiveTrip.fromJson(x)),
              ),
        type: json["type"],
        transportData: json["transport_data"] == null
            ? null
            : TransportDataModel.fromJson(json["transport_data"]),
        studentTrack: json["student_track"] == null
            ? []
            : List<StudentTrackModel>.from(
                json["student_track"]!.map(
                  (x) => StudentTrackModel.fromJson(x),
                ),
              ),
      );

  Map<String, dynamic> toJson() => {
    "transport_data": transportData?.toJson(),
    "live_trips": liveTrips == null
        ? []
        : List<dynamic>.from(liveTrips!.map((x) => x.toJson())),
    "student_track": studentTrack == null
        ? []
        : List<dynamic>.from(studentTrack!.map((x) => x.toJson())),
  };
}

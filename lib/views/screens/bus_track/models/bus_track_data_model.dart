import 'package:school_app/views/screens/bus_track/models/live_trip.dart';
import 'package:school_app/views/screens/bus_track/models/student_track_model.dart';
import 'package:school_app/views/screens/bus_track/models/transport_data_model.dart';

/// API config for map provider (e.g. Google Maps api_key).
class BusTrackApiConfig {
  final String? apiIndex;
  final String? apiKey;

  BusTrackApiConfig({this.apiIndex, this.apiKey});

  factory BusTrackApiConfig.fromJson(Map<String, dynamic>? json) {
    if (json == null) return BusTrackApiConfig();
    return BusTrackApiConfig(
      apiIndex: json["api_index"] as String?,
      apiKey: json["api_key"] as String?,
    );
  }
}

class BusTrackDataModel {
  final TransportDataModel? transportData;
  final List<StudentTrackModel>? studentTrack;
  final List<LiveTrip>? liveTrips;
  final String type;
  /// When true, show Google Maps; when false, show MapTiler map.
  final bool useGoogleMaps;
  final BusTrackApiConfig? api;

  BusTrackDataModel({
    this.transportData,
    this.studentTrack,
    required this.type,
    this.liveTrips,
    this.useGoogleMaps = false,
    this.api,
  });

  factory BusTrackDataModel.fromJson(Map<String, dynamic> json) =>
      BusTrackDataModel(
        liveTrips: json["live_trips"] == null
            ? []
            : List<LiveTrip>.from(
                json["live_trips"]!.map((x) => LiveTrip.fromJson(x)),
              ),
        type: json["type"] ?? '',
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
        useGoogleMaps: json["use_google_map"] == true,
        api: BusTrackApiConfig.fromJson(json["api"] as Map<String, dynamic>?),
      );

  Map<String, dynamic> toJson() => {
        "transport_data": transportData?.toJson(),
        "live_trips": liveTrips == null
            ? []
            : List<dynamic>.from(liveTrips!.map((x) => x.toJson())),
        "student_track": studentTrack == null
            ? []
            : List<dynamic>.from(studentTrack!.map((x) => x.toJson())),
        "use_google_map": useGoogleMaps,
      };
}

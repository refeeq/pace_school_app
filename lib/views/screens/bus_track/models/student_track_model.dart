class StudentTrackModel {
  final String? trackId;
  final String? childId;
  final String? admnNo;
  final DateTime? entryTime;
  final DateTime? exitTime;
  final String? entryStat;
  final String? exitStat;
  final String? entryLat;
  final String? entryLong;
  final String? exitLat;
  final String? exitLong;
  final String? nfcTag;
  final dynamic dateAdded;
  final String? tripId;
  final String? except;
  final String busNO;

  StudentTrackModel({
    this.trackId,
    this.childId,
    this.admnNo,
    this.entryTime,
    this.exitTime,
    this.entryStat,
    this.exitStat,
    this.entryLat,
    this.entryLong,
    this.exitLat,
    this.exitLong,
    this.nfcTag,
    this.dateAdded,
    this.tripId,
    this.except,
    required this.busNO,
  });

  factory StudentTrackModel.fromJson(Map<String, dynamic> json) =>
      StudentTrackModel(
          trackId: json["track_id"],
          childId: json["child_id"],
          admnNo: json["admn_no"],
          entryTime: json["entry_time"] == null
              ? null
              : DateTime.parse(json["entry_time"]),
          exitTime: json["exit_time"] == null
              ? null
              : DateTime.parse(json["exit_time"]),
          entryStat: json["entry_stat"],
          exitStat: json["exit_stat"],
          entryLat: json["entry_lat"],
          entryLong: json["entry_long"],
          exitLat: json["exit_lat"],
          exitLong: json["exit_long"],
          nfcTag: json["nfc_tag"],
          dateAdded: json["date_added"],
          tripId: json["trip_id"],
          except: json["except"],
          busNO: json['bus_no']);

  Map<String, dynamic> toJson() => {
        "track_id": trackId,
        "child_id": childId,
        "admn_no": admnNo,
        "entry_time": entryTime?.toIso8601String(),
        "exit_time": exitTime?.toIso8601String(),
        "entry_stat": entryStat,
        "exit_stat": exitStat,
        "entry_lat": entryLat,
        "entry_long": entryLong,
        "exit_lat": exitLat,
        "exit_long": exitLong,
        "nfc_tag": nfcTag,
        "date_added": dateAdded,
        "trip_id": tripId,
        "except": except,
        "bus_no": busNO,
      };
}

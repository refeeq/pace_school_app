class LiveTrip {
  final String? tripId;
  final String? imei;
  final String? busNo;
  final DateTime? startTime;
  final dynamic endTime;
  final String? tripType;
  final String? tripStat;
  final String? studCount;
  final String? tripTypeId;
  final String? tripName;
  final String? stat;
  final String? tripDirection;
  final String? tripBifurId;
  final String? grade;

  LiveTrip({
    this.tripId,
    this.imei,
    this.busNo,
    this.startTime,
    this.endTime,
    this.tripType,
    this.tripStat,
    this.studCount,
    this.tripTypeId,
    this.tripName,
    this.stat,
    this.tripDirection,
    this.tripBifurId,
    this.grade,
  });

  factory LiveTrip.fromJson(Map<String, dynamic> json) => LiveTrip(
        tripId: json["trip_id"],
        imei: json["imei"],
        busNo: json["bus_no"],
        startTime: json["start_time"] == null
            ? null
            : DateTime.parse(json["start_time"]),
        endTime: json["end_time"],
        tripType: json["trip_type"],
        tripStat: json["trip_stat"],
        studCount: json["stud_count"],
        tripTypeId: json["trip_type_id"],
        tripName: json["trip_name"],
        stat: json["stat"],
        tripDirection: json["trip_direction"],
        tripBifurId: json["trip_bifur_id"],
        grade: json["grade"],
      );

  Map<String, dynamic> toJson() => {
        "trip_id": tripId,
        "imei": imei,
        "bus_no": busNo,
        "start_time": startTime?.toIso8601String(),
        "end_time": endTime,
        "trip_type": tripType,
        "trip_stat": tripStat,
        "stud_count": studCount,
        "trip_type_id": tripTypeId,
        "trip_name": tripName,
        "stat": stat,
        "trip_direction": tripDirection,
        "trip_bifur_id": tripBifurId,
        "grade": grade,
      };
}

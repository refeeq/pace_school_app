// To parse this JSON data, do
//
//     final circularListModel = circularListModelFromJson(jsonString);

class CircularModel {
  final String id;

  final String circularDate;
  final String circularHead;
  final String circular;
  final String file;
  CircularModel({
    required this.id,
    required this.circularDate,
    required this.circularHead,
    required this.circular,
    required this.file,
  });

  factory CircularModel.fromJson(Map<String, dynamic> json) => CircularModel(
        id: json["id"],
        circularDate: json["circular_date"],
        circularHead: json["circular_head"],
        circular: json["circular"],
        file: json["file"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "circular_date": circularDate,
        "circular_head": circularHead,
        "circular": circular,
        "file": file,
      };
}

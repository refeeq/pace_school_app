class TransportDataModel {
  final String? studid;
  final String? busNo1;
  final String? busNo2;

  TransportDataModel({
    this.studid,
    this.busNo1,
    this.busNo2,
  });

  factory TransportDataModel.fromJson(Map<String, dynamic> json) =>
      TransportDataModel(
        studid: json["studid"],
        busNo1: json["busNo1"],
        busNo2: json["busNo2"],
      );

  Map<String, dynamic> toJson() => {
        "studid": studid,
        "busNo1": busNo1,
        "busNo2": busNo2,
      };
}

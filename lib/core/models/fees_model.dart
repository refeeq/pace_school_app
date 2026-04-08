class FeesModel {
  bool isSelected;

  final String description;

  final String feeAmt;
  final String vatAmt;
  final String vatStat;
  final int vatPerc;
  final String acYear;
  final String acYearId;
  final String monthId;
  final String feeItemId;
  final String advStat;

  FeesModel({
    this.isSelected = true,
    required this.description,
    required this.feeAmt,
    required this.vatAmt,
    required this.vatStat,
    required this.vatPerc,
    required this.acYear,
    required this.monthId,
    required this.advStat,
    required this.acYearId,
    required this.feeItemId,
  });

  factory FeesModel.fromJson(Map<String, dynamic> json) => FeesModel(
        description: json["description"],
        feeAmt: json["feeAmt"],
        vatAmt: json["vatAmt"],
        vatStat: json["vatStat"],
        vatPerc: json["vatPerc"],
        acYear: json["acYear"],
        acYearId: json["acYearId"],
        monthId: json["monthId"],
        feeItemId: json["feeItemId"],
        advStat: json["advStat"],
      );

  Map<String, dynamic> toJson() => {
        "description": description,
        "feeAmt": feeAmt,
        "vatAmt": vatAmt,
        "vatStat": vatStat,
        "vatPerc": vatPerc,
        "acYear": acYear,
        "acYearId": acYearId,
        "monthId": monthId,
        "feeItemId": feeItemId,
        "advStat": advStat,
      };
}

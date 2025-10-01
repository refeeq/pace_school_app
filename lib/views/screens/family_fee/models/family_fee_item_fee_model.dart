class FamilyFeeItemFee {
  String description;
  String feeAmt;
  String vatAmt;
  String vatStat;
  int vatPerc;
  String acYear;
  String acYearId;
  String monthId;
  String feeItemId;
  String advStat;
  bool isSelected;
  FamilyFeeItemFee({
    required this.description,
    required this.feeAmt,
    required this.vatAmt,
    required this.vatStat,
    required this.vatPerc,
    required this.acYear,
    required this.acYearId,
    required this.monthId,
    required this.feeItemId,
    required this.advStat,
    this.isSelected = true,
  });

  factory FamilyFeeItemFee.fromJson(Map<String, dynamic> json) =>
      FamilyFeeItemFee(
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

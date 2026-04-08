import 'package:school_app/views/screens/family_fee/models/family_fee_item_fee_model.dart';

class FamilyFeeItem {
  String studcode;
  String fullname;
  String datumClass;
  String section;
  String studStat;
  String acdyear;
  String acYearId;
  String stdsex;
  String datbirth;
  String national;
  String photo;
  bool chkboxReadOnly;
  double amount;
  List<FamilyFeeItemFee> fee;

  FamilyFeeItem({
    required this.studcode,
    this.amount = 0,
    required this.fullname,
    required this.datumClass,
    required this.section,
    required this.studStat,
    required this.acdyear,
    required this.acYearId,
    required this.stdsex,
    required this.datbirth,
    required this.national,
    required this.photo,
    required this.chkboxReadOnly,
    required this.fee,
  });

  factory FamilyFeeItem.fromJson(Map<String, dynamic> json) {
    // Create a list of FamilyFeeItemFee objects from the JSON
    List<FamilyFeeItemFee> fees = List<FamilyFeeItemFee>.from(
      json["fee"].map((x) => FamilyFeeItemFee.fromJson(x)),
    );

    // Calculate the total amount based on the fees
    double calculatedAmount = calculateAmount(fees);

    // Return the FamilyFeeItem object with the calculated amount
    return FamilyFeeItem(
      studcode: json["studcode"],
      fullname: json["fullname"],
      datumClass: json["class"],
      section: json["section"],
      studStat: json["stud_stat"],
      acdyear: json["acdyear"],
      acYearId: json["ac_year_id"],
      stdsex: json["STDSEX"],
      datbirth: json["DATBIRTH"],
      national: json["national"],
      photo: json["photo"],
      chkboxReadOnly: json['chkbox_read_only'],
      amount: calculatedAmount, // Set the calculated amount
      fee: fees,
    );
  }

  static double calculateAmount(List<FamilyFeeItemFee> fees) {
    double amount = 0;
    for (var item in fees) {
      if (item.isSelected) {
        amount += double.parse(item.feeAmt);
      }
    }
    // Calculate the total amount by summing up the fee amounts
    return amount;
  }

  Map<String, dynamic> toJson() => {
    "studcode": studcode,
    "fullname": fullname,
    "class": datumClass,
    "section": section,
    "stud_stat": studStat,
    "acdyear": acdyear,
    "ac_year_id": acYearId,
    "STDSEX": stdsex,
    "DATBIRTH": datbirth,
    "national": national,
    "photo": photo,
    "chkbox_read_only": chkboxReadOnly,
    "fee": List<dynamic>.from(
      fee.where((item) => item.isSelected).map((x) => x.toJson()),
    ),
    "amount": amount,
  };
}

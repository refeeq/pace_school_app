class Transaction {
  final String accDate;

  final String studcode;
  final String name;
  final String type;
  final String desc;
  final String label;
  final String drAmt;
  final String gid;
  final String crAmt;
  final String amt;
  final String doctType;
  final String no;
  Transaction({
    required this.accDate,
    required this.studcode,
    required this.name,
    required this.type,
    required this.desc,
    required this.label,
    required this.drAmt,
    required this.gid,
    required this.crAmt,
    required this.amt,
    required this.doctType,
    required this.no,
  });
  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    accDate: json["acc_date"],
    studcode: json["studcode"],
    name: json["name"] ?? "",
    type: json["type"],
    desc: json["Desc"],
    label: json["color"] ?? "",
    drAmt: json["DrAmt"],
    gid: json["gid"],
    crAmt: json["CrAmt"],
    amt: json["amt"],
    doctType: json["doc_type"] ?? "",
    no: json['no'].toString(),
  );

  Map<String, dynamic> toJson() => {
    "acc_date": accDate,
    "studcode": studcode,
    "name": name,
    "type": type,
    "Desc": desc,
    "color": label,
    "DrAmt": drAmt,
    "gid": gid,
    "CrAmt": crAmt,
  };
}

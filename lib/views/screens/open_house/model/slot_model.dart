class SlotDetail {
  final int slotId;
  final String slotFrom;
  final String slotTo;
  final int bookStat;
  final int bookedByMe;

  SlotDetail({
    required this.slotId,
    required this.slotFrom,
    required this.slotTo,
    required this.bookStat,
    required this.bookedByMe,
  });

  factory SlotDetail.fromJson(Map<String, dynamic> json) => SlotDetail(
        slotId: json["slotId"],
        slotFrom: json["slot_from"],
        slotTo: json["slot_to"],
        bookStat: json["book_stat"],
        bookedByMe: json["bookedByMe"],
      );

  Map<String, dynamic> toJson() => {
        "slotId": slotId,
        "slot_from": slotFrom,
        "slot_to": slotTo,
        "book_stat": bookStat,
        "bookedByMe": bookedByMe,
      };
}

class ContactUsHistoryItem {
  final int id;
  final String message;
  final String name;
  final String email;
  final String phone;
  final DateTime? dateAdded;
  final String reply;
  final DateTime? replyDate;
  final String replyBy;
  final bool hasReply;

  ContactUsHistoryItem({
    required this.id,
    required this.message,
    required this.name,
    required this.email,
    required this.phone,
    this.dateAdded,
    this.reply = '',
    this.replyDate,
    this.replyBy = '',
    this.hasReply = false,
  });

  factory ContactUsHistoryItem.fromJson(Map<String, dynamic> json) {
    final dateAddedStr = json['date_added']?.toString();
    final replyDateStr = json['reply_date']?.toString();

    return ContactUsHistoryItem(
      id: (json['id'] is int) ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      message: json['message']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      dateAdded: dateAddedStr != null && dateAddedStr.isNotEmpty
          ? DateTime.tryParse(dateAddedStr)
          : null,
      reply: json['reply']?.toString() ?? '',
      replyDate: replyDateStr != null && replyDateStr.isNotEmpty
          ? DateTime.tryParse(replyDateStr)
          : null,
      replyBy: json['reply_by']?.toString() ?? '',
      hasReply: json['has_reply'] == true,
    );
  }

  static List<ContactUsHistoryItem> listFromJson(dynamic data) {
    if (data is! List) return [];
    final list = <ContactUsHistoryItem>[];
    for (final e in data) {
      if (e is Map<String, dynamic>) {
        try {
          list.add(ContactUsHistoryItem.fromJson(e));
        } catch (_) {
          // skip malformed items
        }
      }
    }
    return list;
  }
}

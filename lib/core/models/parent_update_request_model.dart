class ParentUpdateRequestListModel {
  final bool status;
  final String message;
  final List<ParentUpdateRequest> data;

  ParentUpdateRequestListModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ParentUpdateRequestListModel.fromJson(Map<String, dynamic> json) {
    List<ParentUpdateRequest> dataList = <ParentUpdateRequest>[];
    if (json['data'] is List) {
      for (final e in json['data'] as List) {
        if (e is Map<String, dynamic>) {
          try {
            dataList.add(ParentUpdateRequest.fromJson(e));
          } catch (_) {
            // Skip malformed list items to avoid crashing the whole parse
          }
        }
      }
    }
    return ParentUpdateRequestListModel(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      data: dataList,
    );
  }
}

class ParentUpdateRequest {
  final int id;
  final String requestType;
  final String requestTypeLabel;
  final String? studcode;
  final String? newValue;
  final String? expiryDate;
  final String? dateRequested;
  final int approvalStatus;
  final String approvalStatusLabel;
  final String? approvedAt;
  final String? remark;

  ParentUpdateRequest({
    required this.id,
    required this.requestType,
    required this.requestTypeLabel,
    required this.studcode,
    required this.newValue,
    required this.expiryDate,
    required this.dateRequested,
    required this.approvalStatus,
    required this.approvalStatusLabel,
    required this.approvedAt,
    required this.remark,
  });

  factory ParentUpdateRequest.fromJson(Map<String, dynamic> json) {
    return ParentUpdateRequest(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      requestType: json['request_type']?.toString() ?? '',
      requestTypeLabel: json['request_type_label']?.toString() ?? '',
      studcode: json['studcode']?.toString(),
      newValue: json['new_value']?.toString(),
      expiryDate: json['expiry_date']?.toString(),
      dateRequested: json['date_requested']?.toString(),
      approvalStatus: int.tryParse(json['approval_status']?.toString() ?? '') ?? 0,
      approvalStatusLabel: json['approval_status_label']?.toString() ?? '',
      approvedAt: json['approved_at']?.toString(),
      remark: json['remark']?.toString(),
    );
  }

  bool get isPending => approvalStatus == 0;

  bool get isApproved => approvalStatus == 1;

  bool get isRejected => approvalStatus == 2;
}


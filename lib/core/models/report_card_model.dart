/// Models for Report Card APIs (getReportNamesByClass, getReportCardHtml)

class ClassHistoryItem {
  final String acYearId;
  final String klass;
  final String section;

  ClassHistoryItem({
    required this.acYearId,
    required this.klass,
    required this.section,
  });

  factory ClassHistoryItem.fromJson(Map<String, dynamic> json) =>
      ClassHistoryItem(
        acYearId: (json["ac_year_id"] ?? '').toString(),
        klass: (json["class"] ?? '').toString(),
        section: (json["section"] ?? '').toString(),
      );

  Map<String, dynamic> toJson() => {
        "ac_year_id": acYearId,
        "class": klass,
        "section": section,
      };
}

class ReportCardItem {
  final String id;
  final String reportName;
  final String defaultDate;
  final String term;
  final String acYearId;
  final String klass;
  final String section;
  /// Optional exam ID from getReportNamesByClass; used by getReportCardHtml.
  /// If absent, report.id is used as fallback.
  final String? exmId;

  ReportCardItem({
    required this.id,
    required this.reportName,
    required this.defaultDate,
    required this.term,
    required this.acYearId,
    required this.klass,
    required this.section,
    this.exmId,
  });

  factory ReportCardItem.fromJson(Map<String, dynamic> json) => ReportCardItem(
        id: (json["id"] ?? '').toString(),
        reportName: (json["report_name"] ?? '').toString(),
        defaultDate: (json["default_date"] ?? '').toString(),
        term: (json["term"] ?? '').toString(),
        acYearId: (json["ac_year_id"] ?? '').toString(),
        klass: (json["class"] ?? '').toString(),
        section: (json["section"] ?? '').toString(),
        exmId: () {
          final v = json["exm_id"];
          if (v == null) return null;
          final s = v.toString().trim();
          return s.isEmpty ? null : s;
        }(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "report_name": reportName,
        "default_date": defaultDate,
        "term": term,
        "ac_year_id": acYearId,
        "class": klass,
        "section": section,
        if (exmId != null) "exm_id": exmId,
      };

  bool matchesClass(ClassHistoryItem c) =>
      acYearId == c.acYearId && klass == c.klass && section == c.section;
}

class ReportCardStudentInfo {
  final int studcode;
  final int publicAcYearId;

  ReportCardStudentInfo({
    required this.studcode,
    required this.publicAcYearId,
  });

  factory ReportCardStudentInfo.fromJson(Map<String, dynamic> json) =>
      ReportCardStudentInfo(
        studcode: (json["studcode"] is int)
            ? json["studcode"]
            : int.tryParse(json["studcode"]?.toString() ?? '0') ?? 0,
        publicAcYearId: (json["public_ac_year_id"] is int)
            ? json["public_ac_year_id"]
            : int.tryParse(json["public_ac_year_id"]?.toString() ?? '0') ?? 0,
      );
}

class ReportNamesResponse {
  final ReportCardStudentInfo student;
  final List<ClassHistoryItem> classHistory;
  final List<ReportCardItem> reports;

  ReportNamesResponse({
    required this.student,
    required this.classHistory,
    required this.reports,
  });

  factory ReportNamesResponse.fromJson(Map<String, dynamic> json) {
    ReportCardStudentInfo student = ReportCardStudentInfo(
      studcode: 0,
      publicAcYearId: 0,
    );
    if (json["student"] is Map<String, dynamic>) {
      student =
          ReportCardStudentInfo.fromJson(json["student"] as Map<String, dynamic>);
    }

    List<ClassHistoryItem> classHistory = [];
    if (json["class_history"] is List) {
      for (final x in json["class_history"] as List) {
        if (x is Map<String, dynamic>) {
          classHistory.add(ClassHistoryItem.fromJson(x));
        }
      }
    }

    List<ReportCardItem> reports = [];
    if (json["reports"] is List) {
      for (final x in json["reports"] as List) {
        if (x is Map<String, dynamic>) {
          reports.add(ReportCardItem.fromJson(x));
        }
      }
    }

    return ReportNamesResponse(
      student: student,
      classHistory: classHistory,
      reports: reports,
    );
  }
}

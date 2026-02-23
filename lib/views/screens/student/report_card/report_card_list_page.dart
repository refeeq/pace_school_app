import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/config/app_status.dart';
import 'package:school_app/core/models/report_card_model.dart';
import 'package:school_app/core/provider/student_provider.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/views/components/common_app_bar.dart';
import 'package:school_app/views/components/slect_student.dart';
import 'package:school_app/views/screens/student/report_card/report_card_detail_page.dart';

class ReportCardListPage extends StatelessWidget {
  const ReportCardListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstColors.backgroundColor,
      appBar: const CommonAppBar(title: 'Report Card'),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: SelectStudentWidget(
              onchanged: (index) {
                Provider.of<StudentProvider>(context, listen: false)
                    .getReportNamesByClass(
                  Provider.of<StudentProvider>(context, listen: false)
                      .selectedStudentModel(context)
                      .studcode,
                );
              },
            ),
          ),
          Expanded(
            child: Consumer<StudentProvider>(
              builder: (context, value, child) {
                switch (value.reportNamesState) {
                  case AppStates.Unintialized:
                  case AppStates.Initial_Fetching:
                    return const Center(child: CircularProgressIndicator());
                  case AppStates.Fetched:
                    return _buildClassList(context, value);
                  case AppStates.NoInterNetConnectionState:
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Text(
                          'Network error. Please check your connection.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  case AppStates.Error:
                    return _buildEmptyState(
                      context,
                      'Unable to load report cards. Please try again.',
                    );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassList(BuildContext context, StudentProvider value) {
    final data = value.reportNamesData;
    if (data == null) {
      return _buildEmptyState(context, 'No report cards available.');
    }

    final classHistory = data.classHistory;
    final reports = data.reports;
    final admissionNo = value.selectedStudentModel(context).studcode;

    if (classHistory.isEmpty && reports.isEmpty) {
      return _buildEmptyState(context, 'No report cards available.');
    }

    // If no class history but we have reports, show single expandable section
    if (classHistory.isEmpty && reports.isNotEmpty) {
      return _buildExpandableList(
        context,
        [
          _ClassTileData(
            label: 'Report Cards',
            reports: reports,
          ),
        ],
        admissionNo,
      );
    }

    final tiles = classHistory.map((classItem) {
      final classReports =
          reports.where((r) => r.matchesClass(classItem)).toList();
      return _ClassTileData(
        label: 'Grade ${classItem.klass} ${classItem.section}'.trim(),
        reports: classReports,
      );
    }).toList();

    return _buildExpandableList(context, tiles, admissionNo);
  }

  Widget _buildExpandableList(
    BuildContext context,
    List<_ClassTileData> tiles,
    String admissionNo,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, left: 10, right: 10, bottom: 16),
      itemCount: tiles.length,
      itemBuilder: (context, index) {
        final tile = tiles[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _ExpandableClassTile(
            label: tile.label,
            reports: tile.reports,
            admissionNo: admissionNo,
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: ShapeDecoration(
          color: ConstColors.filledColor,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1,
              color: ConstColors.borderColor,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Center(
              child: Image.asset(
                'assets/images/image.png',
                height: MediaQuery.sizeOf(context).height * 0.2,
              ),
            ),
            Center(
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClassTileData {
  final String label;
  final List<ReportCardItem> reports;

  _ClassTileData({
    required this.label,
    required this.reports,
  });
}

class _ExpandableClassTile extends StatelessWidget {
  final String label;
  final List<ReportCardItem> reports;
  final String admissionNo;

  const _ExpandableClassTile({
    required this.label,
    required this.reports,
    required this.admissionNo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 10,
            offset: const Offset(4, 0),
          ),
        ],
        border: Border.all(color: ConstColors.borderColor),
        color: ConstColors.filledColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
          expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
          title: Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
          subtitle: Text(
            '${reports.length} report${reports.length == 1 ? '' : 's'} available',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          trailing: const Icon(Icons.keyboard_arrow_down),
          children: reports.isEmpty
              ? [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'No report cards available',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ),
                ]
              : reports
                  .map(
                    (report) => _ReportCardTile(
                      report: report,
                      admissionNo: admissionNo,
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }
}

class _ReportCardTile extends StatelessWidget {
  final ReportCardItem report;
  final String admissionNo;

  const _ReportCardTile({
    required this.report,
    required this.admissionNo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: InkWell(
        onTap: () {
          Provider.of<StudentProvider>(context, listen: false)
              .getReportCardHtml(admissionNo, report.id);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReportCardDetailPage(
                title: report.reportName,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: ConstColors.borderColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.reportName,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    if (report.defaultDate.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        report.defaultDate,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                'View',
                style: TextStyle(
                  color: ConstColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward_ios, size: 14, color: ConstColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/provider/student_provider.dart';
import 'package:school_app/views/components/border_with_text_widget.dart';
import 'package:school_app/views/components/profile_tile.dart';
import 'package:school_app/views/screens/student/student_profile/edit_emirates_id.dart';

bool _isExpiredOrToday(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return false;
  final formats = [
    DateFormat('dd/MM/yyyy'),
    DateFormat('MM/dd/yyyy'),
    DateFormat('yyyy-MM-dd'),
    DateFormat.yMMMd(),
  ];
  DateTime? parsed;
  for (final f in formats) {
    try {
      parsed = f.parse(dateStr);
      break;
    } catch (_) {}
  }
  if (parsed == null) return false;
  final today = DateTime.now();
  final normalized = DateTime(parsed.year, parsed.month, parsed.day);
  final normalizedToday = DateTime(today.year, today.month, today.day);
  return !normalized.isAfter(normalizedToday);
}

class DocumentDetailWidget extends StatelessWidget {
  const DocumentDetailWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentProvider>(
      builder: (context, value, child) {
        if (value.studentDetailModel == null) {
          return const SizedBox.shrink();
        }
        final data = value.studentDetailModel!.data;

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: BorderWithTextWidget(
            title: "Student Document Details",
            widget: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                Builder(
                  builder: (context) {
                    final canEdit = true;
                    // _isExpiredOrToday(data.emiratesId);
                    void navigate() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditEmiratesIdScreen(),
                        ),
                      );
                    }

                    return InkWell(
                      onTap: canEdit ? navigate : null,
                      child: ProfileTile(
                        canEdit: canEdit,
                        label: "Emirates ID",
                        value: data.emiratesId,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 5),
                Builder(
                  builder: (context) {
                    final canEdit = true;
                    //_isExpiredOrToday(data.emiratesIdExp);
                    void navigate() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditEmiratesIdScreen(),
                        ),
                      );
                    }

                    return InkWell(
                      onTap: canEdit ? navigate : null,
                      child: ProfileTile(
                        canEdit: canEdit,
                        label: "Emirates ID Expiry date",
                        value: data.emiratesIdExp,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 5),
                ProfileTile(label: "Passport Number", value: data.passno),
                const SizedBox(height: 5),
                ProfileTile(
                  label: "Passport Issue Date",
                  value: data.ppIssueDate,
                ),
                const SizedBox(height: 5),
                ProfileTile(
                  label: "Passport Expiry Date",
                  value: data.ppExpDate,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

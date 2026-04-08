import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/provider/student_provider.dart';
import 'package:school_app/core/utils/utils.dart';
import 'package:school_app/views/components/border_with_text_widget.dart';

class DocumentExpiryAlertsWidget extends StatelessWidget {
  const DocumentExpiryAlertsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentProvider>(
      builder: (context, studentProvider, child) {
        if (studentProvider.documentWarnings.isEmpty) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: BorderWithTextWidget(
            title: "Document Expiry Alerts",
            widget: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: studentProvider.documentWarnings
                  .map((w) => _DocumentWarningTile(warning: w))
                  .toList(),
            ),
          ),
        );
      },
    );
  }
}

/// Returns the first two words of a full name (e.g. "MUHAMMAD IHSAN" from
/// "MUHAMMAD IHSAN RAFEEQ REHUMAN JOWHARA SHAJAHAN").
String _shortName(String fullName) {
  final parts = fullName.trim().split(RegExp(r'\s+'));
  if (parts.length <= 2) return fullName;
  return parts.take(2).join(' ');
}

class _DocumentWarningTile extends StatelessWidget {
  final DocumentWarning warning;

  const _DocumentWarningTile({required this.warning});

  @override
  Widget build(BuildContext context) {
    final isExpired = warning.status == DocumentExpiryStatus.expired;
    final color = isExpired ? Colors.red.shade500 : Colors.orange.shade700;
    final statusText =
        isExpired ? "Expired" : "Expiring soon";
    final displayName = _shortName(warning.studentName);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(color: color, width: 4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: color,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$displayName's ${warning.documentType}",
                  style: GoogleFonts.nunitoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$statusText (${warning.expiryDate})",
                  style: GoogleFonts.nunitoSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

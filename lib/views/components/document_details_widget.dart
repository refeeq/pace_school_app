import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/provider/student_provider.dart';
import 'package:school_app/core/utils/utils.dart';
import 'package:school_app/views/components/border_with_text_widget.dart';
import 'package:school_app/views/components/profile_tile.dart';
import 'package:school_app/views/screens/student/student_profile/student_eid_request_screen.dart';
import 'package:school_app/views/screens/student/student_profile/student_passport_request_screen.dart';

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
        final eidExpiryStatus = getDocumentExpiryStatus(data.emiratesIdExp);
        final ppExpiryStatus = getDocumentExpiryStatus(data.ppExpDate);
        final eidColor = eidExpiryStatus == DocumentExpiryStatus.expired
            ? Colors.red.shade500
            : eidExpiryStatus == DocumentExpiryStatus.expiringSoon
                ? Colors.orange
                : null;
        final ppColor = ppExpiryStatus == DocumentExpiryStatus.expired
            ? Colors.red.shade500
            : ppExpiryStatus == DocumentExpiryStatus.expiringSoon
                ? Colors.orange
                : null;

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
                    void navigate() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const StudentEidRequestScreen(),
                        ),
                      );
                    }

                    return InkWell(
                      onTap: navigate,
                      child: ProfileTile(
                        canEdit: false,
                        label: "Emirates ID",
                        value: data.emiratesId,
                        valueColor: eidColor,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 5),
                Builder(
                  builder: (context) {
                    void navigate() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const StudentEidRequestScreen(),
                        ),
                      );
                    }

                    return InkWell(
                      onTap: navigate,
                      child: ProfileTile(
                        canEdit: true,
                        label: "Emirates ID Expiry date",
                        value: data.emiratesIdExp,
                        valueColor: eidColor,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 5),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const StudentPassportRequestScreen(),
                      ),
                    );
                  },
                  child: ProfileTile(
                    canEdit: true,
                    label: "Passport Number",
                    value: data.passno,
                    valueColor: ppColor,
                  ),
                ),
                const SizedBox(height: 5),
                ProfileTile(
                  label: "Passport Issue Date",
                  value: data.ppIssueDate,
                ),
                const SizedBox(height: 5),
                ProfileTile(
                  label: "Passport Expiry Date",
                  value: data.ppExpDate,
                  valueColor: ppColor,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

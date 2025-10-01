import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/provider/student_provider.dart';
import 'package:school_app/views/components/border_with_text_widget.dart';
import 'package:school_app/views/components/profile_tile.dart';

class DocumentDetailWidget extends StatelessWidget {
  const DocumentDetailWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentProvider>(
      builder: (context, value, child) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: BorderWithTextWidget(
          title: "Student Document Details",
          widget: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              ProfileTile(
                label: "Emirates ID",
                value: value.studentDetailModel!.data.emiratesId,
              ),
              const SizedBox(height: 5),
              ProfileTile(
                label: "Emirates ID Expiry date",
                value: value.studentDetailModel!.data.emiratesIdExp,
              ),
              const SizedBox(height: 5),
              ProfileTile(
                label: "Passport Number",
                value: value.studentDetailModel!.data.passno,
              ),
              const SizedBox(height: 5),
              ProfileTile(
                label: "Passport Issue Date",
                value: value.studentDetailModel!.data.ppIssueDate,
              ),
              const SizedBox(height: 5),
              ProfileTile(
                label: "Passport Expiry Date",
                value: value.studentDetailModel!.data.ppExpDate,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

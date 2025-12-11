import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/provider/student_provider.dart';
import 'package:school_app/views/components/profile_tile.dart';

import 'border_with_text_widget.dart';

class BasicDetailWidget extends StatelessWidget {
  const BasicDetailWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentProvider>(
      builder: (context, value, child) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: BorderWithTextWidget(
          title: "Primary Details",
          widget: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              ProfileTile(
                label: "Name of Student",
                value: value.studentDetailModel!.data.fullname,
              ),

              const SizedBox(height: 5),
              ProfileTile(
                label: "Admission Number",
                value: value.studentDetailModel!.data.studcode,
              ),
              const SizedBox(height: 5),
              ProfileTile(
                label: "Grade & Section",
                value:
                    "${value.studentDetailModel!.data.dataClass} - ${value.studentDetailModel!.data.section}",
              ),

              const SizedBox(height: 5),
              ProfileTile(
                label: "Date of Birth",
                value: value.studentDetailModel!.data.datbirth,
              ),

              const SizedBox(height: 5),
              ProfileTile(
                label: "Birth Place",
                value: value.studentDetailModel!.data.birthplac,
              ),

              const SizedBox(height: 5),
              ProfileTile(
                label: "Nationality",
                value: value.studentDetailModel!.data.nationality,
              ),

              // SizedBox(
              //   height: 20,
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

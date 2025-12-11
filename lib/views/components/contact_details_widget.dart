import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/provider/student_provider.dart';
import 'package:school_app/views/components/border_with_text_widget.dart';
import 'package:school_app/views/components/profile_tile.dart';
import 'package:school_app/views/screens/parent/parent_profile/parent_profile_screen_view.dart';

class ContactDetailsWidget extends StatelessWidget {
  const ContactDetailsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentProvider>(
      builder: (context, value, child) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: BorderWithTextWidget(
          title: "Parent Details",
          widget: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  ProfileTile(
                    label: "Name of Father",
                    value: value.studentDetailModel!.parentData.fname,
                  ),
                  const SizedBox(height: 5),
                  ProfileTile(
                    label: "Contact Number",
                    value: value.studentDetailModel!.parentData.mobile,
                  ),
                  const SizedBox(height: 5),
                  ProfileTile(
                    label: "Name of Mother",
                    value: value.studentDetailModel!.parentData.mname,
                  ),
                  const SizedBox(height: 5),
                  ProfileTile(
                    label: "Contact Number",
                    value: value.studentDetailModel!.parentData.mmob,
                  ),
                  const SizedBox(height: 5),
                  Center(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const ParentProfileScreenView(),
                          ),
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "View More",
                            style: TextStyle(color: Colors.blue),
                          ),
                          Icon(
                            Icons.double_arrow_rounded,
                            color: Colors.blue,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/config/app_status.dart';
import 'package:school_app/core/models/communication_student_model.dart';
import 'package:school_app/core/provider/communication_provider.dart';
import 'package:school_app/core/provider/student_provider.dart';
import 'package:school_app/core/utils/utils.dart';

class SelectStudentWidget extends StatelessWidget {
  final void Function(int index) onchanged;
  /// When true, shows unread communication badge per student (Communication tab only).
  final bool showCommunicationUnread;

  const SelectStudentWidget({
    super.key,
    required this.onchanged,
    this.showCommunicationUnread = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<StudentProvider, CommunicationProvider>(
      builder: (context, studentProvider, communicationProvider, child) {
        switch (studentProvider.studentListState) {
          case AppStates.Unintialized:
            // getStudents is triggered by bottom_nav initState; avoid duplicate call
            return Container();
          case AppStates.Initial_Fetching:
            return Container();
          case AppStates.Fetched:
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Colors.grey, width: 1.0),
                ),
              ),
              height: 100,
              child: Center(
                child: ListView.builder(
                  itemCount: studentProvider.studentsModel!.data.length,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemBuilder: (context, index) => GestureDetector(
                    onTap: () {
                      final selected = studentProvider.studentsModel!.data[index];
                      Provider.of<StudentProvider>(
                        context,
                        listen: false,
                      ).selectStudent(
                        selected,
                        index: index,
                      );
                      onchanged(index);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: SizedBox(
                        height: 100,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Builder(
                              builder: (context) {
                                final student =
                                    studentProvider.studentsModel!.data[index];
                                final isSelected =
                                    studentProvider.selectedStudentModel(context)
                                            .studcode ==
                                        student.studcode;
                                final statusColour =
                                    student.statusColour.isNotEmpty
                                        ? parseRgbColor(student.statusColour)
                                        : null;
                                final int unread = showCommunicationUnread
                                    ? _unreadForStudent(
                                        communicationProvider
                                            .communicationStudentList,
                                        student.studcode,
                                      )
                                    : 0;
                                return Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: isSelected
                                          ? Colors.blue
                                          : Colors.white,
                                      radius: 30,
                                      child: CircleAvatar(
                                        radius: 28,
                                        backgroundImage: NetworkImage(
                                          studentProvider
                                              .studentsModel!
                                              .data[index]
                                              .photo,
                                        ),
                                      ),
                                    ),
                                    if (statusColour != null)
                                      Positioned(
                                        right: 0,
                                        bottom: 0,
                                        child: Container(
                                          width: 14,
                                          height: 14,
                                          decoration: BoxDecoration(
                                            color: statusColour,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (unread > 0)
                                      Positioned(
                                        right: -2,
                                        top: -2,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          constraints: const BoxConstraints(
                                            minWidth: 22,
                                            minHeight: 22,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withValues(alpha: 0.25),
                                                blurRadius: 4,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Text(
                                              unread > 99
                                                  ? '99+'
                                                  : unread.toString(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 5),
                            Text(
                              studentProvider
                                  .studentsModel!
                                  .data[index]
                                  .fullname,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 5),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );

          case AppStates.NoInterNetConnectionState:
            return Container();
          case AppStates.Error:
            return Container();
        }
      },
    );
  }

  static int _unreadForStudent(
    List<CommunicationStudentModel> list,
    String studcode,
  ) {
    for (final s in list) {
      if (s.studcode == studcode) return s.unread;
    }
    return 0;
  }
}

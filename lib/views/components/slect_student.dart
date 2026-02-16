// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/config/app_status.dart';
import 'package:school_app/core/provider/student_provider.dart';
import 'package:school_app/core/utils/utils.dart';

class SelectStudentWidget extends StatelessWidget {
  final void Function(int index) onchanged;

  const SelectStudentWidget({super.key, required this.onchanged});

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentProvider>(
      builder: (context, studentProvider, child) {
        switch (studentProvider.studentListState) {
          case AppStates.Unintialized:
            Future(() {
              studentProvider.getStudents();
            });
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
                        //  width: 100,
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
                                final statusColour = student.statusColour
                                        .isNotEmpty
                                    ? parseRgbColor(student.statusColour)
                                    : null;
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
}

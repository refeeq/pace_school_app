// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/config/app_status.dart';
import 'package:school_app/core/provider/student_provider.dart';

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
                      Provider.of<StudentProvider>(
                        context,
                        listen: false,
                      ).selectStudent(
                        studentProvider.studentsModel!.data[index],
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
                            CircleAvatar(
                              backgroundColor:
                                  studentProvider
                                          .selectedStudentModel(context)
                                          .studcode ==
                                      studentProvider
                                          .studentsModel!
                                          .data[index]
                                          .studcode
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

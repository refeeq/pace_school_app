import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/config/app_status.dart';
import 'package:school_app/core/provider/communication_provider.dart';
import 'package:school_app/core/provider/student_provider.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/views/components/common_app_bar.dart';
import 'package:school_app/views/components/slect_student.dart';
import 'package:school_app/views/screens/parent/parent_communication/communication_listing/communication_listing_screen.dart';

class CommunicationChecker extends StatefulWidget {
  const CommunicationChecker({super.key});

  @override
  State<CommunicationChecker> createState() => _CommunicationCheckerState();
}

class _CommunicationCheckerState extends State<CommunicationChecker> {
  bool isLoader = true;
  @override
  Widget build(BuildContext context) {
    final studentProvider = context.watch<StudentProvider>();
    final hasStudents = (studentProvider.studentsModel?.data.isNotEmpty ?? false);
    final isLoading = studentProvider.studentListState == AppStates.Initial_Fetching;

    if (!hasStudents) {
      return Scaffold(
        backgroundColor: ConstColors.backgroundColor,
        appBar: const CommonAppBar(title: "Communication"),
        body: SafeArea(
          child: Center(
            child: isLoading
                ? const CircularProgressIndicator()
                : const Text("No students available"),
          ),
        ),
      );
    }

    final selectedStudent = studentProvider.selectedStudentModel(context);

    return Scaffold(
      backgroundColor: ConstColors.backgroundColor,
      appBar: const CommonAppBar(title: "Communication"),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: SelectStudentWidget(
                showCommunicationUnread: true,
                onchanged: (index) {
                  Provider.of<CommunicationProvider>(
                    context,
                    listen: false,
                  ).getCommunicationList(
                    Provider.of<StudentProvider>(context, listen: false)
                        .selectedStudentModel(context)
                        .studcode,
                  );
                },
              ),
            ),
            Expanded(
              child: CommunicationListingScreen(
                studentId: selectedStudent.studcode,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Future(() {
      Provider.of<StudentProvider>(context, listen: false).getStudents();
      Provider.of<CommunicationProvider>(context, listen: false).getStudentList();
    });
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/config/app_status.dart';
import 'package:school_app/core/models/exam_report_model.dart';
import 'package:school_app/core/provider/student_provider.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/views/components/common_app_bar.dart';
import 'package:school_app/views/components/slect_student.dart';
import 'package:school_app/views/screens/student/progress_report/progress_report_page.dart';

class MyListViewBuilder extends StatelessWidget {
  final List<ExamReportListElement> examReportListElement;

  const MyListViewBuilder({super.key, required this.examReportListElement});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: examReportListElement.length, // Example number of items
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 10, right: 10),
            child: InkWell(
              onTap: () {
                Provider.of<StudentProvider>(
                  context,
                  listen: false,
                ).getProgressReport(
                  Provider.of<StudentProvider>(
                    context,
                    listen: false,
                  ).selectedStudentModel(context).studcode,
                  examReportListElement[index].exmId,
                  examReportListElement[index].acYearId,
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProgressReportPage(
                      title: examReportListElement[index].examName,
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 10,
                      offset: const Offset(4, 0), // Shadow position
                    ),
                  ],
                  border: Border.all(color: ConstColors.borderColor),
                  color: ConstColors.filledColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          examReportListElement[index].examName,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'GRADE	${examReportListElement[index].grade}',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                    const Icon(Icons.arrow_forward_ios),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ProgressReportExamListPage extends StatelessWidget {
  const ProgressReportExamListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstColors.backgroundColor,
      appBar: const CommonAppBar(title: 'Progress Report'),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: SelectStudentWidget(
              onchanged: (index) {
                Provider.of<StudentProvider>(
                  context,
                  listen: false,
                ).getProgressReportExams(
                  Provider.of<StudentProvider>(
                    context,
                    listen: false,
                  ).selectedStudentModel(context).studcode,
                );
              },
            ),
          ),
          Expanded(
            child: Consumer<StudentProvider>(
              builder: (context, value, child) {
                switch (value.expamReportModel.status!) {
                  case AppStates.Unintialized:
                  case AppStates.Initial_Fetching:
                    return const Center(child: CircularProgressIndicator());
                  case AppStates.Fetched:
                    return value.expamReportModel.data == []
                        ? Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Container(
                              decoration: ShapeDecoration(
                                color: ConstColors.filledColor,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 1,
                                    color: ConstColors.borderColor,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Center(
                                    child: Image.asset(
                                      "assets/images/image.png",
                                      height:
                                          MediaQuery.sizeOf(context).height *
                                          0.2,
                                    ),
                                  ),
                                  Center(
                                    child: Text(
                                      "No Data Found",
                                      style: Theme.of(
                                        context,
                                      ).textTheme.headlineMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : DefaultTabController(
                            length: value.expamReportModel.data!.length,
                            child: Column(
                              children: [
                                Container(
                                  width: double.infinity,
                                  color: ConstColors.primary,
                                  child: Center(
                                    child: TabBar(
                                      tabAlignment: TabAlignment.center,
                                      isScrollable: true,
                                      labelColor: Colors.white,
                                      unselectedLabelColor: Colors.white24,
                                      tabs: value.expamReportModel.data!
                                          .map(
                                            (title) => Tab(
                                              text: " ${title.acYearId} ",
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: TabBarView(
                                    children: List.generate(
                                      value.expamReportModel.data!.length,
                                      (index) => MyListViewBuilder(
                                        examReportListElement: value
                                            .expamReportModel
                                            .data![index]
                                            .list,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                  case AppStates.NoInterNetConnectionState:
                    return const Center(child: Text("Networ erro"));
                  case AppStates.Error:
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        decoration: ShapeDecoration(
                          color: ConstColors.filledColor,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              width: 1,
                              color: ConstColors.borderColor,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Center(
                              child: Image.asset(
                                "assets/images/image.png",
                                height: MediaQuery.sizeOf(context).height * 0.2,
                              ),
                            ),
                            Center(
                              child: Text(
                                "No Data Found",
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

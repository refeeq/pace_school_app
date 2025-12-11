import 'package:flutter/material.dart';
import 'package:observe_internet_connectivity/observe_internet_connectivity.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/config/app_status.dart';
import 'package:school_app/core/provider/leave_provider.dart';
import 'package:school_app/core/provider/student_provider.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/core/themes/const_gradient.dart';
import 'package:school_app/core/utils/utils.dart';
import 'package:school_app/views/components/common_app_bar.dart';
import 'package:school_app/views/components/no_internet_connection.dart';
import 'package:school_app/views/components/shimmer_student_profile.dart';
import 'package:school_app/views/components/slect_student.dart';
import 'package:school_app/views/screens/student/leave_application/leave_application_forum.dart';
import 'package:school_app/views/screens/student/leave_application/leave_tile_widget.dart';

import '../../../components/no_data_widget.dart';

class LeaveApplicationScreen extends StatefulWidget {
  const LeaveApplicationScreen({super.key});

  @override
  State<LeaveApplicationScreen> createState() => _LeaveApplicationScreenState();
}

class _LeaveApplicationScreenState extends State<LeaveApplicationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: CircleAvatar(
        backgroundColor: ConstColors.primary,
        child: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LeaveApplicationForum(),
              ),
            );
          },
          icon: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      backgroundColor: ConstColors.backgroundColor,
      appBar: const CommonAppBar(title: "Leave Application"),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: SelectStudentWidget(
              onchanged: (index) async {
                Provider.of<StudentProvider>(
                  context,
                  listen: false,
                ).selectStudent(
                  Provider.of<StudentProvider>(
                    context,
                    listen: false,
                  ).studentsModel!.data[index],
                );
                await Provider.of<LeaveProvider>(
                  context,
                  listen: false,
                ).getLeaveList(
                  studentId: Provider.of<StudentProvider>(
                    context,
                    listen: false,
                  ).studentsModel!.data[index].studcode,
                );
              },
            ),
          ),
          Expanded(
            child: Consumer<LeaveProvider>(
              builder: (context, value, child) {
                switch (value.leaveListFetchState) {
                  case AppStates.Unintialized:
                  case AppStates.Initial_Fetching:
                    return Shimmer(
                      linearGradient: ConstGradient.shimmerGradient,
                      child: ListView.builder(
                        primary: false,
                        itemCount: 10,
                        shrinkWrap: true,
                        itemBuilder: (context, index) => ShimmerLoading(
                          isLoading: true,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 15,
                              right: 15,
                              bottom: 5,
                            ),
                            child: Container(
                              height: index.isEven ? 100 : 50,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                gradient: ConstGradient.shimmerGradient,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  case AppStates.Fetched:
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: value.leaveList.isEmpty
                          ? const Center(
                              child: NoDataWidget(
                                imagePath:
                                    "assets/images/no_leave_application.svg",
                                content:
                                    "You don't have any leave applications awaiting approval or processing. Keep up the good work!",
                              ),
                            )
                          : ListView.builder(
                              itemCount: value.leaveList.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) => LeaveTileWidget(
                                model: value.leaveList[index],
                              ),
                            ),
                    );
                  case AppStates.Error:
                    return const Center(child: Text("Error"));
                  case AppStates.NoInterNetConnectionState:
                    return NoInternetConnection(
                      ontap: () async {
                        bool hasInternet =
                            await InternetConnectivity().hasInternetConnection;
                        if (!hasInternet) {
                          showToast("No internet connection!", context);
                        } else {
                          value.getLeaveList(
                            studentId: Provider.of<StudentProvider>(
                              context,
                              listen: false,
                            ).selectedStudentModel(context).studcode,
                          );
                          // Navigator.pop(context);
                        }
                      },
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

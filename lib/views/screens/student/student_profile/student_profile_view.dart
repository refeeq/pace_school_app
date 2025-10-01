import 'package:flutter/material.dart';
import 'package:observe_internet_connectivity/observe_internet_connectivity.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/provider/student_provider.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/core/utils/utils.dart';
import 'package:school_app/views/components/common_app_bar.dart';
import 'package:school_app/views/components/slect_student.dart';
import 'package:school_app/views/screens/student/student_profile/student_profile_tab_view.dart';

import '../../../../core/config/app_status.dart';
import '../../../components/no_data_widget.dart';
import '../../../components/no_internet_connection.dart';

class ProfileHeaderTab extends StatelessWidget {
  final TabController _tabController;

  const ProfileHeaderTab({super.key, required TabController tabController})
    : _tabController = tabController;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: TabBar(
        isScrollable: true,
        labelStyle: const TextStyle(color: Colors.black),
        unselectedLabelStyle: const TextStyle(color: Colors.black),
        controller: _tabController,
        tabs: const [
          Tab(
            child: Text('Basic Details', style: TextStyle(color: Colors.black)),
            // text: 'Basic Details',
          ),
          Tab(
            child: Text(
              'Contact Information',
              style: TextStyle(color: Colors.black),
            ),
          ),
          Tab(
            child: Text(
              'Document Details',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}

class StudentProfileView extends StatefulWidget {
  const StudentProfileView({super.key});

  @override
  State<StudentProfileView> createState() => _StudentProfileViewState();
}

class _StudentProfileViewState extends State<StudentProfileView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstColors.backgroundColor,
      appBar: const CommonAppBar(title: "Profile"),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(color: Colors.white),
              child: SelectStudentWidget(
                onchanged: (index) {
                  Provider.of<StudentProvider>(
                    context,
                    listen: false,
                  ).getStudentDetail(
                    studCode: Provider.of<StudentProvider>(
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
                  switch (value.studentDetail) {
                    case AppStates.Unintialized:
                    case AppStates.Initial_Fetching:
                      // return NoDataWidget(
                      //   imagePath: "assets/images/no_data.svg",
                      //   content: "Something went wrong",
                      // );
                      return const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [Center(child: CircularProgressIndicator())],
                      );
                    case AppStates.Fetched:
                      if (value.studentDetailModel == null) {
                        return const NoDataWidget(
                          imagePath: "assets/images/no_data.svg",
                          content: "Something went wrong",
                        );
                      } else {
                        return SingleChildScrollView(
                          child: StudentProfileTabView(
                            studentDetailModel: value.studentDetailModel!,
                          ),
                        );
                      }
                    case AppStates.Error:
                      return const Center(child: Text("Error"));
                    case AppStates.NoInterNetConnectionState:
                      return NoInternetConnection(
                        ontap: () async {
                          bool hasInternet = await InternetConnectivity()
                              .hasInternetConnection;
                          if (!hasInternet) {
                            showToast("No internet connection!", context);
                          } else {
                            Provider.of<StudentProvider>(
                              context,
                              listen: false,
                            ).getStudentDetail(
                              studCode: Provider.of<StudentProvider>(
                                context,
                                listen: false,
                              ).selectedStudentModel(context).studcode,
                            );
                            //    Navigator.pop(context);
                          }
                        },
                      );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    Future(() {
      Provider.of<StudentProvider>(context, listen: false).getStudentDetail(
        studCode: Provider.of<StudentProvider>(
          context,
          listen: false,
        ).selectedStudentModel(context).studcode,
      );
    });
    super.didChangeDependencies();
  }
}

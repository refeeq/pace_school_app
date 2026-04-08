// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:observe_internet_connectivity/observe_internet_connectivity.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/config/app_status.dart';
import 'package:school_app/core/provider/attendance_provider.dart';
import 'package:school_app/core/provider/student_provider.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/core/utils/utils.dart';
import 'package:school_app/views/components/calender/flutter_neat_and_clean_calendar.dart';
import 'package:school_app/views/components/common_app_bar.dart';
import 'package:school_app/views/components/no_internet_connection.dart';
import 'package:school_app/views/components/slect_student.dart';

import '../../../components/attendance_shimmer_component.dart';

class AttendenceAppbar extends StatelessWidget {
  const AttendenceAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AttendenceProvider>(
      builder: (context, provider, child) => Container(
        decoration: BoxDecoration(
          color: const Color.fromRGBO(150, 177, 229, 1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                provider.updateIndex(0);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: provider.valu == 0 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "ATTENDANCE",
                    style: Theme.of(context).textTheme.labelLarge!.apply(
                      color: provider.valu == 0
                          ? const Color.fromRGBO(102, 136, 202, 1)
                          : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                provider.updateIndex(1);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: provider.valu == 1 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "HOLIDAY",
                    style: Theme.of(context).textTheme.labelLarge!.apply(
                      color: provider.valu == 1
                          ? const Color.fromRGBO(102, 136, 202, 1)
                          : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AttendenceScreen extends StatefulWidget {
  const AttendenceScreen({super.key});

  @override
  State<AttendenceScreen> createState() => _AttendenceScreenState();
}

class _AttendenceScreenState extends State<AttendenceScreen> {
  DateTime currentDate = DateTime.now();

  var month = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AttendenceProvider>(
      builder: (context, provider, child) => Hero(
        tag: "Attendance",
        child: Scaffold(
          backgroundColor: ConstColors.backgroundColor,
          appBar: const CommonAppBar(title: "Attendance", actions: []),
          body: Column(
            children: [
              Container(
                color: Colors.white,
                child: SelectStudentWidget(
                  onchanged: (index) {
                    provider.getAttendanceList(
                      studentId: Provider.of<StudentProvider>(
                        context,
                        listen: false,
                      ).selectedStudentModel(context).studcode,
                      month: currentDate.month.toString(),
                      year: currentDate.year.toString(),
                      context: context,
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: () {
                      // provider.changeMonthe(
                      //   provider.selectedMonth! - 1,
                      // );
                      setState(() {
                        currentDate = DateTime(
                          currentDate.year,
                          currentDate.month - 1,
                          currentDate.month - 1 == DateTime.now().month
                              ? DateTime.now().day
                              : 1,
                        );
                      });
                      provider.getAttendanceList(
                        studentId: Provider.of<StudentProvider>(
                          context,
                          listen: false,
                        ).selectedStudentModel(context).studcode,
                        month: currentDate.month.toString(),
                        year: currentDate.year.toString(),
                        context: context,
                      );
                      // log(currentDate.month.toString());
                    },
                    icon: const Icon(Icons.arrow_back_ios),
                  ),
                  Text(DateFormat.yMMMM().format(currentDate)),
                  IconButton(
                    onPressed: () {
                      // provider.changeMonthe(
                      //   provider.selectedMonth! + 1,
                      // );
                      setState(() {
                        currentDate = DateTime(
                          currentDate.year,
                          currentDate.month + 1,
                          currentDate.month - 1 == DateTime.now().month
                              ? DateTime.now().day
                              : 1,
                        );
                      });
                      provider.getAttendanceList(
                        studentId: Provider.of<StudentProvider>(
                          context,
                          listen: false,
                        ).selectedStudentModel(context).studcode,
                        month: currentDate.month.toString(),
                        year: currentDate.year.toString(),
                        context: context,
                      );
                    },
                    icon: const Icon(Icons.arrow_forward_ios),
                  ),
                ],
              ),
              Expanded(
                child: Consumer<AttendenceProvider>(
                  builder: (context, provider, child) {
                    switch (provider.attendanceListState) {
                      case AppStates.Unintialized:
                        Future(
                          () => provider.getAttendanceList(
                            studentId: Provider.of<StudentProvider>(
                              context,
                              listen: false,
                            ).selectedStudentModel(context).studcode,
                            month: currentDate.month.toString(),
                            year: currentDate.year.toString(),
                            context: context,
                          ),
                        );
                        return const AttendenceShimmerComponent();
                      case AppStates.Initial_Fetching:
                        return const AttendenceShimmerComponent();
                      case AppStates.Fetched:
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: ConstColors.filledColor,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: ConstColors.borderColor,
                                width: 1,
                              ),
                            ),
                            child: Calendar(
                              initialDate: currentDate,
                              //startOnMonday: true,
                              weekDays: const [
                                'SUN',
                                'MON',
                                'TUE',
                                'WED',
                                'THU',
                                'FRI',
                                'SAT',
                              ],
                              eventsList: provider.eventList,
                              isExpandable: false,
                              hideTodayIcon: true,

                              selectedTodayColor: Colors.transparent,
                              todayColor: Colors.black,
                              locale: 'en_US',

                              isExpanded: true,
                              expandableDateFormat: 'EEEE, dd. MMMM yyyy',

                              // datePickerType: DatePickerType.date,
                              dayOfWeekStyle: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        );
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
                              provider.getAttendanceList(
                                studentId: Provider.of<StudentProvider>(
                                  context,
                                  listen: false,
                                ).selectedStudentModel(context).studcode,
                                month: currentDate.month.toString(),
                                year: currentDate.year.toString(),
                                context: context,
                              );
                              Navigator.pop(context);
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
      ),
    );
  }
}

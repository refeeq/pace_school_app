// ignore_for_file: deprecated_member_use

import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:observe_internet_connectivity/observe_internet_connectivity.dart';
import 'package:provider/provider.dart';
import 'package:school_app/app.dart';
import 'package:school_app/core/config/app_status.dart';
import 'package:school_app/core/models/slider_model.dart';
import 'package:school_app/core/models/student_menu_model.dart';
import 'package:school_app/core/provider/student_fee_provider.dart';
import 'package:school_app/core/provider/student_provider.dart';
import 'package:school_app/core/services/dependecyInjection.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/core/themes/const_gradient.dart';
import 'package:school_app/core/utils/utils.dart';
import 'package:school_app/views/components/gridview_loader_component.dart';
import 'package:school_app/views/components/menu_item.dart';
import 'package:school_app/views/components/no_data_widget.dart';
import 'package:school_app/views/components/no_internet_connection.dart';
import 'package:school_app/views/components/shimmer_student_profile.dart';
import 'package:school_app/views/components/update_alert.dart';
import 'package:school_app/views/screens/bus_track/cubit/bus_track_cubit.dart';
import 'package:school_app/views/screens/bus_track/pages/bus_track_page.dart';
import 'package:school_app/views/screens/home_screen/home_screen_shimmer.dart';
import 'package:school_app/views/screens/internal_web/pages/internal_web_page.dart';
import 'package:school_app/views/screens/open_house/screens/open_house_page.dart';
import 'package:school_app/views/screens/sibilingRegister/page/sibiling_registration_list.dart';
import 'package:school_app/views/screens/student/attendence_screen/attendence_screen_view.dart';
import 'package:school_app/views/screens/student/fees_screen/fees_screen_view.dart';
import 'package:school_app/views/screens/student/leave_application/leave_application_screen.dart';
import 'package:school_app/views/screens/student/progress_report/progress_report_exams_page.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/provider/attendance_provider.dart';
import '../../../core/provider/leave_provider.dart';
import '../../components/app_drawer.dart';
import '../school_information_screen/school_information_screen_view.dart';
import '../student/circular_screen/circular_screen_view.dart';
import '../student/library_screen/library_screen_view.dart';
import '../student/student_fee_statement/student_fee_statement_screen.dart';
import '../student/student_profile/student_profile_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> _scaffoldKey1 = GlobalKey<ScaffoldState>();
  final CarouselSliderController _controller = CarouselSliderController();
  int _current = 0;
  @override
  void initState() {
    logToken();
    // TODO: implement initState
    super.initState();
  }

  Future<void> logToken() async {
    try {
      var token = await FirebaseMessaging.instance.getToken();
      // var frr=await FirebaseMessaging.instance.app.toString();
      log(FirebaseMessaging.instance.app.toString());
      log(token.toString());
    } catch (e) {
      log("Firebase Messaging error in logToken: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentProvider>(
      builder: (context, value, child) {
        switch (value.studentListState) {
          case AppStates.Unintialized:
            Future(() {
              value.getStudents();
            });
            return Shimmer(
              linearGradient: ConstGradient.shimmerGradient,
              child: const HomeShimmerView(),
            );
          case AppStates.Initial_Fetching:
            return Shimmer(
              linearGradient: ConstGradient.shimmerGradient,
              child: const HomeShimmerView(),
            );

          case AppStates.Fetched:
            if (value.studentsModel == null) {
              return const NoDataWidget(
                imagePath: "assets/images/no_data.svg",
                content: "Something went wrong",
              );
            } else {
              return Scaffold(
                appBar: AppBar(
                  leadingWidth: 50,
                  leading: GestureDetector(
                    onTap: () {
                      if (_scaffoldKey1.currentState!.isDrawerOpen == false) {
                        _scaffoldKey1.currentState!.openDrawer();
                      } else {
                        _scaffoldKey1.currentState!.openEndDrawer();
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        "assets/Icons/menus.png",
                        height: 25,
                        width: 25,
                        color: const Color.fromARGB(255, 255, 255, 255),
                      ),
                    ),
                  ),
                  title: Text(AppEnivrornment.appFullName),
                  actions: [
                    CircleAvatar(
                      radius: 25,
                      backgroundImage: AssetImage(AppEnivrornment.appImageName),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),

                //  PreferredSize(
                //     preferredSize: Size(double.infinity,
                //         MediaQuery.of(context).size.height * 0.095),
                //     child: SafeArea(
                //       child: ParentTile(
                //         fkey: _scaffoldKey1,
                //         type: 0,
                //         isSlect: true,
                //         parentModel: value.studentsModel!.parent,
                //       ),
                //     )),
                key: _scaffoldKey,
                backgroundColor: Colors.transparent,
                body: Scaffold(
                  backgroundColor: Colors.transparent,
                  key: _scaffoldKey1,
                  drawer: Container(
                    decoration: BoxDecoration(
                      gradient: ConstGradient.linearGradient,
                    ),
                    child: const DrawerWidget(),
                  ),
                  body: Container(
                    height: MediaQuery.of(context).size.height,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      // borderRadius: BorderRadius.only(
                      //   topLeft: Radius.circular(40),
                      //   topRight: Radius.circular(40),
                      // ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 18.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            value.studentsModel!.sliderModel.isNotEmpty
                                ? Padding(
                                    padding: EdgeInsets.only(
                                      left: 15.w,
                                      right: 15.w,
                                    ),
                                    child: CarouselSlider.builder(
                                      carouselController: _controller,
                                      itemCount: value
                                          .studentsModel!
                                          .sliderModel
                                          .length,
                                      itemBuilder: (context, index, realIndex) {
                                        SliderModel sliderModel = value
                                            .studentsModel!
                                            .sliderModel[index];
                                        return GestureDetector(
                                          onTap: () {
                                            if (sliderModel.webUrl == null) {
                                              if (sliderModel.page ==
                                                  "SiblingRegistration") {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const SibilingRegistrationList(),
                                                  ),
                                                );
                                              }
                                            } else {
                                              launchUrl(
                                                Uri.parse(sliderModel.webUrl),
                                              );
                                            }
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10.0.r),
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                  sliderModel.sliderUrl
                                                      .toString(),
                                                ),
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      options: CarouselOptions(
                                        onPageChanged: (index, reason) {
                                          setState(() {
                                            _current = index;
                                          });
                                        },
                                        height:
                                            MediaQuery.of(context).size.height *
                                            0.2.h,
                                        enlargeCenterPage: false,
                                        autoPlay: true,
                                        autoPlayCurve: Curves.linear,
                                        enableInfiniteScroll: true,
                                        autoPlayAnimationDuration:
                                            const Duration(milliseconds: 800),
                                        viewportFraction: 1,
                                      ),
                                    ),
                                  )
                                : const SizedBox(),
                            value.studentsModel!.sliderModel.isNotEmpty
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: value.studentsModel!.sliderModel
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                          return GestureDetector(
                                            onTap: () => _controller
                                                .animateToPage(entry.key),
                                            child: Container(
                                              width: 8.0.h,
                                              height: 8.0.h,
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 8.0,
                                                    horizontal: 4.0,
                                                  ),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color:
                                                    (Theme.of(
                                                                  context,
                                                                ).brightness ==
                                                                Brightness.dark
                                                            ? Colors.white
                                                            : ConstColors
                                                                  .primary)
                                                        .withOpacity(
                                                          _current == entry.key
                                                              ? 0.9
                                                              : 0.4,
                                                        ),
                                              ),
                                            ),
                                          );
                                        })
                                        .toList(),
                                  )
                                : const SizedBox(),
                            const SizedBox(height: 5),

                            Padding(
                              padding: EdgeInsets.only(left: 15.w, right: 15.w),
                              child: RichText(
                                text: TextSpan(
                                  text: 'Welcome,\n',
                                  style: GoogleFonts.nunitoSans(
                                    textStyle: DefaultTextStyle.of(
                                      context,
                                    ).style,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: value.studentsModel!.parent.name,
                                      style: GoogleFonts.nunitoSans(
                                        textStyle: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // SelectStudentWidget(onchanged: () {}),
                            Padding(
                              padding: EdgeInsets.all(15.0.sp),
                              child: Consumer<StudentProvider>(
                                builder: (context, value, child) {
                                  switch (value.studentMenu) {
                                    case AppStates.Unintialized:
                                      Future(
                                        () => value.getStudentMenu(
                                          studcode:
                                              Provider.of<StudentProvider>(
                                                    context,
                                                    listen: false,
                                                  )
                                                  .selectedStudentModel(context)
                                                  .studcode,
                                        ),
                                      );
                                      return Shimmer(
                                        linearGradient:
                                            ConstGradient.shimmerGradient,
                                        child: const GridLoaderComponent(),
                                      );
                                    case AppStates.Initial_Fetching:
                                      return Shimmer(
                                        linearGradient:
                                            ConstGradient.shimmerGradient,
                                        child: const GridLoaderComponent(),
                                      );
                                    case AppStates.Fetched:
                                      if (value.studentMenuModel == null) {
                                        return Container();
                                      } else {
                                        final items = [
                                          ...value.studentMenuModel!.data
                                        ];
                                        final circularIndex = items.indexWhere(
                                          (e) => e.menuKey == "Circular",
                                        );
                                        if (!items.any(
                                          (e) => e.menuKey == "Library",
                                        )) {
                                          final library = StudentMenu(
                                            id: "Library",
                                            iconUrl: "",
                                            subMenu: null,
                                            weburl: null,
                                            menuKey: "Library",
                                            menuValue: "Library",
                                          );
                                          if (circularIndex == -1) {
                                            items.add(library);
                                          } else {
                                            items.insert(circularIndex + 1, library);
                                          }
                                        }
                                        return GridView.builder(
                                          primary: false,
                                          shrinkWrap: true,
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 3,
                                                childAspectRatio: 2.7.h / 3.6.h,
                                                crossAxisSpacing: 2.h,
                                                mainAxisSpacing: 4.w,
                                              ),
                                          itemCount: items.length,
                                          itemBuilder: (BuildContext ctx, index) {
                                            final item = items[index];
                                            return Hero(
                                              tag: item.id,
                                              child: StudentMenuItemWidget(
                                                homeTile: item,
                                                ontap: () async {
                                                  final menuKey = item.menuKey;
                                                  final studcode =
                                                      Provider.of<
                                                            StudentProvider
                                                          >(
                                                            context,
                                                            listen: false,
                                                          )
                                                          .selectedStudentModel(
                                                            context,
                                                          )
                                                          .studcode;

                                                  if (menuKey == "Attendance") {
                                                    Provider.of<
                                                          AttendenceProvider
                                                        >(
                                                          context,
                                                          listen: false,
                                                        )
                                                        .getAttendanceList(
                                                          studentId: studcode,
                                                          month: DateTime.now()
                                                              .month
                                                              .toString(),
                                                          year: DateTime.now()
                                                              .year
                                                              .toString(),
                                                          context: context,
                                                        );
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            const AttendenceScreen(),
                                                      ),
                                                    );
                                                  } else if (menuKey ==
                                                      "Circular") {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            const CircularScreenView(),
                                                      ),
                                                    );
                                                  } else if (menuKey ==
                                                      "Library") {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            const LibraryScreenView(),
                                                      ),
                                                    );
                                                  } else if (menuKey ==
                                                      "SchoolInfo") {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            SchoolInformationScreenView(),
                                                      ),
                                                    );
                                                  } else if (menuKey ==
                                                      "PayFee") {
                                                    Provider.of<
                                                          StudentFeeProvider
                                                        >(
                                                          context,
                                                          listen: false,
                                                        )
                                                        .getStudentFee(
                                                          studentId: studcode,
                                                        );
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            const FeeScreenView(),
                                                      ),
                                                    );
                                                  } else if (menuKey ==
                                                      "FeeStatement") {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            const StudentFeesStatementScreen(),
                                                      ),
                                                    );
                                                  } else if (menuKey ==
                                                      "StudentProfile") {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            const StudentProfileView(),
                                                      ),
                                                    );
                                                  } else if (menuKey ==
                                                      "LeaveApplication") {
                                                    final leaveProvider =
                                                        Provider.of<
                                                          LeaveProvider
                                                        >(
                                                          context,
                                                          listen: false,
                                                        );
                                                    leaveProvider
                                                        .updateLeaveState(
                                                          AppStates
                                                              .Unintialized,
                                                        );
                                                    leaveProvider.getLeaveList(
                                                      studentId: studcode,
                                                    );
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            const LeaveApplicationScreen(),
                                                      ),
                                                    );
                                                  } else if (menuKey ==
                                                      "Progress Report") {
                                                    Provider.of<
                                                          StudentProvider
                                                        >(
                                                          context,
                                                          listen: false,
                                                        )
                                                        .getProgressReportExams(
                                                          studcode,
                                                        );
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            const ProgressReportExamListPage(),
                                                      ),
                                                    );
                                                  } else if (menuKey ==
                                                      "OpenHouse") {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            const OpenHousePage(),
                                                      ),
                                                    );
                                                  } else if (menuKey ==
                                                      "studTrack") {
                                                    locator<BusTrackCubit>()
                                                        .getTracking(
                                                          admissionNo: studcode,
                                                        );
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            const BusTrackPage(),
                                                      ),
                                                    );
                                                  } else if (menuKey ==
                                                      "internalWeb") {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            InternalWebPage(
                                                              studentMenu: item,
                                                            ),
                                                      ),
                                                    );
                                                  } else if (menuKey ==
                                                      "externalWeb") {
                                                    if (await canLaunch(
                                                      item.weburl!,
                                                    )) {
                                                      await launch(
                                                        item.weburl!,
                                                      );
                                                    } else {
                                                      throw 'Could not launch URL';
                                                    }
                                                  } else {
                                                    showDialog(
                                                      context: context,
                                                      builder:
                                                          (
                                                            BuildContext
                                                            context,
                                                          ) =>
                                                              const UpdateAlertDialog(),
                                                    );
                                                  }
                                                },
                                              ),
                                            );
                                          },
                                        );
                                      }
                                    case AppStates.Error:
                                      return const Center(
                                        child: Text("No Data"),
                                      );
                                    case AppStates.NoInterNetConnectionState:
                                      return NoInternetConnection(
                                        ontap: () async {
                                          bool hasInternet =
                                              await InternetConnectivity()
                                                  .hasInternetConnection;
                                          if (!hasInternet) {
                                            showToast(
                                              "No internet connection!",
                                              context,
                                            );
                                          } else {
                                            if (context.mounted) {
                                              Navigator.pop(context);
                                            }
                                            //  value.getStudentMenu();
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
                  ),
                ),
              );
            }
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
                  value.getStudents();
                }
              },
            );
        }
      },
    );
  }
}

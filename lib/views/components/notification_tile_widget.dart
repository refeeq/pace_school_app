import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/models/notification_model.dart';
import 'package:school_app/core/models/students_model.dart';
import 'package:school_app/core/provider/notification_provider.dart';
import 'package:school_app/core/provider/student_provider.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/views/screens/sibilingRegister/page/sibiling_registration_list.dart';

import '../../core/config/app_status.dart';
import '../../core/provider/attendance_provider.dart';
import '../../core/provider/leave_provider.dart';
import '../../core/provider/student_fee_provider.dart';
import '../../core/utils/utils.dart';
import '../screens/student/attendence_screen/attendence_screen_view.dart';
import '../screens/student/circular_screen/circular_file_view.dart';
import '../screens/student/circular_screen/circular_screen_view.dart';
import '../screens/student/fees_screen/fees_screen_view.dart';
import '../screens/student/leave_application/leave_application_screen.dart';
import '../screens/student/student_fee_statement/student_fee_statement_screen.dart';
import 'choose_student_tile.dart';

class NotificationTileWidget extends StatefulWidget {
  final NotificationModel model;
  const NotificationTileWidget({super.key, required this.model});

  @override
  State<NotificationTileWidget> createState() => _NotificationTileWidgetState();
}

class _NotificationTileWidgetState extends State<NotificationTileWidget> {
  bool isExpand = false;
  @override
  Widget build(BuildContext context) {
    StudentModel? studentModel = widget.model.student;
    // Figma Flutter Generator Group4Widget - GROUP

    return InkWell(
      onTap: () async {
        if (widget.model.readStatus == "0") {
          Provider.of<NotificationProvider>(
            context,
            listen: false,
          ).readNotification(widget.model.id);
          int count = await Hive.box('notificationCount').get('count') ?? 0;
          if (count > 0) {
            count--;
            await Hive.box("notificationCount").put("count", count);
          }
          await Hive.box("notificationCount").put("new", "");
          setState(() {
            widget.model.readStatus = "1";
          });
        }
        // if (widget.model.student != null) {
        //   Provider.of<StudentProvider>(context, listen: false)
        //       .selectStudent(widget.model.student!);
        // }
        showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          backgroundColor: ConstColors.backgroundColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
          ),
          builder: (context) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: MediaQuery.of(context).size.height - 100,
                  // optional: add padding
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          child: const CircleAvatar(
                            backgroundColor: Color.fromARGB(255, 108, 111, 122),
                            radius: 14,
                            child: Center(
                              child: Icon(Icons.close, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      widget.model.student == null
                          ? const SizedBox()
                          : Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: ChooseStudentTile(
                                showArrow: false,
                                studentModel: widget.model.student!,
                              ),
                            ),
                      Text(
                        widget.model.head.toString(),
                        style: GoogleFonts.nunitoSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            Text(
                              widget.model.notification.toString(),
                              textAlign: TextAlign.justify,
                              style: GoogleFonts.nunitoSans(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      widget.model.action.isEmpty
                          ? const SizedBox()
                          : Padding(
                              padding: const EdgeInsets.only(
                                left: 12,
                                right: 12,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  log("circular file ${widget.model.link} ");
                                  if (widget.model.action == "fee_payment") {
                                    Provider.of<StudentProvider>(
                                      context,
                                      listen: false,
                                    ).selectStudent(
                                      studentModel!,
                                      select: PageControllerState
                                          .PageControllerNeeded,
                                    );
                                    Provider.of<StudentFeeProvider>(
                                      context,
                                      listen: false,
                                    ).getStudentFee(
                                      studentId: studentModel.studcode,
                                    );
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const FeeScreenView(),
                                      ),
                                    );
                                  } else if (widget.model.action ==
                                      "attendance") {
                                    Provider.of<StudentProvider>(
                                      context,
                                      listen: false,
                                    ).selectStudent(studentModel!);
                                    Provider.of<AttendenceProvider>(
                                      context,
                                      listen: false,
                                    ).getAttendanceList(
                                      month: DateTime.now().month.toString(),
                                      year: DateTime.now().year.toString(),
                                      studentId: studentModel.studcode,
                                      context: context,
                                    );
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const AttendenceScreen(),
                                      ),
                                    );
                                  } else if (widget.model.action ==
                                      "fee_statement") {
                                    Provider.of<StudentProvider>(
                                      context,
                                      listen: false,
                                    ).selectStudent(studentModel!);
                                    Provider.of<StudentProvider>(
                                      context,
                                      listen: false,
                                    ).getStudents();
                                    Provider.of<StudentFeeProvider>(
                                      context,
                                      listen: false,
                                    ).getStudentFeeStatementlist(
                                      isRefresh: true,
                                      studeCode: studentModel.studcode,
                                    );
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const StudentFeesStatementScreen(),
                                      ),
                                    );
                                  } else if (widget.model.action ==
                                      "circular") {
                                    if (widget.model.link != null) {
                                      if (widget.model.link!.contains(".jpg")) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                CircularFileView(
                                                  url: widget.model.link!,
                                                ),
                                          ),
                                        );
                                      } else if (widget.model.link!.contains(
                                        ".pdf",
                                      )) {
                                        log("is pdf");
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute<dynamic>(
                                            builder: (_) => PDFViewerFromUrl(
                                              url: widget.model.link!,
                                            ),
                                          ),
                                        );
                                      } else {
                                        showToast("No file found", context);
                                      }
                                    } else {
                                      // Provider.of<CircularProvider>(context,
                                      //         listen: false)
                                      //     .getCircularList(
                                      //         studCode: widget.model.studcode);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const CircularScreenView(),
                                        ),
                                      );
                                    }
                                  } else if (widget.model.action ==
                                      "sibling_registration") {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const SibilingRegistrationList(),
                                      ),
                                    );
                                  } else if (widget.model.action ==
                                      "leave_application") {
                                    Provider.of<StudentProvider>(
                                      context,
                                      listen: false,
                                    ).selectStudent(studentModel!);
                                    Provider.of<LeaveProvider>(
                                      context,
                                      listen: false,
                                    ).updateLeaveState(AppStates.Unintialized);
                                    Provider.of<LeaveProvider>(
                                      context,
                                      listen: false,
                                    ).getLeaveList(
                                      studentId: studentModel.studcode,
                                    );
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const LeaveApplicationScreen(),
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: ConstColors.primary,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  width: MediaQuery.of(context).size.width,
                                  height: 40,
                                  child: Center(
                                    child: Text(
                                      widget.model.actionStatus,
                                      textAlign: TextAlign.left,
                                      style: GoogleFonts.nunitoSans(
                                        color: const Color.fromRGBO(
                                          255,
                                          255,
                                          255,
                                          1,
                                        ),
                                        fontSize: 18,
                                        letterSpacing: 0,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(
          left: 8.0,
          right: 8.0,
          bottom: 5,
          top: 5,
        ),
        child: Container(
          //  height: 120,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.2),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
            borderRadius: const BorderRadius.all(Radius.circular(6.0)),
            gradient: LinearGradient(
              stops: const [0.02, 0.02],
              colors: [
                widget.model.readStatus == "0"
                    ? Colors.blue
                    : ConstColors.buttonColor,
                Colors.white,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(
              left: 8.0,
              right: 8.0,
              bottom: 12,
              top: 12,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    right: 10,
                    left: 10,
                    top: 5,
                    bottom: 5,
                  ),
                  child: Stack(
                    children: [
                      widget.model.student == null
                          ? CircleAvatar(
                              radius: 21,
                              backgroundColor: const Color.fromRGBO(
                                53,
                                71,
                                140,
                                1,
                              ),
                              child: Image.asset(
                                'assets/Icons/i.png',
                                color: Colors.white,
                              ),
                            )
                          : CircleAvatar(
                              backgroundImage: NetworkImage(
                                widget.model.student!.photo,
                              ),
                            ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.model.head,
                              //  textAlign: TextAlign.left,
                              style: GoogleFonts.nunitoSans(
                                color: const Color.fromARGB(255, 108, 111, 122),
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          widget.model.studcode == "0"
                              ? const SizedBox()
                              : Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(4.0),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      widget.model.studcode,
                                      //  textAlign: TextAlign.left,
                                      style: GoogleFonts.nunitoSans(
                                        color: const Color.fromARGB(
                                          255,
                                          88,
                                          91,
                                          100,
                                        ),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                      Text(
                        "${widget.model.notification.substring(0, widget.model.notification.length > 150 ? 150 : widget.model.notification.length)}${widget.model.notification.length > 150 ? "..." : ""}",
                        style: GoogleFonts.nunitoSans(
                          color: widget.model.readStatus != "0"
                              ? const Color.fromARGB(255, 108, 111, 122)
                              : const Color.fromRGBO(53, 71, 140, 1),
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        widget.model.dateAdded,
                        //   textAlign: TextAlign.left,
                        style: GoogleFonts.nunitoSans(
                          color: widget.model.readStatus != "0"
                              ? const Color.fromARGB(255, 108, 111, 122)
                              : const Color.fromRGBO(53, 71, 140, 1),
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

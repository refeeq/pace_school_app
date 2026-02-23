import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/config/app_status.dart';
import 'package:school_app/core/models/student_menu_model.dart';
import 'package:school_app/core/provider/attendance_provider.dart';
import 'package:school_app/core/provider/leave_provider.dart';
import 'package:school_app/core/provider/student_fee_provider.dart';
import 'package:school_app/core/provider/student_provider.dart';
import 'package:school_app/core/services/dependecyInjection.dart';
import 'package:school_app/main.dart';
import 'package:school_app/views/screens/bus_track/cubit/bus_track_cubit.dart';
import 'package:school_app/views/screens/bus_track/pages/bus_track_page.dart';
import 'package:school_app/views/screens/internal_web/pages/internal_web_page.dart';
import 'package:school_app/views/screens/open_house/screens/open_house_page.dart';
import 'package:school_app/views/screens/school_information_screen/school_information_screen_view.dart';
import 'package:school_app/views/screens/student/attendence_screen/attendence_screen_view.dart';
import 'package:school_app/views/screens/student/circular_screen/circular_screen_view.dart';
import 'package:school_app/views/screens/student/fees_screen/fees_screen_view.dart';
import 'package:school_app/views/screens/student/leave_application/leave_application_screen.dart';
import 'package:school_app/views/screens/student/library_screen/library_screen_view.dart';
import 'package:school_app/views/screens/student/progress_report/progress_report_exams_page.dart';
import 'package:school_app/views/screens/student/report_card/report_card_list_page.dart';
import 'package:school_app/views/screens/student/student_fee_statement/student_fee_statement_screen.dart';
import 'package:school_app/views/screens/student/student_profile/student_profile_view.dart';

/// Navigates to the appropriate student menu screen based on [menuKey].
/// [studcode] is optional: if provided, the student is selected and menu is fetched first.
/// [url] is used for menu_key "internalWeb" (e.g. Activity Fee).
/// Returns true if a screen was pushed, false otherwise.
Future<bool> navigateToMenuScreen({
  required String menuKey,
  String? studcode,
  String? url,
}) async {
  final context = navigatorKey.currentContext;
  if (context == null) {
    log('menu_deeplink: No context');
    return false;
  }

  try {
    final studentProvider = Provider.of<StudentProvider>(context, listen: false);

    if (studcode != null && studcode.isNotEmpty) {
      studentProvider.selectStudentWithStudId(studcode);
      await studentProvider.getStudentMenu(studcode: studcode);
    }

    final state = navigatorKey.currentState;
    if (state == null) return false;

    final String key = menuKey.trim();

    switch (key) {
      case 'Attendance':
        Provider.of<AttendenceProvider>(context, listen: false).getAttendanceList(
          studentId: studcode ?? studentProvider.selectedStudentModel(context).studcode,
          month: DateTime.now().month.toString(),
          year: DateTime.now().year.toString(),
          context: context,
        );
        state.push(MaterialPageRoute(builder: (_) => const AttendenceScreen()));
        break;
      case 'Circular':
        state.push(MaterialPageRoute(builder: (_) => const CircularScreenView()));
        break;
      case 'Library':
        state.push(MaterialPageRoute(builder: (_) => const LibraryScreenView()));
        break;
      case 'SchoolInfo':
        state.push(MaterialPageRoute(builder: (_) => SchoolInformationScreenView()));
        break;
      case 'PayFee':
        Provider.of<StudentFeeProvider>(context, listen: false).getStudentFee(
          studentId: studcode ?? studentProvider.selectedStudentModel(context).studcode,
        );
        state.push(MaterialPageRoute(builder: (_) => const FeeScreenView()));
        break;
      case 'FeeStatement':
        state.push(MaterialPageRoute(builder: (_) => const StudentFeesStatementScreen()));
        break;
      case 'StudentProfile':
        state.push(MaterialPageRoute(builder: (_) => const StudentProfileView()));
        break;
      case 'LeaveApplication':
        final leaveProvider = Provider.of<LeaveProvider>(context, listen: false);
        leaveProvider.updateLeaveState(AppStates.Unintialized);
        leaveProvider.getLeaveList(
          studentId: studcode ?? studentProvider.selectedStudentModel(context).studcode,
        );
        state.push(MaterialPageRoute(builder: (_) => const LeaveApplicationScreen()));
        break;
      case 'Progress Report':
        studentProvider.getProgressReportExams(
          studcode ?? studentProvider.selectedStudentModel(context).studcode,
        );
        state.push(MaterialPageRoute(builder: (_) => const ProgressReportExamListPage()));
        break;
      case 'Report Card':
      case 'ReportCard':
        studentProvider.getReportNamesByClass(
          studcode ?? studentProvider.selectedStudentModel(context).studcode,
        );
        state.push(MaterialPageRoute(builder: (_) => const ReportCardListPage()));
        break;
      case 'OpenHouse':
        state.push(MaterialPageRoute(builder: (_) => const OpenHousePage()));
        break;
      case 'studTrack':
        locator<BusTrackCubit>().getTracking(
          admissionNo: studcode ?? studentProvider.selectedStudentModel(context).studcode,
        );
        state.push(MaterialPageRoute(builder: (_) => const BusTrackPage()));
        break;
      case 'internalWeb':
        final loadUrl = url?.trim();
        if (loadUrl != null && loadUrl.isNotEmpty) {
          final studentMenu = StudentMenu(
            id: '0',
            menuKey: 'internalWeb',
            menuValue: 'Activity Fee',
            iconUrl: '',
            subMenu: null,
            weburl: loadUrl,
          );
          state.push(MaterialPageRoute(
            builder: (_) => InternalWebPage(studentMenu: studentMenu),
          ));
        } else {
          log('menu_deeplink: internalWeb requires url in data');
          return false;
        }
        break;
      default:
        log('menu_deeplink: Unknown menu_key "$key"');
        return false;
    }
    return true;
  } catch (e, st) {
    log('menu_deeplink error: $e\n$st');
    return false;
  }
}

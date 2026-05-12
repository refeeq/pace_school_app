import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/config/app_status.dart';
import 'package:school_app/core/provider/communication_provider.dart';
import 'package:school_app/core/provider/student_provider.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/views/components/slect_student.dart';
import 'package:school_app/views/screens/parent/parent_communication/communication_listing/communication_listing_screen.dart';
import 'package:school_app/views/screens/parent/parent_communication/communication_listing/message_filter_pills.dart';

class CommunicationChecker extends StatefulWidget {
  const CommunicationChecker({super.key});

  @override
  State<CommunicationChecker> createState() => _CommunicationCheckerState();
}

class _CommunicationCheckerState extends State<CommunicationChecker> {
  final TextEditingController _searchController = TextEditingController();
  MessageFilter _filter = MessageFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = context.watch<StudentProvider>();
    final hasStudents =
        (studentProvider.studentsModel?.data.isNotEmpty ?? false);
    final isLoading =
        studentProvider.studentListState == AppStates.Initial_Fetching;

    if (!hasStudents) {
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: ConstColors.primary,
          statusBarIconBrightness: Brightness.light,
        ),
        child: Scaffold(
          backgroundColor: ConstColors.backgroundColor,
          body: SafeArea(
            child: Center(
              child: isLoading
                  ? CircularProgressIndicator(color: ConstColors.primary)
                  : Text(
                      'No students available',
                      style: GoogleFonts.nunitoSans(
                        textStyle: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: ConstColors.primary.withValues(alpha: 0.75),
                        ),
                      ),
                    ),
            ),
          ),
        ),
      );
    }

    final selectedCode = studentProvider.selectedStudentModel(context).studcode;
    final searchQuery = _searchController.text;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: ConstColors.primary,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: ConstColors.backgroundColor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context, selectedCode),
            SelectStudentWidget(
              showCommunicationUnread: true,
              onchanged: (_) {
                final studCode = Provider.of<StudentProvider>(
                  context,
                  listen: false,
                ).selectedStudentModel(context).studcode;
                Provider.of<CommunicationProvider>(
                  context,
                  listen: false,
                ).getCommunicationList(studCode);
              },
            ),
            _buildSearchField(),
            MessageFilterPills(
              selected: _filter,
              onChanged: (f) => setState(() => _filter = f),
              allBadgeCount: _globalUnreadSum(context),
              unreadBadgeCount: _currentListUnreadCount(context),
            ),
            Expanded(
              child: ColoredBox(
                color: ConstColors.backgroundColor,
                child: CommunicationListingScreen(
                  key: ValueKey<String>(selectedCode),
                  studentId: selectedCode,
                  searchQuery: searchQuery,
                  messageFilter: _filter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String selectedCode) {
    return ColoredBox(
      color: ConstColors.primary,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Communication',
                    style: GoogleFonts.nunitoSans(
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Consumer<CommunicationProvider>(
                    builder: (context, comm, _) {
                      final n = _unreadForStudent(comm, selectedCode);
                      return Text(
                        n == 1
                            ? '1 unread message'
                            : '$n unread messages',
                        style: GoogleFonts.nunitoSans(
                          textStyle: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: 0.75),
                            letterSpacing: 0.1,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _unreadForStudent(CommunicationProvider comm, String studCode) {
    if (comm.communicationListState != AppStates.Fetched) return 0;
    return comm.communicationList.fold<int>(0, (s, t) => s + t.cnt);
  }

  int _globalUnreadSum(BuildContext context) {
    final comm = Provider.of<CommunicationProvider>(context, listen: true);
    return comm.communicationStudentList.fold<int>(0, (a, s) => a + s.unread);
  }

  int _currentListUnreadCount(BuildContext context) {
    final comm = Provider.of<CommunicationProvider>(context, listen: true);
    if (comm.communicationListState != AppStates.Fetched) return 0;
    return comm.communicationList.where((t) => t.cnt > 0).length;
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: ConstColors.filledColor,
        border: Border(bottom: BorderSide(color: ConstColors.borderColor)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        style: GoogleFonts.poppins(
          textStyle: TextStyle(
            fontSize: 14,
            color: ConstColors.primary.withValues(alpha: 0.88),
          ),
        ),
        cursorColor: ConstColors.primary,
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: ConstColors.filledColor,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: ConstColors.borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: ConstColors.primary.withValues(alpha: 0.85),
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 8, right: 4),
            child: Icon(
              Icons.search,
              color: ConstColors.primary.withValues(alpha: 0.42),
              size: 20,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 44,
            minHeight: 40,
          ),
          hintText: 'Search messages',
          hintStyle: GoogleFonts.poppins(
            textStyle: TextStyle(
              color: ConstColors.primary.withValues(alpha: 0.32),
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Provider.of<StudentProvider>(context, listen: false).getStudents();
      Provider.of<CommunicationProvider>(
        context,
        listen: false,
      ).getStudentList();
    });
  }
}

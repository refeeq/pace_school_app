import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:school_app/core/config/app_status.dart';
import 'package:school_app/core/provider/leave_provider.dart';
import 'package:school_app/core/provider/student_provider.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/core/utils/utils.dart';
import 'package:school_app/views/components/common_app_bar.dart';
import 'package:school_app/views/components/custom_text_field.dart';
import 'package:school_app/views/components/reason_select_widget.dart';
import 'package:school_app/views/components/slect_student.dart';
import 'package:school_app/views/components/submit_button.dart';
import 'package:school_app/views/screens/leave/bloc/leave_bloc.dart';

class LeaveApplicationForum extends StatefulWidget {
  const LeaveApplicationForum({super.key});

  @override
  State<LeaveApplicationForum> createState() => _LeaveApplicationForumState();
}

class _LeaveApplicationForumState extends State<LeaveApplicationForum> {
  final TextEditingController nameController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController phoneController = TextEditingController();

  final TextEditingController messageController = TextEditingController();

  final TextEditingController searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime? _startDate;
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  String startDate = '';
  String endDate = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstColors.backgroundColor,
      appBar: const CommonAppBar(title: "Leave Application"),
      body: Column(
        children: [
          SelectStudentWidget(
            onchanged: (index) {
              Provider.of<LeaveProvider>(
                context,
                listen: false,
              ).updateLeaveState(AppStates.Unintialized);
              // Provider.of<LeaveProvider>(context, listen: false)
              //     .getLeaveReaonsList();
            },
          ),
          Expanded(
            child: BlocConsumer<LeaveBloc, LeaveState>(
              listener: (context, state) {
                log(state.toString());

                if (state is ApplyLeaveApplicationSuccessState) {
                  if (state.isSuccess) {
                    Provider.of<LeaveProvider>(
                      context,
                      listen: false,
                    ).getLeaveList(
                      studentId: Provider.of<StudentProvider>(
                        context,
                        listen: false,
                      ).selectedStudentModel(context).studcode,
                    );
                    Provider.of<LeaveProvider>(
                      context,
                      listen: false,
                    ).updateLeaveReson(null);
                    messageController.clear();
                    _startDate = null;
                    startDate = '';
                    searchController.clear();
                  }

                  QuickAlert.show(
                    context: context,
                    type: state.isSuccess
                        ? QuickAlertType.success
                        : QuickAlertType.error,
                    title: state.message,
                  );
                } else if (state is ApplyLeaveApplicationFailureState) {
                  QuickAlert.show(
                    context: context,
                    type: QuickAlertType.error,
                    title: state.message,
                  );
                }
                // TODO: implement listener
              },
              builder: (context, state) {
                return SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () async {
                                    final selectedDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2100),
                                    );
                                    if (selectedDate != null) {
                                      setState(() {
                                        _startDate = selectedDate;
                                        startDate = DateFormat.yMMMd().format(
                                          selectedDate,
                                        );
                                      });
                                    }
                                  },
                                  child: Container(
                                    height: 45,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                      color: ConstColors.whiteColor,
                                      borderRadius: BorderRadius.circular(5.0),
                                      border: Border.all(
                                        color: ConstColors.borderColor,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Center(
                                        child: Text(
                                          startDate.isEmpty
                                              ? "From Date"
                                              : startDate,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: InkWell(
                                  onTap: () async {
                                    if (_startDate == null) {
                                      showToast("Select from date", context);
                                    } else {
                                      final selectedDate = await showDatePicker(
                                        context: context,
                                        initialDate: _endDate,
                                        firstDate: _startDate!,
                                        lastDate: DateTime(2100),
                                      );
                                      if (selectedDate != null) {
                                        setState(() {
                                          _endDate = selectedDate;
                                          endDate = DateFormat.yMMMd().format(
                                            selectedDate,
                                          );
                                        });
                                      }
                                    }
                                  },
                                  child: Container(
                                    height: 45,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                      color: ConstColors.whiteColor,
                                      borderRadius: BorderRadius.circular(5.0),
                                      border: Border.all(
                                        color: ConstColors.borderColor,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        endDate.isEmpty ? "To Date" : endDate,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ReasonSelectWidget(
                            searchController: searchController,
                            hintText: "Reason",
                          ),
                          const SizedBox(height: 10),
                          CustomtextFormFieldBorder(
                            hintText: "Remark",
                            textEditingController: messageController,
                            maxLines: 10,
                          ),
                          const SizedBox(height: 20),
                          state is ApplyLeaveApplicationLoadingstate
                              ? const Center(child: CircularProgressIndicator())
                              : SubmitButton(
                                  onTap: () {
                                    if (messageController.text.isNotEmpty ||
                                        Provider.of<LeaveProvider>(
                                              context,
                                              listen: false,
                                            ).selectedLeaveReasonModel !=
                                            null ||
                                        messageController.text.isNotEmpty ||
                                        _startDate != null) {
                                      BlocProvider.of<LeaveBloc>(context).add(
                                        LeaveApplyEvent(
                                          studentId:
                                              Provider.of<StudentProvider>(
                                                    context,
                                                    listen: false,
                                                  )
                                                  .selectedStudentModel(context)
                                                  .studcode,
                                          endDate: DateFormat(
                                            'dd/MM/yyyy',
                                          ).format(_endDate),
                                          fromDate: DateFormat(
                                            'dd/MM/yyyy',
                                          ).format(_startDate!),
                                          reason: messageController.text,
                                          reasonId:
                                              Provider.of<LeaveProvider>(
                                                    context,
                                                    listen: false,
                                                  ).selectedLeaveReasonModel ==
                                                  null
                                              ? ""
                                              : Provider.of<LeaveProvider>(
                                                      context,
                                                      listen: false,
                                                    )
                                                    .selectedLeaveReasonModel!
                                                    .listKey
                                                    .toString(),
                                        ),
                                      );
                                    } else {
                                      showToast("Fill the details", context);
                                    }
                                  },
                                  title: 'Apply Leave',
                                ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

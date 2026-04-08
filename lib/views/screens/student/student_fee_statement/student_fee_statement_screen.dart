import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/config/app_status.dart';
import 'package:school_app/core/models/students_model.dart';
import 'package:school_app/core/models/transaction_model.dart';
import 'package:school_app/core/provider/student_fee_provider.dart';
import 'package:school_app/core/provider/student_provider.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/core/themes/const_gradient.dart';
import 'package:school_app/views/components/common_app_bar.dart';
import 'package:school_app/views/components/no_data_widget.dart';
import 'package:school_app/views/components/payment_button.dart';
import 'package:school_app/views/components/slect_student.dart';
import 'package:school_app/views/components/transaction_tile.dart';
import 'package:school_app/views/screens/student/fees_screen/fees_screen_view.dart';

import '../../../components/shimmer_student_profile.dart';

class StudentFeesStatementScreen extends StatefulWidget {
  const StudentFeesStatementScreen({super.key});

  @override
  State<StudentFeesStatementScreen> createState() =>
      _StudentFeesStatementScreenState();
}

class _ListViewWidget extends StatelessWidget {
  final List<Transaction> _data;
  bool _isLoading;
  late DataState _dataState;
  late BuildContext _buildContext;
  late StudentModel studentModel;
  _ListViewWidget(this._data, this._isLoading);
  @override
  Widget build(BuildContext context) {
    _dataState = Provider.of<StudentFeeProvider>(
      context,
      listen: false,
    ).dataState;
    studentModel = Provider.of<StudentFeeProvider>(context).studentModel!;
    _buildContext = context;
    return SafeArea(child: _scrollNotificationWidget(context));
  }

  bool _scrollNotification(ScrollNotification scrollInfo) {
    if (!_isLoading &&
        scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
      _isLoading = true;
      Provider.of<StudentFeeProvider>(
        _buildContext,
        listen: false,
      ).getStudentFeeStatementlist(
        studeCode: Provider.of<StudentProvider>(
          _buildContext,
          listen: false,
        ).selectedStudentModel(_buildContext).studcode,
      );
    }
    return true;
  }

  Widget _scrollNotificationWidget(context) {
    return Column(
      children: [
        // Container(
        //   //   color: const Color(0x7FB3C5F7),
        //   child: Padding(
        //     padding: const EdgeInsets.only(
        //       left: 16.0,
        //       right: 16,
        //       bottom: 8,
        //       top: 8.0,
        //     ),
        //     child: Row(
        //       mainAxisAlignment: MainAxisAlignment.end,
        //       children: [
        //         Text(
        //           "Balance : ${Provider.of<StudentFeeProvider>(_buildContext, listen: false).pending_fee}",
        //           style: GoogleFonts.nunitoSans(
        //             textStyle: Theme.of(context)
        //                 .textTheme
        //                 .titleMedium!
        //                 .merge(const TextStyle(
        //                   color: Color(0xFF26273A),
        //                 )),
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: _scrollNotification,
            child: Padding(
              padding: EdgeInsets.only(top: 12.0, right: 12.w, left: 12.w),
              child: Container(
                decoration: ShapeDecoration(
                  color: ConstColors.filledColor,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1, color: ConstColors.borderColor),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  primary: false,
                  itemCount: _data.length,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            //                    <--- top side
                            color: ConstColors.borderColor,
                            width: 1.0,
                          ),
                        ),
                      ),
                      child: TransactionTileStudent(transaction: _data[index]),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        if (_dataState == DataState.More_Fetching)
          const Center(child: CircularProgressIndicator()),
        double.parse(
                  Provider.of<StudentFeeProvider>(
                    _buildContext,
                    listen: false,
                  ).pending_fee,
                ) ==
                0
            ? const SizedBox()
            : PaymentButton(
                ontap: () {
                  // BlocProvider.of<FamilyFeeCubit>(context).submitFee();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FeeScreenView(),
                    ),
                  );
                },
                totalAmount: double.parse(
                  Provider.of<StudentFeeProvider>(
                    _buildContext,
                    listen: false,
                  ).pending_fee.toString(),
                ),
              ),
      ],
    );
  }
}

class _StudentFeesStatementScreenState
    extends State<StudentFeesStatementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstColors.backgroundColor,
      appBar: const CommonAppBar(title: "Fee Statement"),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: SelectStudentWidget(
              onchanged: (index) {
                Provider.of<StudentFeeProvider>(
                  context,
                  listen: false,
                ).getStudentFeeStatementlist(
                  isRefresh: true,
                  studeCode: Provider.of<StudentProvider>(
                    context,
                    listen: false,
                  ).selectedStudentModel(context).studcode,
                );
              },
            ),
          ),
          Expanded(
            child: Consumer<StudentFeeProvider>(
              builder: (context, controller, child) {
                switch (controller.dataState) {
                  case DataState.Uninitialized:
                  case DataState.Initial_Fetching:
                    return Shimmer(
                      linearGradient: ConstGradient.shimmerGradient,
                      child: ShimmerLoading(
                        isLoading: true,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: 20,
                            itemBuilder: (context, index) => Column(
                              children: [
                                Container(
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    gradient: const LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        Color(0xfff1efef),
                                        Color(0xfff8f7f7),
                                        Color(0xffe7e5e5),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );

                  case DataState.More_Fetching:
                  case DataState.Refreshing:
                    return _ListViewWidget(controller.dataList, true);
                  case DataState.Fetched:
                  case DataState.Error:
                  case DataState.No_More_Data:
                    return _ListViewWidget(controller.dataList, false);
                  case DataState.NoInterNetConnectionState:
                    return const NoDataWidget(
                      imagePath: "assets/images/no_connection.svg",
                      content:
                          "No internet connection detected. Please ensure that your device is connected to a Wi-Fi or cellular network.",
                    );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    Provider.of<StudentFeeProvider>(
      context,
      listen: false,
    ).getStudentFeeStatementlist(
      isRefresh: true,
      studeCode: Provider.of<StudentProvider>(
        context,
        listen: false,
      ).selectedStudentModel(context).studcode,
    );
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }
}
